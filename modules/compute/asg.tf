# asg.tf (partie 1 : AMI + Launch Template)

# -----------------------------------------------------------------------------
# AMI Amazon Linux 2023 (x86_64) la plus recente
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# Launch Template : recette de construction d une EC2
# -----------------------------------------------------------------------------
resource "aws_launch_template" "app" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  # IAM instance profile fourni par le Role 5 (permet AWS CLI sur l EC2)
  iam_instance_profile {
    name = var.app_instance_profile_name
  }

  # Security Group app : seul l ALB peut parler HTTP 80 a l EC2
  vpc_security_group_ids = [var.app_security_group_id]

  # IMDSv2 obligatoire (contre le SSRF et les vols de credentials)
  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2 # 2 pour que Docker container puisse acceder IMDS
    instance_metadata_tags      = "enabled"
  }

  # Root volume chiffre par KMS (defaut AWS)
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 20
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  # user_data rendu par templatefile() avec les valeurs des autres modules
  user_data = base64encode(templatefile("${path.module}/templates/nextcloud-user-data.sh.tftpl", {
    db_endpoint               = var.db_endpoint
    db_name                   = var.db_name
    db_username               = var.db_username
    db_password_secret_arn    = var.db_password_secret_arn
    admin_password_secret_arn = var.admin_password_secret_arn
    s3_primary_bucket_name    = var.s3_primary_bucket_name
    alb_dns_name              = aws_lb.main.dns_name
    aws_region                = "eu-west-1"
  }))

  # Tags propages aux instances creees par l ASG
  tag_specifications {
    resource_type = "instance"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-app"
      Role = "nextcloud-app"
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-app-volume"
    })
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-launch-template"
  })

  # Si on change l AMI ou le user_data, on veut un nouveau LT avant suppression
  lifecycle {
    create_before_destroy = true
  }
}

# asg.tf (partie 2 : ASG)

resource "aws_autoscaling_group" "app" {
  name = "${local.name_prefix}-asg"

  # Subnets prives (les EC2 ne sont JAMAIS exposees directement)
  vpc_zone_identifier = local.private_app_subnet_ids_list

  # Taille : 1 seule instance a la fois (file locking Nextcloud sans Redis)
  min_size         = 1
  max_size         = 2
  desired_capacity = 1

  # Health check ELB : l ASG suit l avis du target group
  health_check_type         = "ELB"
  health_check_grace_period = 300 # 5 min pour que Nextcloud finisse de booter

  # Rattachement au Launch Template (toujours la derniere version)
  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # Rolling refresh si le LT change : on cycle les instances une par une
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
  }

  # Tags propages a chaque instance creee (separe du tag_specifications du LT
  # pour etre sur que Name est bien propage).
  tag {
    key                 = "Name"
    value               = "${local.name_prefix}-app"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }

  # create_before_destroy pour zero-downtime si on renomme l ASG
  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Rattachement ASG <-> Target Group (ressource separee en v5+)
# -----------------------------------------------------------------------------
resource "aws_autoscaling_attachment" "app_tg" {
  autoscaling_group_name = aws_autoscaling_group.app.name
  lb_target_group_arn    = aws_lb_target_group.app.arn
}

# alb.tf

# -----------------------------------------------------------------------------
# Application Load Balancer (public, cross-AZ)
# -----------------------------------------------------------------------------
resource "aws_lb" "main" {
  name               = "${local.name_prefix}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [var.alb_security_group_id]
  subnets            = local.public_subnet_ids_list

  # Protection contre destruction accidentelle en prod
  # FALSE en dev pour que terraform destroy fonctionne sans souci
  enable_deletion_protection = true

  # Recommandations AWS / tfsec
  drop_invalid_header_fields = true
  enable_http2               = true

  # Access logs : on ecrit dans le bucket fourni par le Role 4 (Data)
  access_logs {
    bucket  = var.s3_logs_bucket_name
    prefix  = "alb"
    enabled = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-alb"
  })
}

# -----------------------------------------------------------------------------
# Target Group : les EC2 Nextcloud enregistrees par l ASG arriveront ici.
# Health check sur /status.php, endpoint natif Nextcloud qui renvoie un JSON.
# -----------------------------------------------------------------------------
resource "aws_lb_target_group" "app" {
  name        = "${local.name_prefix}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # Deregistration delay : temps avant retrait d une EC2 degradee
  deregistration_delay = 30

  health_check {
    enabled             = true
    path                = "/status.php"
    port                = "traffic-port"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-tg"
  })

  # create_before_destroy : evite une fenetre sans TG si on renomme
  lifecycle {
    create_before_destroy = true
  }
}

# -----------------------------------------------------------------------------
# Listener HTTPS 443 : c est la porte d entree
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  # Politique TLS moderne (TLS 1.2 et 1.3, pas de SSLv3/TLS1.0)
  ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }

  tags = local.common_tags
}

# -----------------------------------------------------------------------------
# Listener HTTP 80 : redirige tout vers 443 (UX + securite)
# -----------------------------------------------------------------------------
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = local.common_tags
}

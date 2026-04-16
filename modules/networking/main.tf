# =============================================================================
# modules/networking/main.tf
# ROLE 2 (Network Engineer) — a completer
# =============================================================================
# OBJECTIF : creer le reseau complet Nextcloud.
#
# Ressources a declarer (voir role-2-network.md pour le detail par etape) :
#
#   - aws_vpc                     "main"             (cidr_block = var.vpc_cidr)
#   - aws_internet_gateway        "main"
#   - aws_subnet                  "public"           (for_each sur local.public_subnets)
#   - aws_subnet                  "private_app"      (for_each sur local.private_app_subnets)
#   - aws_subnet                  "private_db"       (for_each sur local.private_db_subnets)
#   - aws_eip                     "nat"              (domain = "vpc")
#   - aws_nat_gateway             "main"             (subnet_id = premiere AZ public)
#   - aws_route_table             "public"           (route 0.0.0.0/0 -> IGW)
#   - aws_route_table             "private"          (route 0.0.0.0/0 -> NAT)
#   - aws_route_table_association "public"           (for_each, 2 associations)
#   - aws_route_table_association "private_app"      (for_each)
#   - aws_route_table_association "private_db"       (for_each)
#   - aws_security_group          "endpoints"        (443 from vpc_cidr)
#   - aws_vpc_security_group_ingress_rule "endpoints_https"
#   - aws_vpc_endpoint            "s3"               (type = Gateway)
#   - aws_vpc_endpoint            "secretsmanager"   (type = Interface, private_dns_enabled = true)
#   - aws_vpc_endpoint            "kms"              (type = Interface, private_dns_enabled = true)
#
# Total : ~21 ressources
#
# Les locals (name_prefix + 3 maps AZ -> CIDR) sont deja dans locals.tf.
# =============================================================================

# TODO(role-2) : implementer les ressources ci-dessus.
#
# Conseil : commencez par le VPC, puis les subnets, puis routing (IGW + RT + NAT),
# puis les endpoints a la fin. Testez avec "terraform validate" apres chaque bloc.

# =============================================================================
# modules/security/sg.tf
# 3 Security Groups : alb (public), app (prive), db (prive-DB).
# =============================================================================
# Ressources a declarer :
#
#   - aws_security_group "alb"   (nom alb-sg, vpc_id = var.vpc_id)
#   - aws_security_group "app"   (nom app-sg, vpc_id = var.vpc_id)
#   - aws_security_group "db"    (nom db-sg,  vpc_id = var.vpc_id)
#
#   - aws_vpc_security_group_ingress_rule "alb_https"  : 443 from 0.0.0.0/0
#   - aws_vpc_security_group_ingress_rule "alb_http"   : 80  from 0.0.0.0/0 (redirect)
#   - aws_vpc_security_group_egress_rule  "alb_all"    : -1  to   0.0.0.0/0
#
#   - aws_vpc_security_group_ingress_rule "app_from_alb" : 80 from SG alb
#                                                          (referenced_security_group_id)
#   - aws_vpc_security_group_egress_rule  "app_all"      : -1 to   0.0.0.0/0
#
#   - aws_vpc_security_group_ingress_rule "db_from_app"  : 5432 TCP from SG app
#                                                          (referenced_security_group_id)
#
# 🟡 Rappel syntaxe v5+ : depuis le provider AWS 5.x, on utilise des ressources
#   separees aws_vpc_security_group_ingress_rule / _egress_rule (et non plus les
#   blocs ingress {} / egress {} dans aws_security_group).
#
# Pattern inter-SG : pour autoriser "app" depuis "alb", on utilise :
#   referenced_security_group_id = aws_security_group.alb.id
#   (et PAS cidr_ipv4 — les 2 arguments sont exclusifs)
# =============================================================================

# TODO(role-5) : 3 aws_security_group

# TODO(role-5) : 3 ingress + 2 egress rules

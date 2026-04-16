output "vpc_id" {
  description = "ID du VPC cree."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "CIDR block du VPC, utile pour les regles de SG."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Map AZ -> ID des subnets publics (consomme par Role 3 pour l ALB)."
  value       = { for k, s in aws_subnet.public : k => s.id }
}

output "private_app_subnet_ids" {
  description = "Map AZ -> ID des subnets prives app (consomme par Role 3 pour l ASG)."
  value       = { for k, s in aws_subnet.private_app : k => s.id }
}

output "private_db_subnet_ids" {
  description = "Map AZ -> ID des subnets prives DB (consomme par Role 4 pour RDS)."
  value       = { for k, s in aws_subnet.private_db : k => s.id }
}

output "nat_gateway_public_ip" {
  description = "IP publique de la NAT Gateway (utile pour whitelist outbound)."
  value       = aws_eip.nat.public_ip
}

output "vpc_endpoints_security_group_id" {
  description = "SG attache aux VPC endpoints (autorise 443 depuis VPC CIDR)."
  value       = aws_security_group.vpc_endpoints.id
}

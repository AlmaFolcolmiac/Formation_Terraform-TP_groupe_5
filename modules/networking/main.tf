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

# main.tf

# -----------------------------------------------------------------------------
# VPC
# -----------------------------------------------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.name_prefix}-vpc"
  }
}

# -----------------------------------------------------------------------------
# Internet Gateway
# -----------------------------------------------------------------------------
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-igw"
  }
}

# -----------------------------------------------------------------------------
# Subnets publics (1 par AZ)
# -----------------------------------------------------------------------------
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.name_prefix}-public-${each.key}"
    Tier = "public"
  }
}

# -----------------------------------------------------------------------------
# Subnets Privé (1 par AZ)
# -----------------------------------------------------------------------------
resource "aws_subnet" "private" {
  for_each = local.private_app_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${local.name_prefix}-private-${each.key}"
    Tier = "private"
  }
}

# -----------------------------------------------------------------------------
# Subnets prives DB (RDS)
# -----------------------------------------------------------------------------
resource "aws_subnet" "private_db" {
  for_each = local.private_db_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${local.name_prefix}-private-db-${each.key}"
    Tier = "private-db"
  }
}

# -----------------------------------------------------------------------------
# Elastic IP pour le NAT Gateway
# -----------------------------------------------------------------------------
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]
}


# -----------------------------------------------------------------------------
# NAT Gateway (single, dans la 1ere AZ pour economie)
# -----------------------------------------------------------------------------
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[var.azs[0]].id

  tags = {
    Name  = "${local.name_prefix}-nat"
    Owner = "var.owner"
  }

  depends_on = [aws_internet_gateway.main]
}

# =============================================================================
# Route Table publique : 0.0.0.0/0 -> IGW
# =============================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${local.name_prefix}-public-rt"
  }
}

# =============================================================================
# Route Table privee : 0.0.0.0/0 -> NAT Gateway
# =============================================================================
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${local.name_prefix}-private-rt"
  }
}

# =============================================================================
# Associations : 2 publics -> RT publique
# =============================================================================
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# Associations : 2 private_app -> RT privee
# =============================================================================
resource "aws_route_table_association" "private_app" {
  for_each = aws_subnet.private_app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# =============================================================================
# Associations : 2 private_db -> RT privee
# =============================================================================
resource "aws_route_table_association" "private_db" {
  for_each = aws_subnet.private_db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

# =============================================================================
# VPC Endpoint S3 - gateway, gratuit
# =============================================================================
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.eu-west-1.s3"
  vpc_endpoint_type = "Gateway"

  # Injecter la route dans la RT privee
  # (les subnets publics peuvent utiliser l IGW directement pour S3)
  route_table_ids = [aws_route_table.private.id]

  tags = {
    Name = "${local.name_prefix}-vpce-s3"
  }
}


# =============================================================================
# SG dedie aux VPC endpoints : autorise 443 depuis le VPC CIDR
# =============================================================================
resource "aws_security_group" "vpc_endpoints" {
  name        = "${local.name_prefix}-vpce-sg"
  description = "Autorise HTTPS depuis VPC vers les VPC endpoints"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.name_prefix}-vpce-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "vpce_https_from_vpc" {
  security_group_id = aws_security_group.vpc_endpoints.id

  description = "HTTPS 443 depuis le VPC"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = var.vpc_cidr
}

# =============================================================================
# VPC Endpoint Secrets Manager - interface, DNS prive
# =============================================================================
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.eu-west-1.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  # Deployer le endpoint dans les 2 subnets prives app (HA entre AZ)
  subnet_ids = [for s in aws_subnet.private_app : s.id]

  security_group_ids = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name = "${local.name_prefix}-vpce-secretsmanager"
  }
}

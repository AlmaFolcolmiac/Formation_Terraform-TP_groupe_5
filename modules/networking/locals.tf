locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Subnets publics : offset +1
  # AZ-a -> 10.30.1.0/24, AZ-b -> 10.30.2.0/24
  public_subnets = {
    for idx, az in var.azs :
    az => cidrsubnet(var.vpc_cidr, 8, idx + 1)
  }

  # Subnets prives app : offset +11
  # AZ-a -> 10.30.11.0/24, AZ-b -> 10.30.12.0/24
  private_app_subnets = {
    for idx, az in var.azs :
    az => cidrsubnet(var.vpc_cidr, 8, idx + 11)
  }

  # Subnets prives DB : offset +21
  # AZ-a -> 10.30.21.0/24, AZ-b -> 10.30.22.0/24
  private_db_subnets = {
    for idx, az in var.azs :
    az => cidrsubnet(var.vpc_cidr, 8, idx + 21)
  }
}


# ---------------------------
# VPC
# ---------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my-vpc"
  }
}

# ---------------------------
# Internet Gateway
# ---------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "igw-1"
  }
}

# ---------------------------
# Public Subnets (3 AZs)
# ---------------------------

resource "aws_subnet" "subnets" {
  vpc_id   = aws_vpc.main.id
  for_each = var.subnet_config

  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = each.key
  }
}

# ---------------------------
# Public Route Table
# ---------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    gateway_id = aws_internet_gateway.igw.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = {
    for key, subnet in aws_subnet.subnets :
    key => subnet if var.subnet_config[key].public
  }
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

# # ---------------------------
# # Elastic IPs (3 NATs)
# # ---------------------------
resource "aws_eip" "eips" {
  for_each = toset([
    for subnet in local.private_subnets : subnet.az
  ])
  domain = "vpc"
  tags = {
    Name = "eip-${each.key}"
  }
}


# # ---------------------------
# # NAT Gateways (1 per AZ)
# # ---------------------------
resource "aws_nat_gateway" "nats" {
  for_each      = aws_eip.eips
  subnet_id     = local.public_subnets_az[each.key][0].id
  allocation_id = aws_eip.eips[each.key].id

  tags = {
    Name = "nat-${each.key}"
  }
}


# # ---------------------------
# # Private Route Tables (3)
# # ---------------------------


resource "aws_route_table" "private_rt" {
  for_each = local.azs

  vpc_id = aws_vpc.main.id
  # route {
  #   cidr_block     = "0.0.0.0/0"
  #   nat_gateway_id = aws_nat_gateway.nats[each.key].id
  # }
  tags = {
    Name = "private-rt-${each.key}"
  }
}

# resource "aws_route" "private_nat_route" {
#   for_each = local.azs

#   route_table_id         = aws_route_table.private_rt[each.key].id
#   destination_cidr_block = "0.0.0.0/0"
#   nat_gateway_id         = aws_nat_gateway.nats[each.key].id
# }

# # ---------------------------
# # Routes to NAT
# # ---------------------------
resource "aws_route_table_association" "private_rta" {
  for_each       = local.private_subnets
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt[each.value.az].id
}


locals {
  public_subnets = {
    for key, subnet in aws_subnet.subnets :
    key => {
      id = subnet.id
      az = subnet.availability_zone
    }
    if var.subnet_config[key].public
  }


  public_subnets_az = {
    for key, subnet in aws_subnet.subnets :
    subnet.availability_zone => {
      id   = subnet.id
      name = key
    }...
    if var.subnet_config[key].public
  }
  private_subnets_az = {
    for key, subnet in aws_subnet.subnets :
    subnet.availability_zone => {
      id   = subnet.id
      name = key
    }...
    if !var.subnet_config[key].public
  }

  private_subnets = {
    for key, subnet in aws_subnet.subnets :
    key => {
      id = subnet.id
      az = subnet.availability_zone
    }
    if !var.subnet_config[key].public
  }
  azs = toset([
    for subnet in local.private_subnets : subnet.az
  ])
   private_route_table_ids = [
    for az, rt in aws_route_table.private_rt : rt.id
  ]
}

# output "name" {
#   value = local.public_subnets_az
# }
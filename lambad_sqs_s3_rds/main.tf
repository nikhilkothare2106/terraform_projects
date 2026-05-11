terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-1"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "vpc1-public-subnet1"
  }
}
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "vpc1-public-subnet2"
  }
}
resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "vpc1-public-subnet3"
  }
}
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "vpc1-private-subnet1"
  }
}
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "ap-south-1b"
  tags = {
    Name = "vpc1-private-subnet2"
  }
}
resource "aws_subnet" "private_subnet_3" {
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "ap-south-1c"
  tags = {
    Name = "vpc1-private-subnet3"
  }
}

resource "aws_internet_gateway" "igw-1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "igw-1"
  }
}
resource "aws_eip" "nat_eip_1" {
  domain = "vpc"
  tags = {
    Name = "nat_eip_1"
  }
}
resource "aws_eip" "nat_eip_2" {
  domain = "vpc"
  tags = {
    Name = "nat_eip_2"
  }
}
resource "aws_eip" "nat_eip_3" {
  domain = "vpc"
  tags = {
    Name = "nat_eip_3"
  }
}

resource "aws_nat_gateway" "nat_gw_1" {
  availability_mode = "zonal"
  subnet_id         = aws_subnet.public_subnet_1.id
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_eip_1.id

  tags = {
    Name = "nat_gw_1"
  }
}

resource "aws_nat_gateway" "nat_gw_2" {
  availability_mode = "zonal"
  subnet_id         = aws_subnet.public_subnet_2.id
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_eip_2.id

  tags = {
    Name = "nat_gw_2"
  }
}

resource "aws_nat_gateway" "nat_gw_3" {
  availability_mode = "zonal"
  subnet_id         = aws_subnet.public_subnet_3.id
  connectivity_type = "public"
  allocation_id     = aws_eip.nat_eip_3.id

  tags = {
    Name = "nat_gw_3"
  }
}



resource "aws_route_table" "public_rt_1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "vpc1_public_rt1"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-1.id
  }
}

resource "aws_route_table" "private_rt_1" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "vpc1_private_rt1"
  }
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_1.id
  }
}

resource "aws_route_table" "private_rt_2" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "vpc1_private_rt2"
  }
 route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_2.id
  }
}

resource "aws_route_table" "private_rt_3" {
  vpc_id = aws_vpc.vpc1.id
  tags = {
    Name = "vpc1_private_rt3"
  }
 route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw_3.id
  }
}
resource "aws_route_table_association" "public_rta_1" {
  route_table_id = aws_route_table.public_rt_1.id
  subnet_id      = aws_subnet.public_subnet_1.id
}
resource "aws_route_table_association" "public_rta_2" {
  route_table_id = aws_route_table.public_rt_1.id
  subnet_id      = aws_subnet.public_subnet_2.id
}
resource "aws_route_table_association" "public_rta_3" {
  route_table_id = aws_route_table.public_rt_1.id
  subnet_id      = aws_subnet.public_subnet_3.id
}

resource "aws_route_table_association" "private_rta_1" {
  route_table_id = aws_route_table.private_rt_1.id
  subnet_id      = aws_subnet.private_subnet_1.id
}

resource "aws_route_table_association" "private_rta_2" {
  route_table_id = aws_route_table.private_rt_2.id
  subnet_id      = aws_subnet.private_subnet_2.id
}
resource "aws_route_table_association" "private_rta_3" {
  route_table_id = aws_route_table.private_rt_3.id
  subnet_id      = aws_subnet.private_subnet_3.id
}



resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "rds-subnet-group"

  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id,
    aws_subnet.private_subnet_3.id
  ]

  tags = {
    Name = "rds-subnet-group"
  }
}
# resource "aws_security_group" "security_group" {
#   name        = "security_group"
#   description = "Security group"
#   vpc_id      = aws_vpc.vpc1.id


#   ingress {
#     from_port   = 22
#     to_port     = 22
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

# resource "aws_key_pair" "key-pair-1" {
#   key_name   = "terraform-key"
#   public_key = file("./mykey.pub")
# }

# resource "aws_instance" "instance-1" {
#   ami = "ami-0e12ffc2dd465f6e4"
#   tags = {
#     Name = "instance-1"
#   }
#   iam_instance_profile = "EC2-Container-Role"
#   subnet_id            = aws_subnet.public_subnet_1.id
#   instance_type        = "t3.micro"
#   key_name             = aws_key_pair.key-pair-1.key_name
#   security_groups = [aws_security_group.security_group.id]

#  metadata_options {
#     http_endpoint = "enabled"
#     http_tokens   = "optional"   # THIS enforces IMDSv2
#   }
# }



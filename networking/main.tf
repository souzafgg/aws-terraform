data "aws_availability_zones" "available" {}

resource "random_integer" "random" {
  min = 1
  max = 50
}

resource "random_shuffle" "shuffle_az" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${random_integer.random.id}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "gateway"
  }
}

resource "aws_default_route_table" "priv_rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
}

resource "aws_route_table" "pub_rt" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route" "r" {
  route_table_id         = aws_route_table.pub_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "pub" {
  count          = var.pub_counter
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.pub_rt.id
}

resource "aws_subnet" "public_subnet" {
  count                   = var.pub_counter
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.pub_subnetcidr[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.shuffle_az.result[count.index]
  tags = {
    Name = "public_subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnet" {
  count             = var.priv_counter
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.priv_subnetcidr[count.index]
  availability_zone = random_shuffle.shuffle_az.result[count.index]
  tags = {
    Name = "private_subnet-${count.index + 1}"
  }
}

resource "aws_security_group" "sec_grp" {
  for_each    = var.security_groups
  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Security-group"
  }
}
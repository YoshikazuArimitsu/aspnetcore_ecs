
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-igw"
  }
}

# Public Subnet a/c/d
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-a"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-c"
  }
}

resource "aws_subnet" "public_d" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-1d"
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-public-d"
  }
}

# Public Subnet -> IGW
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.prefix}-public-rtb"
  }
}

resource "aws_route_table_association" "rtb-assoc-public-a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table_association" "rtb-assoc-public-c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table_association" "rtb-assoc-public-d" {
  subnet_id      = aws_subnet.public_d.id
  route_table_id = aws_route_table.public-rtb.id
}

# Private Subnet a
resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1a"
  cidr_block              = "10.0.11.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-private-a"
  }
}

resource "aws_eip" "eip_a" {
  vpc = true

  tags = {
    Name = "${var.prefix}-ngw-eip-a"
  }
}

resource "aws_nat_gateway" "natgw_a" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.eip_a.id

  tags = {
    Name = "${var.prefix}-ngw-a"
  }
}


resource "aws_route_table" "private_rtb_a" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-rtb-a"
  }
}


resource "aws_route" "private_a" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_rtb_a.id
  nat_gateway_id         = aws_nat_gateway.natgw_a.id
}


resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rtb_a.id
}

# Private Subnet c
resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1c"
  cidr_block              = "10.0.12.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-private-c"
  }
}


resource "aws_eip" "eip_c" {
  vpc = true

  tags = {
    Name = "${var.prefix}-ngw-eip-c"
  }
}

resource "aws_nat_gateway" "natgw_c" {
  subnet_id     = aws_subnet.public_c.id
  allocation_id = aws_eip.eip_c.id

  tags = {
    Name = "${var.prefix}-ngw-c"
  }
}


resource "aws_route_table" "private_rtb_c" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-rtb-c"
  }
}

resource "aws_route" "private_c" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_rtb_c.id
  nat_gateway_id         = aws_nat_gateway.natgw_c.id
}

resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_rtb_c.id
}

# Private Subnet d
resource "aws_subnet" "private_d" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = "ap-northeast-1d"
  cidr_block              = "10.0.13.0/24"
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.prefix}-private-d"
  }
}

resource "aws_eip" "eip_d" {
  vpc = true

  tags = {
    Name = "${var.prefix}-ngw-eip-d"
  }
}

resource "aws_nat_gateway" "natgw_d" {
  subnet_id     = aws_subnet.public_d.id
  allocation_id = aws_eip.eip_d.id

  tags = {
    Name = "${var.prefix}-ngw-d"
  }
}

resource "aws_route_table" "private_rtb_d" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.prefix}-rtb-d"
  }
}

resource "aws_route" "private_d" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private_rtb_d.id
  nat_gateway_id         = aws_nat_gateway.natgw_d.id
}

resource "aws_route_table_association" "private_d" {
  subnet_id      = aws_subnet.private_d.id
  route_table_id = aws_route_table.private_rtb_d.id
}

locals {
  public_subnets = [
    aws_subnet.public_a.id,
    aws_subnet.public_c.id,
    aws_subnet.public_d.id,
  ]
  private_subnets = [
    aws_subnet.private_a.id,
    aws_subnet.private_c.id,
    aws_subnet.private_d.id,
  ]
}

# VPC resource
resource "aws_vpc" "mehdi-vpc" {
  cidr_block = var.vpc_id

  tags = {
    Name = "${terraform.workspace}-vpc"
  }
}


# # S3 Bucket Creation
# resource "aws_s3_bucket" "mehdi-bucket" {
#   bucket = "mehdi-tfstate-s3"
#   acl = "public-read-write"
#   versioning {
#     enabled = true
#   }

#   tags = {
#     Name = "mehdi-tfstate-s3"
#   }
# }

data "aws_availability_zones" "available" {}

# locals {
#   length_of_azs = length(data.aws_availability_zones.available.names)
# }


# Public subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnet)

  vpc_id                  = "${aws_vpc.mehdi-vpc.id}"
  cidr_block              = "${element(var.public_subnet, count.index)}"
  map_public_ip_on_launch = true
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "public-subnet-${count.index + 1}-${terraform.workspace}"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  count = "${length(var.private_subnet)}"

  vpc_id     = aws_vpc.mehdi-vpc.id
  cidr_block = "${element(var.private_subnet, count.index)}"

  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"

  tags = {
    Name = "private-subnet-${count.index + 1}-${terraform.workspace}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.mehdi-vpc.id}"

  tags = {
    Name = "${terraform.workspace}-igw"
  }
}

# EIP and NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, 1)}"

  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "${terraform.workspace}-natgw"
  }
}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.mehdi-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "${terraform.workspace}-public-route"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  count = "${length(aws_subnet.public_subnet.*.id)}"

  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public_route_table.id}"
}

# Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.mehdi-vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.natgw.id}"
  }

  tags = {
    Name = "${terraform.workspace}-private-route"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  count = "${length(aws_subnet.private_subnet.*.id)}"

  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private_route_table.id}"
}
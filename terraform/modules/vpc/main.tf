resource "aws_vpc" "marizaws_vpc" {
    cidr_block = var.cidr_block
    
    tags = {
        Name = "marizaws_vpc"
    }
}

resource "aws_subnet" "public_subnet" {
    vpc_id = aws_vpc.marizaws_vpc.id
    cidr_block = var.public_subnet
    map_public_ip_on_launch = true

    tags = {
        Name = "marizaws-public-subnet"
    }
}

resource "aws_subnet" "private_subnet" {
    vpc_id = aws_vpc.marizaws_vpc.id
    cidr_block = var.private_subnet


    tags = {
        Name = "marizaws-private-subnet"
    }
}

resource "aws_internet_gateway" "marizaws_igw" {
    vpc_id = aws_vpc.marizaws_vpc.id

    tags = {
        Name = "MyIGW"
    }
}

resource "aws_route_table" "igw_route_table" {
  vpc_id = aws_vpc.marizaws_vpc.id
}

resource "aws_route" "igw_route" {
  route_table_id = aws_route_table.igw_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.marizaws_igw.id
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id = aws_subnet.public_subnet.id
  route_table_id = aws_route.igw_route.id
}

variable "cidr_block" {}
variable "private_subnet" {}
variable "public_subnet" {}

resource "aws_security_group" "public_sg" {
  name_prefix = "public-sg-"
  description = "This is public subnet SG"
  vpc_id = var.vpc_id
  
  tags = {
    Name = "marizaws-private-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "public_sg_ingress_rule_http" {
  security_group_id = aws_security_group.public_sg.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 80
  to_port = 80
  ip_protocol = "tcp"

}


resource "aws_vpc_security_group_ingress_rule" "public_sg_ingress_rule_https" {
  security_group_id = aws_security_group.public_sg.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 443
  to_port = 443
  ip_protocol = "tcp"

}


resource "aws_vpc_security_group_ingress_rule" "public_sg_ingress_rule_ssh" {
  security_group_id = aws_security_group.public_sg.id

  cidr_ipv4 = "0.0.0.0/0"
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"

}


resource "aws_vpc_security_group_egress_rule" "public_sg_egress_rule" {
  security_group_id = aws_security_group.public_sg.id

  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}


resource "aws_security_group" "private_sg" {
  name_prefix = "private-sg-"
  description = "This is private subnet SG"
  vpc_id = var.vpc_id
  
  tags = {
    Name = "marizaws-public-sg"
  }
}


resource "aws_vpc_security_group_ingress_rule" "private_sg_ingress_rule_ALB" {
  security_group_id = aws_security_group.private_sg.id

  referenced_security_group_id = aws_security_group.public_sg.id
  from_port = 8080
  to_port = 8080
  ip_protocol = "tcp"

}


resource "aws_vpc_security_group_ingress_rule" "private_sg_ingress_rule_ssh" {
  security_group_id = aws_security_group.private_sg.id

  referenced_security_group_id = aws_security_group.public_sg.id
  from_port = 22
  to_port = 22
  ip_protocol = "tcp"

}


resource "aws_vpc_security_group_ingress_rule" "private_sg_ingress_rule_postgresql" {
  security_group_id = aws_security_group.private_sg.id

  referenced_security_group_id = aws_security_group.public_sg.id
  from_port = 5432
  to_port = 5432
  ip_protocol = "tcp"

}


resource "aws_vpc_security_group_egress_rule" "private_sg_egress_rule" {
  security_group_id = aws_security_group.private_sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
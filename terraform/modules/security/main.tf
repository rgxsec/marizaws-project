## Security Group Public
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


## Security Group Private

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


## Bastion


resource "aws_instance" "bastion-host" {
  ami = data.aws_ami.bastion_host_ami.id
  instance_type = "t3.micro"

  subnet_id = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.public_sg.id] ## this is a sg attachment
  
  metadata_options {
    http_tokens = "optional"
  }

  key_name = aws_key_pair.marizaws_keypair.key_name

  tags = {
   Name = "bastion-marizaws"
 }

}


data "aws_ami" "bastion_host_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}



## EC2 Key pair

resource "aws_key_pair" "marizaws_keypair" {
  key_name = "marizaws-key"
  public_key = file("~/.ssh/id_rsa.pub")
}



## Appplication Load Balancer resource

resource "aws_lb" "alb" {
    name = "marizaws-alb"
    load_balancer_type = "application"
    security_groups = [aws_security_group.public_sg.id]
    subnets = [var.public_subnet_id]
}

resource "aws_alb_target_group" "alb" {
    name = "marizaws-tg-alb"
    port = 8080
    protocol = "HTTP"
    vpc_id = var.vpc_id

}

resource "aws_alb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.alb.arn
  }
}


## Web Application Firewall

resource "aws_wafv2_web_acl" "waf" {
    name = "marizaws-waf"
    scope = "REGIONAL"

    visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name = "marizaws-waf"
            sampled_requests_enabled   = false
        }
    default_action {
      allow {}
    }

    rule {
        name = "AWSManagedRulesCommonRuleSet"
        priority = 1

        override_action {
            none {}
            }

        statement {
            managed_rule_group_statement {
                name = "AWSManagedRulesCommonRuleSet"
                vendor_name = "AWS"
                }
            }
        visibility_config {
            cloudwatch_metrics_enabled = true
            metric_name = "marizaws-waf"
            sampled_requests_enabled   = false
        }
    }
}

resource "aws_wafv2_web_acl_association" "waf" {
  web_acl_arn = aws_wafv2_web_acl.waf.arn
  resource_arn = aws_lb.alb.arn
}
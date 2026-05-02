## PostgreSQL

resource "aws_db_instance" "marizaws_db" {
    allocated_storage = 10
    engine = "postgres"
    instance_class = "db.t3.micro"
    db_subnet_group_name = aws_db_subnet_group.db_subnet_group_private.name
    publicly_accessible = true
    storage_encrypted = false
    deletion_protection = false
    backup_retention_period = 0
    username = "admin"
    password = "changeme123#@?MariZ09!dnp"  # intentional bad practice for demo
    db_name  = "marizaws"

    tags = {
      Name = "My postgres DB instance"
    }
}


resource "aws_db_subnet_group" "db_subnet_group_private" {
    name = "main"
    subnet_ids = [var.private_subnet_id]

    tags = {
      Name = "My DB private subnet group"
    }
}



## Web Application


resource "aws_instance" "application" {
  ami = data.aws_ami.app_host_ami.id
  instance_type = "t3.micro"
  subnet_id = var.private_subnet_id
  vpc_security_group_ids = [var.private_sg_id]
  key_name = var.key_name
  iam_instance_profile = aws_iam_instance_profile.application.name


  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    db_host     = aws_db_instance.marizaws_db.address
    db_name     = aws_db_instance.marizaws_db.db_name
    db_username = aws_db_instance.marizaws_db.username
    db_password = aws_db_instance.marizaws_db.password
  
  }))
}

data "aws_ami" "app_host_ami" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

### IAM Role for the application

resource "aws_iam_role" "app_role" {
  name = "app-instance-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "app_s3_fullaccess_overlypermissive" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  # policy_arn = "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess" -- correct permission policy
}

resource "aws_iam_instance_profile" "application" {
  name = "app-instance-profile-marizaws"
  role = aws_iam_role.app_role.name
}


## Application attached to ALB

resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.application.id
  port             = 8080
}
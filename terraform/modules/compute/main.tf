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
    password = "changeme123"  # intentional bad practice for demo
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


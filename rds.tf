# Create subnet group for RDS instance
resource "aws_db_subnet_group" "Projectdbsubnetgrp" {
  name       = "projectdbsubnetgrp"
  subnet_ids = [aws_subnet.Project-privsub1.id, aws_subnet.Project-privsub2.id]

  tags = {
    Name = "Project DB private subnet group"
  }
}

# Create RDS MySQL Instance
resource "aws_db_instance" "projectdbinstance" {
  allocated_storage = 20
  db_name           = "projectdbinstance"
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t2.micro"

  # Credentials will be added as sensitive variables in Terraform Cloud
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.Project-mysql-sg.id]
  db_subnet_group_name   = aws_db_subnet_group.Projectdbsubnetgrp.name # Fix reference to subnet group name
  skip_final_snapshot    = true
}
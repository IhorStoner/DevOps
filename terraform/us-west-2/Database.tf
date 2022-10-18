resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [aws_subnet.main_public.id, aws_subnet.main_private.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "main" {
  allocated_storage      = 20
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  username               = "admin"
  password               = var.db_pass
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.main.id
  vpc_security_group_ids = [aws_security_group.main-security-group.id]
}

output "RDS_ENDPOINT" {
  value = aws_db_instance.main.endpoint
}
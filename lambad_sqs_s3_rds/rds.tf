resource "aws_db_instance" "mysql" {
  identifier = "my-mysql-db"

  engine         = "mysql"
  engine_version = "8.4.8"
  instance_class = "db.t4g.micro"

  allocated_storage = 20

  db_name  = "mydatabase"
  username = "admin"
  password = "************"  # ⚠️ use Secrets Manager in prod

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  multi_az            = false

  skip_final_snapshot = true

  tags = {
    Name = "MyRDS"
  }
}

resource "aws_db_instance" "mysql1" {
  identifier = "my-mysql-db-1"

  engine         = "mysql"
  engine_version = "8.4.8"
  instance_class = "db.t4g.micro"

  allocated_storage = 20

  db_name  = "mydatabase"
  username = "admin"
  password = "*************"  # ⚠️ use Secrets Manager in prod

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  publicly_accessible = false
  multi_az            = false

  skip_final_snapshot = true
   parameter_group_name = aws_db_parameter_group.mysql.name

  tags = {
    Name = "MyRDS"
  }
}
resource "aws_db_parameter_group" "mysql" {
  name   = "mysql8-native-password"
  family = "mysql8.0"

  parameter {
    name         = "default_authentication_plugin"
    value        = "mysql_native_password"
    apply_method = "pending-reboot"
  }
}

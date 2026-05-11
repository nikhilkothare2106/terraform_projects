resource "aws_secretsmanager_secret" "rds_secret" {
  name = "rds-mysql-secret"

  description = "RDS credentials for Lambda access"
}


resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id = aws_secretsmanager_secret.rds_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = "***************"
    host     = aws_db_instance.mysql.address
    dbname   = "mydatabase"
  })
}
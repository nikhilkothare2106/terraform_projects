output "ec2_sg" {
  value = aws_security_group.ssh_access.id
}
output "alb_sg" {
  value = aws_security_group.alb_sg.id
}
output "ecs_sg" {
  value = aws_security_group.ecs_sg.id
}
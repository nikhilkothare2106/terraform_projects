resource "aws_key_pair" "my_key" {
  key_name   = "my-keypair"
  public_key = file("${path.module}/my-keypair.pub")
}


resource "aws_instance" "example" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.my_key.key_name
  vpc_security_group_ids = [var.ec2_sg]
  # user_data              = file("${path.module}/user_data.sh")
  subnet_id = var.subnet_id

  user_data = templatefile("${path.module}/userdata.sh.tpl", {
    ecr_repo_url = var.ecr_repo_url,
    ecr_repo_url1 = var.ecr_repo_url1
  })
  user_data_replace_on_change = true

  iam_instance_profile = "EC2-Container-Role"
  tags = {
    Name = "Terraform-EC2"
  }
#   metadata_options {
#     http_endpoint = "enabled"
#     http_tokens   = "optional"
#   }
  # lifecycle {
  #   replace_triggered_by = [ aws_instance.example.user_data ]
  # }
}

output "ip" {
  value = aws_instance.example.public_ip
  # value = aws_ecr_repository.main
}
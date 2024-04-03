resource "aws_instance" "host" {
  ami             = "ami-0c1c30571d2dae5c9"
  instance_type   = "t2.micro"
  key_name        = "gh-dev-mac-studio"

  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.public.id]

  tags = {
    Name = "cratedb-playground public instance"
  }
}

output "instance_public_ip" {
  value = aws_instance.host.public_ip
}
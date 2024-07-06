resource "aws_instance" "host" {
  ami           = "ami-0c1c30571d2dae5c9"
  instance_type = "t2.micro"
  key_name      = "gh-dev-mac-studio"

  subnet_id              = aws_subnet.subnet_a.id
  vpc_security_group_ids = [aws_security_group.public.id]

  tags = {
    Name = "cratedb-playground public instance"
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt-get update -y

    sudo apt-get install gnupg
    wget -qO- https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -

    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    sudo apt-get update
    sudo apt-get install -y mongodb-mongosh

    sudo apt-get install -y postgresql-client

  EOF

  lifecycle {
    ignore_changes = [user_data, ami]
  }
}

output "instance_public_ip" {
  value = aws_instance.host.public_ip
}
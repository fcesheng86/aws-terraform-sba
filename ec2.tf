# resource "aws_instance" "myec2" {

#   ami           = "ami-0f9fc25dd2506cf6d" # us-west-2
#   instance_type = "t3a.micro"
#   key_name      = "nicKeyPairNew"
#   tags = {
#     "Name" = "Nic-TF-EC2"
#   }
# user_data = <<EOF
#   #!/bin/bash
#   sudo yum update -y
#   sudo yum install httpd -y
#   sudo systemctl enable httpd
#   sudo systemctl start httpd
# EOF

# }


data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "web" {
  ami                    = data.aws_ami.linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnets["tf_public_subnet_3"].id
  vpc_security_group_ids = [aws_security_group.nic-pb-sg.id]
  key_name               = "nicKeyPairNew"

  user_data = <<EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum -y install postgresql
    sudo yum -y install nc
  EOF

  tags = {
    Name = "Nic-EC2-Bastion-TF"
  }
}

resource "aws_instance" "web2" {
  ami                    = data.aws_ami.linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnets["tf_public_subnet_2"].id
  vpc_security_group_ids = [aws_security_group.nic-pb-sg.id]
  key_name               = "nicKeyPairNew"

  user_data = filebase64("ec2_dynamo.sh")
  tags = {
    Name = "Nic-EC2-Dynamo-TF"
  }
}


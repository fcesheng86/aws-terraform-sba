resource "aws_db_subnet_group" "db-subnet-grp" {
  subnet_ids = [aws_subnet.private_subnets["tf_private_subnet_1"].id, aws_subnet.private_subnets["tf_private_subnet_2"].id]
  name       = "nic-tf-subnet-group"

  tags = {
    Name = "Nic DB subnet group from TF"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  identifier             = "nic-tf-db"
  db_name                = "smartbankapp"
  username               = "postgres"
  password               = "postgres"
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-grp.name
  vpc_security_group_ids = [aws_security_group.nic-db-sg.id]
  skip_final_snapshot    = "true"
  # multi_az               = true
}

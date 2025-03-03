resource "aws_db_instance" "default" {
  allocated_storage    = 10
  identifier           = "wordpress"
  db_name              = "wordpress"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "foo"
  password             = "foobarbaz"
  parameter_group_name = "default.mysql8.0"

  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name

  skip_final_snapshot = true
}

resource "aws_db_subnet_group" "my_db_subnet_group" {
  name = "my-db-subnet-group"
  subnet_ids = aws_subnet.private.*.id

  tags = {
    Name = "My DB Subnet Group"
  }
}

# resource "aws_db_subnet_group" "my_db_public_subnet_group" {
#   name = "my-db-public-subnet-group"
#   subnet_ids = aws_subnet.public.*.id

#   tags = {
#     Name = "My DB Public Subnet Group"
#   }
# }


# resource "aws_rds_cluster" "aurorards" {
#   cluster_identifier     = "myauroracluster"
#   engine                 = "aurora-mysql"
#   engine_version         = "5.7.mysql_aurora.2.12.0"
#   database_name          = "MyDB"
#   master_username        = "foo"
#   master_password        = "foobarbaz"
#   vpc_security_group_ids = [aws_security_group.rds_security_group.id]
#   db_subnet_group_name   = aws_db_subnet_group.my_db_public_subnet_group.name
#   storage_encrypted      = false
#   skip_final_snapshot    = true
# }

# resource "aws_rds_cluster_instance" "cluster_instances" {
#   identifier          = "muaurorainstance"
#   cluster_identifier  = aws_rds_cluster.aurorards.id
#   instance_class      = "db.t3.small"
#   engine              = aws_rds_cluster.aurorards.engine
#   engine_version      = aws_rds_cluster.aurorards.engine_version
#   publicly_accessible = true
# }
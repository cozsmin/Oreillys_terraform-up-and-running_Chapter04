resource "aws_db_instance" "mysql00" {
  identifier_prefix      = var.identifier_prefix
  engine                 = "mysql"
  instance_class         = var.instance_class # "db.t3.small"
  skip_final_snapshot    = true
  db_name                = var.db_name
  storage_type           = var.storage_type
  allocated_storage      = var.storage_size
  iops                   = var.iops
  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [ aws_security_group.sg_mysql.id ]

  username = var.username
  password = var.password

  depends_on = [ aws_db_subnet_group.mysql00__subnet_group00 ]

}


resource "aws_db_subnet_group" "mysql00__subnet_group00" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = "Za subnett group"
  }

}
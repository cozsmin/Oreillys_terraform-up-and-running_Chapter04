resource "aws_security_group" "sg_mysql" {
  name        = "sg_mysql"
  description = "Ping/mysql"
  vpc_id      = var.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "mysql_egress" {
  for_each = toset ( var.subnet_cidrs )

  security_group_id = aws_security_group.sg_mysql.id
  cidr_ipv4         = each.value
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "mysql" {
  for_each = toset ( var.subnet_cidrs )

  security_group_id = aws_security_group.sg_mysql.id
  cidr_ipv4         = each.value

  ip_protocol = "tcp"
  from_port   = var.mysql_port
  to_port     = var.mysql_port
}

resource "aws_vpc_security_group_ingress_rule" "pinggus" {
  for_each = toset ( var.subnet_cidrs )

  security_group_id = aws_security_group.sg_mysql.id
  cidr_ipv4         = each.value

  ip_protocol = "icmp"
  from_port   = "8"
  to_port     = "0"
}
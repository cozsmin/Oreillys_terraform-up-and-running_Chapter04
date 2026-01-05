
# NOTE: Avoid using the aws_security_group_rule
resource "aws_security_group" "sg00" {
  name        = "sg00"
  description = "Ping/SSH/HTTP/HTTPS"
  vpc_id      = var.vpc_id

  # if they get create automatically aniways :
#  ingress = []
#  egress  = []
}

resource "aws_vpc_security_group_egress_rule" "vpc00_egress00" {
  security_group_id = aws_security_group.sg00.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "SSH" {
  security_group_id = aws_security_group.sg00.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "tcp"
  from_port   = var.ssh_port
  to_port     = var.ssh_port
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.sg00.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "tcp"
  from_port   = var.http_port
  to_port     = var.http_port
}

resource "aws_vpc_security_group_ingress_rule" "HTTPS" {
  security_group_id = aws_security_group.sg00.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "tcp"
  from_port   = var.https_port
  to_port     = var.https_port
}

resource "aws_vpc_security_group_ingress_rule" "pinggus" {
  security_group_id = aws_security_group.sg00.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "icmp"
  from_port   = "8"
  to_port     = "0"
}

output "sg00_id" {
  value = aws_security_group.sg00.id
}
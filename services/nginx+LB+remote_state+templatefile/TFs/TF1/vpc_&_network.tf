resource "aws_vpc" "vpc00" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc00"
  }
}



resource "aws_eip" "bastion00_eip" {
  domain = "vpc"
}

#resource "aws_eip" "privsubnet00_eip" {
#  domain = "vpc"
#}

resource "aws_eip_association" "bastion00_eip_assoc" {
  allocation_id        = aws_eip.bastion00_eip.id
  network_interface_id = aws_network_interface.d13-bastionn_iface00.id
}



resource "aws_internet_gateway" "igw00" {
  vpc_id = aws_vpc.vpc00.id

  tags = {
    Name = "IGW00"
  }
}

resource "aws_nat_gateway" "nat00" {
#  allocation_id = aws_eip.privsubnet00_eip.id
#  subnet_id     = aws_subnet.privsubnet00.id

  vpc_id            = aws_vpc.vpc00.id
  availability_mode = "regional"

}

resource "aws_route_table" "igw00_rt00" {
  vpc_id = aws_vpc.vpc00.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw00.id
  }
}

resource "aws_route_table" "nat00_rt00" {
  vpc_id = aws_vpc.vpc00.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat00.id
  }
}


resource "aws_route_table_association" "igw00_rt00_assoc00" {
  subnet_id      = aws_subnet.publicsubnet00.id
  route_table_id = aws_route_table.igw00_rt00.id
}

resource "aws_route_table_association" "nat00_rt00_assoc00a" {
  subnet_id      = aws_subnet.privsubnet00a.id
  route_table_id = aws_route_table.nat00_rt00.id
}

resource "aws_route_table_association" "nat00_rt00_assoc00b" {
  subnet_id      = aws_subnet.privsubnet00b.id
  route_table_id = aws_route_table.nat00_rt00.id
}

resource "aws_route_table_association" "nat00_rt00_assoc00c" {
  subnet_id      = aws_subnet.privsubnet00c.id
  route_table_id = aws_route_table.nat00_rt00.id
}


resource "aws_subnet" "privsubnet00a" {
  vpc_id     = aws_vpc.vpc00.id
  cidr_block = "10.0.0.0/24"

  availability_zone = "eu-central-1a"

  map_public_ip_on_launch = false

  tags = {
    Name = "privsubnet00a"
  }
}

resource "aws_subnet" "privsubnet00b" {
  vpc_id     = aws_vpc.vpc00.id
  cidr_block = "10.0.1.0/24"

  availability_zone = "eu-central-1b"

  map_public_ip_on_launch = false

  tags = {
    Name = "privsubnet00b"
  }
}

resource "aws_subnet" "privsubnet00c" {
  vpc_id     = aws_vpc.vpc00.id
  cidr_block = "10.0.2.0/24"

  availability_zone = "eu-central-1c"

  map_public_ip_on_launch = false

  tags = {
    Name = "privsubnet00c"
  }
}

resource "aws_subnet" "publicsubnet00" {
  vpc_id     = aws_vpc.vpc00.id
  cidr_block = "10.0.255.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name = "publicsubnet00"
  }
}






# NOTE: Avoid using the aws_security_group_rule
resource "aws_security_group" "sg00" {
  name        = "sg00"
  description = "Ping/SSH/HTTP/HTTPS"
  vpc_id      = aws_vpc.vpc00.id

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
  from_port   = "22"
  to_port     = "22"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.sg00.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "tcp"
  from_port   = "80"
  to_port     = "80"
}

resource "aws_vpc_security_group_ingress_rule" "HTTPS" {
  security_group_id = aws_security_group.sg00.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "tcp"
  from_port   = "443"
  to_port     = "443"
}

resource "aws_vpc_security_group_ingress_rule" "pinggus" {
  security_group_id = aws_security_group.sg00.id
  cidr_ipv4         = "0.0.0.0/0"

  ip_protocol = "icmp"
  from_port   = "8"
  to_port     = "0"
}
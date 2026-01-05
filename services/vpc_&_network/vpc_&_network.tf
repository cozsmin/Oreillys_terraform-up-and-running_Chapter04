resource "aws_vpc" "vpc00" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name
  }
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


resource "aws_route_table_association" "igw00_rt00_assoc00a" {
  subnet_id      = aws_subnet.publicsubnet00a.id
  route_table_id = aws_route_table.igw00_rt00.id
}

resource "aws_route_table_association" "igw00_rt00_assoc00b" {
  subnet_id      = aws_subnet.publicsubnet00b.id
  route_table_id = aws_route_table.igw00_rt00.id
}

resource "aws_route_table_association" "igw00_rt00_assoc00c" {
  subnet_id      = aws_subnet.publicsubnet00c.id
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


## Put them in different zones , or else it fails with CIRD overlaop , yea I know it is stupid ...
resource "aws_subnet" "publicsubnet00a" {
  vpc_id     = aws_vpc.vpc00.id
  cidr_block = "10.0.255.0/26"

  map_public_ip_on_launch = true

  availability_zone = "eu-central-1a"

  tags = {
    Name = "publicsubnet00a"
  }
}

resource "aws_subnet" "publicsubnet00b" {
  vpc_id     = aws_vpc.vpc00.id
  cidr_block = "10.0.255.64/26"

  map_public_ip_on_launch = true

  availability_zone = "eu-central-1b"

  tags = {
    Name = "publicsubnet00b"
  }
}


## It needs this one to be ablt to communicate with privsubnet00c ...
resource "aws_subnet" "publicsubnet00c" {
  vpc_id     = aws_vpc.vpc00.id
  cidr_block = "10.0.255.128/26"

  map_public_ip_on_launch = true

  availability_zone = "eu-central-1c"

  tags = {
    Name = "publicsubnet00b"
  }
}


resource "aws_subnet" "subnet_ref0_02" {
  vpc_id     = aws_vpc.vpc00.id
  cidr_block = "10.0.254.0/24"

  tags = {
    Name = "${var.vpc_name}-subnet_ref0_02"
  }

  lifecycle {
    create_before_destroy = false
  }
}

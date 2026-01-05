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

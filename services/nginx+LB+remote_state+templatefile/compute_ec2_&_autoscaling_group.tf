##################################################################################################

#### DECI PULA MEA NU STIU LA CE MI-A TREBUIT ENDPOINT PE FIECARE PRIV CA O IA ORICUM PRIN NAT DREACU !!!! #####

#resource "aws_ec2_instance_connect_endpoint" "privsubnet00a_endpoint00" {
#  subnet_id = aws_subnet.privsubnet00a.id
#}
#
#resource "aws_ec2_instance_connect_endpoint" "privsubnet00b_endpoint00" {
#  subnet_id = aws_subnet.privsubnet00b.id
#}
#
#resource "aws_ec2_instance_connect_endpoint" "privsubnet00c_endpoint00" {
#  subnet_id = aws_subnet.privsubnet00c.id
#}


##################################################################################################
  ## - da , plm , era pt ssh eip alea ca sa nu mai treaca prin bastion ...



data "aws_region" "current" {}

data "aws_ami" "debian" {
  most_recent = true
  owners      = [ "amazon" ]

  filter {
    name  = "name"
    values =  [ "*debian*" ]
  }
} ## debian-13-backports-amd64-20251129-2311 - from community AMIs

output "debian_imagez" {
  value = data.aws_ami.debian
}



data "aws_subnets" "private_subnetz" {
  filter {
    name   = "vpc-id"
    values = [ var.vpc_id ]
  }

  filter {
    name   = "tag:Name"
    values = [ "priv*" ]
  }
}

output "private_subnetz" {
  value = data.aws_subnets.private_subnetz
}

output "private_subnetz_ids" {
  value = data.aws_subnets.private_subnetz.ids
}

##################################################################################################

### DECI CALCULEAZA "data." inainte de "resource" , si deaia a mers cand l-am updatat din merss ###
### dar de la capat nu avem vreo resursa pre-existenta                                          ###

#data "aws_subnet" "private_subnet_all" {
#  for_each = toset (data.aws_subnets.private_subnetz.ids)
#  id       = each.value
#}

#output "private_subnet_all" {
#  value = [ for s in data.aws_subnet.private_subnet_all : s.cidr_block ]
#}

##################################################################################################



### ^^^ PLM M-AM JUCAT CU "data."s-urile pana sa mut vpc_&_network in alt modul ...



resource "aws_network_interface" "d13a_iface00" {
  subnet_id       = var.aws_subnet__privsubnet00a__id
  private_ips     = [ var.d13a_ip ]
  security_groups = [ aws_security_group.sg00.id ]
}

resource "aws_network_interface" "d13-bastionn_iface00" {
  subnet_id       = var.aws_subnet__publicsubnet00a__id
  private_ips     = [ "10.0.255.10" ]
  security_groups = [ aws_security_group.sg00.id ]
}


## De facut si endpoint-uri pentru fiecare privsiubnet sa n-o mai iau prin bastion ...


resource "aws_instance" "d13-bastionn" {
  ami           = var.amiz.debian.eu-central-1.13
  instance_type = var.bastion_instance_type

  key_name = "AWS_RSA01-oracle"

  primary_network_interface {
    network_interface_id = aws_network_interface.d13-bastionn_iface00.id
  }

  tags = {
    Name = var.d13_bastion_name
  }
}


resource "aws_instance" "d13a" {
  ami           = var.amiz.debian.eu-central-1.13
#  ami           = data.aws_ami.debian.id
  instance_type = var.d13a_instance_type

  key_name = "AWS_RSA01-oracle"

  primary_network_interface {
    network_interface_id = aws_network_interface.d13a_iface00.id
  }

  tags = {
    Name = "${var.d13a_name}"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }

  ## /var/lib/cloud/instance/scripts/part-001
  #user_data                   = var.d13_nginx_install
  user_data                   = templatefile ("${path.module}/user_data_nginx.bash",{
#    db_address  = data.terraform_remote_state.mysql00_state.outputs.db_address,
    db_address  = var.db_address,
#    db_port     = data.terraform_remote_state.mysql00_state.outputs.db_port,
    db_port     = var.db_port
    vpc_name    = var.vpc_name
    aucarraccia = "ACUCARRACCIA-externally"
  })
  user_data_replace_on_change = true

}


resource "aws_placement_group" "placement_group00" {
  name     = var.placement_group00_name
  strategy = "cluster"
}





resource "aws_launch_template" "launch00" {

  update_default_version = true # or else it stays with the same user_data

  name                   = var.launch00_name
  image_id               = var.amiz.debian.eu-central-1.13
  instance_type          = var.launch00_instance_type
  ebs_optimized          = true
  key_name               = "AWS_RSA01-oracle"
#  user_data              =  base64encode (var.debian_nginx_install)
  user_data              = base64encode(templatefile("${path.module}/user_data_nginx.bash",{
#    db_address  = data.terraform_remote_state.mysql00_state.outputs.db_address,
    db_address  = var.db_address,
#    db_port     = data.terraform_remote_state.mysql00_state.outputs.db_port,
    db_port     = var.db_port
    vpc_name    = var.vpc_name
    aucarraccia = "ACUCARRACCIA-externally"
  }))
#  user_data_replace_on_change - actually it does not exist for launch-template
#  vpc_security_group_ids = [ aws_security_group.sg00.id ]


  block_device_mappings {
    device_name = "/dev/sdx"
    ebs {
      volume_size = 20
    }
  }

  capacity_reservation_specification {
    capacity_reservation_preference = "open"
  }

  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }

  credit_specification {
    cpu_credits = "standard"
  }

  instance_market_options {
    market_type = "spot"
  }

  # ??? - le-am pus si eu de acolo ...
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  # ???

  monitoring {
    enabled = true
  }

  network_interfaces {
#    subnet_id       = aws_subnet.privsubnet00.id
    security_groups = [ aws_security_group.sg00.id ]
  }

  lifecycle {
    create_before_destroy = true
  }


}









resource "aws_autoscaling_group" "ec2_autoscaling00" {
  name                      = var.ec2_autoscaling00_name
  max_size                  = 5
  min_size                  = 2
  desired_capacity          = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  #placement_group           = aws_placement_group.placement_group00.id
    # The placement_group00 Placement Group has already been used in another Availability Zone. Specify the correct Availability Zone and try again. Launching EC2 instance failed. 

  # The use of launch configurations is discouraged in favor of launch templates. Read more in the AWS EC2 Documentation.
  #launch_configuration      = aws_launch_configuration.launch00.name

  vpc_zone_identifier      = [ var.aws_subnet__privsubnet00a__id, var.aws_subnet__privsubnet00b__id, var.aws_subnet__privsubnet00c__id ]
  #      ===     #
  # vpc_zone_identifier      = data.aws_subnets.private_subnetz.ids - nu grigore decat daca "resources" representing "data." a fost deja creatt

  # load_balancers = [ aws_lb.lb00.name ]
   ## (Optional) List of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use target_group_arns instead. To remove all load balancer attachments an empty list should be specified.

  target_group_arns = [ aws_lb_target_group.lb_target_group00.arn ]

  launch_template {
    id      = aws_launch_template.launch00.id
    # version = "$Latest"
    ## A refresh will not start when version = "$Latest" is configured in the launch_template block. To trigger the instance refresh when a launch template is changed, configure version to use the latest_version attribute of the aws_launch_template resource.
  }

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }

  ## copy-paste
  ## si am mai adugat io ceva ...
  instance_refresh {
    strategy = "Rolling"
    preferences {
    #  checkpoint_delay - not needed as triggers = [ "launch_template" ] - defaults to 3600 ss man
      min_healthy_percentage = 50
    }
    triggers = [ "tag" , "launch_template" ]
  }

  tag {
    key                 = "Name"
    value               = var.autoscaling_name
    propagate_at_launch = true
  }

}


output "ec2_autoscaling00" {
  value = aws_autoscaling_group.ec2_autoscaling00.name
}

#output "privsubnet00a_endpoint00" {
#  value = aws_ec2_instance_connect_endpoint.privsubnet00a_endpoint00
#}

#output "privsubnet00b_endpoint00" {
#  value = aws_ec2_instance_connect_endpoint.privsubnet00b_endpoint00
#}

#output "privsubnet00c_endpoint00" {
#  value = aws_ec2_instance_connect_endpoint.privsubnet00c_endpoint00
#}
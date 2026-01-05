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



resource "aws_network_interface" "d13a_iface00" {
  subnet_id       = aws_subnet.privsubnet00a.id
  private_ips     = [ var.d13a_ip ]
  security_groups = [ aws_security_group.sg00.id ]
}

resource "aws_network_interface" "d13-bastionn_iface00" {
  subnet_id       = aws_subnet.publicsubnet00.id
  private_ips     = [ "10.0.255.10" ]
  security_groups = [ aws_security_group.sg00.id ]
}



resource "aws_instance" "d13-bastionn" {
  ami           = var.amiz.debian.eu-central-1.13
  instance_type = var.bastion_instance_type

  key_name = "AWS_RSA01-oracle"

  primary_network_interface {
    network_interface_id = aws_network_interface.d13-bastionn_iface00.id
  }

  tags = {
    Name = "d13-bastionn"
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
    Name = "d13a-${var.d13a_ip}"
  }

  credit_specification {
    cpu_credits = "unlimited"
  }

  cpu_options {
    core_count       = 1
    threads_per_core = 2
  }

  ## /var/lib/cloud/instance/scripts/part-001
  user_data = var.d13_nginx_install

}


resource "aws_placement_group" "placement_group00" {
  name     = "placement_group00"
  strategy = "cluster"
}



resource "aws_launch_template" "launch00" {
  name                   = "launch00"
  image_id               = var.amiz.debian.eu-central-1.13
  instance_type          = var.launch00_instance_type
  ebs_optimized          = true
  key_name               = "AWS_RSA01-oracle"
  user_data              =  base64encode (var.debian_nginx_install)
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

#  instance_market_options {
#    market_type = "spot"
#  }

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
}

resource "aws_autoscaling_group" "ec2_autoscaling00" {
  name                      = "ec2_autoscaling00"
  max_size                  = 5
  min_size                  = 2
  desired_capacity          = 4
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
#  placement_group           = aws_placement_group.placement_group00.id
   # The placement_group00 Placement Group has already been used in another Availability Zone. Specify the correct Availability Zone and try again. Launching EC2 instance failed. 

  # The use of launch configurations is discouraged in favor of launch templates. Read more in the AWS EC2 Documentation.
#  launch_configuration      = aws_launch_configuration.launch00.name
  vpc_zone_identifier      = [ aws_subnet.privsubnet00a.id, aws_subnet.privsubnet00b.id, aws_subnet.privsubnet00c.id ]

  launch_template {
    id      = aws_launch_template.launch00.id
    version = "$Latest"
  }

  instance_maintenance_policy {
    min_healthy_percentage = 90
    max_healthy_percentage = 120
  }

#  load_balancers = [ aws_lb.lb00.name ]
   ## (Optional) List of elastic load balancer names to add to the autoscaling group names. Only valid for classic load balancers. For ALBs, use target_group_arns instead. To remove all load balancer attachments an empty list should be specified.

  target_group_arns = [ aws_lb_target_group.lb_target_group00.arn ]

}
## export TF_VAR_username=ion
## export TF_VAR_password='ZAQ!2wsx'

variable "db_name" {}

variable "username" {
  type      = string
  sensitive = true
}

variable "password" {
  type      = string
  sensitive = true
}


variable "identifier_prefix" {}


variable "storage_type" {}

variable "storage_size" {}

variable "iops" {}

variable "instance_class" {}

variable "db_subnet_group_name" {}

variable "subnet_ids" {}

variable "subnet_cidrs" {}

variable "vpc_id" {}

variable "mysql_port" {}
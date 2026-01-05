data "terraform_remote_state" "mysql00_state" {
  backend = "s3"

  config = {
    bucket = "oreillys-terraform-up-and-running-state"
    key    = "Chapter03/last part = stage & global/stage/data-stores/mysql/terraform.tfstate"
    region = "eu-central-1"
  }
}



output "data__terraform_remote_state__mysql99_state_outputs" {
  value = data.terraform_remote_state.mysql00_state.outputs
}

## to be added after s3 and dynamoDBB ...

## to delete the s3 and DB , remove this code , then terraform init , then terraform destroy ...

terraform {
  backend "s3" {
    bucket = "oreillys-terraform-up-and-running-state"
    key    = "0000.DIR + LB rulez/s3/terraform.tfstate"
    region = "eu-central-1"

    dynamodb_table = "oreillys-terraform-up-and-running-locks"
    encrypt        = true

  }
}
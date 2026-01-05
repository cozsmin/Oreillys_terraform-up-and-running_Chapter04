data "aws_dynamodb_table" "terraform_locks" {
  name = "oreillys-terraform-up-and-running-locks"
}
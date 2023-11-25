# store the terraform state file in s3 and lock with dynamodb
terraform {
  backend "s3" {
    bucket         = "wiz-terraform-state-file"
    key            = "terraform-module/rentzone/terraform.tfstate"
    region         = "us-east-1"
    profile        = "obinna"
    dynamodb_table = "terraform-state-lock"
  }
}
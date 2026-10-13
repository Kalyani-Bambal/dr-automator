terraform {
  backend "s3" {
    bucket         = "dr-automator-terraform-state-ap-south-1"
    key            = "dev/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "dr-automator-terraform-state-lock"
  }
}
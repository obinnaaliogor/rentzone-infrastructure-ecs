provider "aws" {
  profile = "obinna"
  region  = var.region

  default_tags {
    tags = {
      "Automation"  = "terraform"
      "Project"     = local.project_name #var.project_name
      "Environment" = local.environment  #var.environment
    }
  }
}
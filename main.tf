module "vpc" {
  source = "git@github.com:obinnaaliogor/terraform-modules.git//vpc"

  vpc_cidr     = var.vpc_cidr
  project_name = local.project_name
  environment  = local.environment
  region       = local.region

  public_subnet_az1_cidr       = var.public_subnet_az1_cidr
  public_subnet_az2_cidr       = var.public_subnet_az2_cidr
  private_app_subnet_az1_cidr  = var.private_app_subnet_az1_cidr
  private_app_subnet_az2_cidr  = var.private_app_subnet_az2_cidr
  private_data_subnet_az1_cidr = var.private_data_subnet_az1_cidr
  private_data_subnet_az2_cidr = var.private_data_subnet_az2_cidr
}

module "nat_gateway" {
  source = "git@github.com:obinnaaliogor/terraform-modules.git//nat-gateway"

  # Natgateway Variables
  project_name = local.project_name
  environment  = local.environment

  public_subnet_az1_id       = module.vpc.public_subnet_az1_id
  public_subnet_az2_id       = module.vpc.public_subnet_az2_id
  internet_gateway           = module.vpc.internet_gateway
  vpc_id                     = module.vpc.vpc_id
  private_app_subnet_az1_id  = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id  = module.vpc.private_app_subnet_az2_id
  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id

  #Important, b/c we are getting the values of the argurments for the nat gateway module from the vpc module.
  #We do not need to pass any variable in the variables.tf or in the terraform.tfvars
}

module "security-groups" {
  source = "git@github.com:obinnaaliogor/terraform-modules.git//security-groups"

  project_name = local.project_name
  environment  = local.environment
  vpc_id       = module.vpc.vpc_id
  ssh_ip       = var.ssh_ip
}

module "rds" {
  source = "git@github.com:obinnaaliogor/terraform-modules.git//rds"

  project_name = local.project_name
  environment  = local.environment

  private_data_subnet_az1_id = module.vpc.private_data_subnet_az1_id
  private_data_subnet_az2_id = module.vpc.private_data_subnet_az2_id
  db_snapshot_identifier     = var.db_snapshot_identifier
  instance_class             = var.instance_class
  multi_az                   = var.multi_az
  database_security_group_id = module.security-groups.database_security_group_id
  identifier                 = var.identifier
  availability_zone_1        = module.vpc.availability_zone_1
}

module "acm" {
  source = "git@github.com:obinnaaliogor/terraform-modules.git//acm"

  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
}

module "alb" {
  source = "git@github.com:obinnaaliogor/terraform-modules.git//alb"

  project_name          = local.project_name
  environment           = local.environment
  alb_security_group_id = module.security-groups.alb_security_group_id
  public_subnet_az1_id  = module.vpc.public_subnet_az1_id
  public_subnet_az2_id  = module.vpc.public_subnet_az2_id
  vpc_id                = module.vpc.vpc_id
  certificate_arn       = module.acm.certificate_arn
}

module "s3" {
  source = "git@github.com:obinnaaliogor/terraform-modules.git//s3"

  project_name         = local.project_name
  environment          = local.environment
  env_file_bucket_name = var.env_file_bucket_name
  env_file_name        = var.env_file_name

}

module "iam-role" {
  source = "git@github.com:obinnaaliogor/terraform-modules.git//iam-role"

  project_name         = local.project_name
  environment          = local.environment
  env_file_bucket_name = module.s3.env_file_bucket_name
}

module "ecs" {
  source = "git@github.com:obinnaaliogor/terraform-modules.git//ecs"
  # ecs Variables
  project_name                = local.project_name
  environment                 = local.environment
  ecs_task_execution_role_arn = module.iam-role.ecs_task_execution_role_arn
  cpu_architecture            = var.cpu_architecture
  container_image             = var.container_image
  env_file_bucket_name        = module.s3.env_file_bucket_name
  env_file_name               = module.s3.env_file_name
  region                      = var.region

  private_app_subnet_az1_id    = module.vpc.private_app_subnet_az1_id
  private_app_subnet_az2_id    = module.vpc.private_app_subnet_az2_id
  app_server_security_group_id = module.security-groups.app_server_security_group_id
  alb_target_group_arn         = module.alb.alb_target_group_arn
}

module "asg" {
  source = "git@github.com:obinnaaliogor/terraform-modules.git//asg"

  project_name = local.project_name
  environment  = local.environment
  ecs_service  = module.ecs.ecs_service

}

module "route_53" {
  source = "git@github.com:obinnaaliogor/terraform-modules.git//route53"

  domain_name                        = module.acm.domain_name
  application_load_balancer_zone_id  = module.alb.application_load_balancer_zone_id
  record_name                        = var.record_name
  application_load_balancer_dns_name = module.alb.application_load_balancer_dns_name

}

# print the website url
output "website_url" {
  value = join("", ["https://", var.record_name, ".", var.domain_name])
}
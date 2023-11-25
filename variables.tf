
# Vpc Variables
variable "vpc_cidr" {}
variable "project_name" {}
variable "environment" {}
variable "region" {}

#Public Subnet az1 and az2 Variables
variable "public_subnet_az1_cidr" {}
variable "public_subnet_az2_cidr" {}

#Private App Subnet az1 and az2 Variables
variable "private_app_subnet_az1_cidr" {}
variable "private_app_subnet_az2_cidr" {}

#Private Data Subnet az1 and az2 Variables
variable "private_data_subnet_az1_cidr" {}
variable "private_data_subnet_az2_cidr" {}


#Nat Gateway Variables

#Security Group Variables
variable "ssh_ip" {}

#RDS Variables
variable "db_snapshot_identifier" {}
variable "instance_class" {}
variable "multi_az" {}
variable "identifier" {}


#ACM Variables
variable "domain_name" {}
variable "subject_alternative_names" {}

#ALB Variables

# s3 Variables
variable "env_file_bucket_name" {}
variable "env_file_name" {}

# ecs Variables
variable "cpu_architecture" {}
variable "container_image" {}

#ASG Variables

#Route53 Variables
variable "record_name" {}
variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2"
  type        = string
  default     = "ami-0889a44b331db0194"
}

variable "vpc_name" {
  description = "Name for Custom VPC"
  type        = string
  default     = "lastproject_vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.50.0.0/16"
}

variable "az1a" {
  description = "First AZ for public and private subnets"
  type        = string
  default     = "us-east-1a"
}

variable "az1b" {
  description = "Second AZ for public and private subnets"
  type        = string
  default     = "us-east-1b"
}

variable "db_username" {
  description = "Database admin username"
  type        = string
  default     = "dbadmin"
  sensitive   = true
}

variable "db_password" {
  description = "Database admin password"
  type        = string
  default     = "dbpassword"
  sensitive   = true
}
variable "aws_region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  description = "all subnets"
  default     = "10.0.0.0/16"
}

variable "vpc_cidr_public" {
  description = "Public subnet"
  default     = "10.0.0.0/24"
}

variable "vpc_cidr_private" {
  description = "Private subnet"
  default     = "10.0.2.0/24"
}

variable "security_group_location" {
  default = "0.0.0.0/0"
  type    = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable key_name {
  default = "LL-TEST"
  type    = string
}
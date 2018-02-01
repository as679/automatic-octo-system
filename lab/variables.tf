variable "aws_region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "pkey_training_internal" {}

variable "aws_az" {
  type        = "map"
  default     = {
    us-west-2 = "us-west-2a"
    eu-west-2 = "eu-west-2a"
  }
}

variable "lab_count" {
  default = 1
}

variable "internal_key_name" {
  default = "training-internal"
}
variable "access_key_name" {
  default = "training-access"
}

variable "owner" {
  default = "Training"
}

variable "sid" {
  default = "Student"
}

variable "instance_volume_size" {
  default = "15"
}

variable "instance_flavour" {
  default = "t2.medium"
}

variable "ami_centos" {
  type        = "map"
  default = {
    us-west-2 = "ami-a042f4d8"
    eu-west-2 = "ami-c8d7c9ac"
  }
}

variable "ami_avi_controller" {
  type        = "map"
  default = {
    us-west-2 = "ami-2c0bbf54"
    eu-west-2 = "ami-9caeb6f8"
  }
}

variable "vpc_cidr" {
  default     = "172.16.0.0/16"
}

variable "private_net_names" {
  type = "list"
  default = ["Management", "PoolNet", "VSNet"]
}

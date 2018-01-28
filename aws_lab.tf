provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

module "aws_lab" {
  source = "./lab"

  aws_region = "${var.aws_region}"
  lab_count = 1
}
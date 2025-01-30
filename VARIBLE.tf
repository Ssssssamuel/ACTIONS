# variable "AWS_ACCESS_KEY" {}

# variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  default = "us-east-1"
  type    = string
}

variable "vpc_id" {
  default = "vpc-09c489f7e7f6ccbfe"
}

variable "number_of_sg" {
  default = "1"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "test_key.pub"
  type    = string
}

variable "snapshot_id" {
  default = "arn:aws:rds:us-east-1:577701061234:snapshot:wordpressdbclixx-ecs-snapshot"
  type    = string
}

variable "security_groups" {
  default = "sg-05048737fb0f14c99"
  type    = string
}

variable "ami" {
  # default = "ami-090bc021dc497de64"
  # default = "ami-0f65981e8ccb90000"
  default = "ami-041ac307104473fa1"
  type    = string
}

variable "cert_arn" {
  default = "arn:aws:acm:us-east-1:222634373909:certificate/0fa98a61-2d96-4c25-ae03-68388e8eb588"
  type    = string
}

variable "Record" {
  default = "Z01063533B95XIB5GVOHL"
  type    = string
}

variable "environment" {
  default = "dev"
}

variable "ACCOUNTS" {
  type = map(string)
  default = {
    dev        = 222634373909
    production = 1
    uat        = 225989363026
  }
}
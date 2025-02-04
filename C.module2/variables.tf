variable "AWS_REGION" {
  default = ""
}

variable "PATH_TO_PUBLIC_KEY" {
  default = ""
}

variable "environment" {
  default = ""
}

variable "instance_type"{
  default =""
}

variable "FILE"{
  default =""
}

variable "Record"{
  default =""
}

variable "cert_arn"{
  default = ""
}

variable "snapshot_id"{
  default =""
}

variable "vpc_id"{
    default=""
}

variable "ami" {
  default = ""
}

variable "ami_id" {
  description = "AMI ID to use for the EC2 instance"
  default     = "" 
}

variable "ACCOUNTS" {
  type = map(string)
  default = {
    dev = ""
    production = ""
    uat = ""
  }
}
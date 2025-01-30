variable "PATH_TO_PUBLIC_KEY" {
  default = ""
}

variable "ami" {
  default = ""
}

variable "environment" {
  default = ""
}

variable "security_groups" {
  description = "Security group ID for EC2 instance"
  default = ""
}

variable "ACCOUNTS" {
  type = map(string)
  default = {

  }
}
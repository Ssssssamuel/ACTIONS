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
  default = ""
}

variable "ACCOUNTS" {
  type = map(string)
  default = {

  }
}
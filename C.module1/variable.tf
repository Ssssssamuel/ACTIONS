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
  default = "sg-05048737fb0f14c99"
}

variable "ACCOUNTS" {
  type = map(string)
  default = {

  }
}
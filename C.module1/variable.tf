variable "PATH_TO_PUBLIC_KEY" {
  default = ""
}

variable "ami" {
  default = ""
}

variable "environment" {
  default = "dev"
}

variable "ACCOUNTS" {
  type = map(string)
  default = {
    dev = 222634373909
    production = 1
    uat = 225989363026
  }
}
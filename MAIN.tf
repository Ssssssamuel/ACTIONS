locals {
  env = var.environment
  account_to_deploy = var.ACCOUNTS[local.env]
  account_arn = "arn:aws:iam::${local.account_to_deploy}:role/Engineer"
}

module "my_entire_stack" {
  #source = "./C.module1"

  #For remote source
  source            = "git::https://github.com/Ssssssamuel/Actions-Direc.git//C.module1"

  #AWS_REGION         = var.AWS_REGION
  PATH_TO_PUBLIC_KEY = var.PATH_TO_PUBLIC_KEY
  ami                = var.ami
  security_groups    = var.security_groups
  # cert_arn           = var.cert_arn
  # Record             = var.Record
  # snapshot_id        = var.snapshot_id

}



# ?ref=v1.0.0
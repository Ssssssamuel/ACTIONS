locals {
  env = var.environment
  account_to_deploy = var.ACCOUNTS[local.env]
  account_arn = "arn:aws:iam::${local.account_to_deploy}:role/Engineer"
}

module "my_entire_stack" {
  #source = "./C.module1"

  #For remote source
  source            = "https://github.com/Ssssssamuel/Actions-Direc.git"

  #AWS_REGION         = var.AWS_REGION
  PATH_TO_PUBLIC_KEY = var.PATH_TO_PUBLIC_KEY
  ami                = var.ami
  # cert_arn           = var.cert_arn
  # Record             = var.Record
  # snapshot_id        = var.snapshot_id

}



# .git?ref=v1.0.0
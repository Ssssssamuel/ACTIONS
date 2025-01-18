module "my_entire_stack" {
  #source = "./C.module1"

  #For remote source
  source            = "https://github.com/Ssssssamuel/MY-ACTIONS"

  #AWS_REGION         = var.AWS_REGION
  PATH_TO_PUBLIC_KEY = var.PATH_TO_PUBLIC_KEY
  ami                = var.ami
  # cert_arn           = var.cert_arn
  # Record             = var.Record
  # snapshot_id        = var.snapshot_id

}



# .git?ref=v1.0.0
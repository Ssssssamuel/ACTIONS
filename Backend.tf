terraform {
  backend "s3" {
    bucket         = "stackbuckstatefer"
    key            = "trial/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "statelock-tf"
    encrypt        = true
    # acl     = "bucket-owner-full-control"
  }
}



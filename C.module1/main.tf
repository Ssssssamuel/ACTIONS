# Creating Key Pair
resource "aws_key_pair" "Stack_KP" {
  key_name   = "test_key2"
  public_key = file(var.PATH_TO_PUBLIC_KEY)
}


# Creating EC2 instance
resource "aws_instance" "web-server" {
  ami = var.ami
  instance_type = "t2.micro"
  key_name = aws_key_pair.Stack_KP.key_name
  vpc_security_group_ids = [var.security_groups]

  tags = {
    Name = "GithubActionServer"
  }
}

output "child_security_group_debug" {
  value = var.security_groups
}

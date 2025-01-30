output "Key_pair_id" {
    value = aws_key_pair.Stack_KP.id
}

output "child_security_group_debug" {
  value = var.security_groups
}

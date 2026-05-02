output "public_sg_id" {
  value = aws_security_group.public_sg.id
}

output "private_sg_id" {
  value = aws_security_group.private_sg.id
}

output "key_name" {
  value = aws_key_pair.marizaws_keypair.key_name
}


output "target_group_arn" {
  value = aws_alb_target_group.alb.arn
}
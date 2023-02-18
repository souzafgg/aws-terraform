output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "security_group_out" {
  value = aws_security_group.sec_grp["public"].id
}

output "pub_subnets_out" {
  value = aws_subnet.public_subnet.*.id
}
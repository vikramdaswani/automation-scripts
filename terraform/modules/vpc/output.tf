output "vpc_id" {
  value = aws_vpc.primary.id
}

output "in_gw" {
  value = aws_internet_gateway.primary_igw.id
}

output "primary_subnet" {
  value = aws_subnet.primary-subnet.id
}

output "primary-rt" {
  value = aws_route_table.primary-rt.id
}

output "allowall-acl" {
  value = aws_network_acl.allowall-acl.id
}

output "allowall-sg" {
  value = aws_security_group.allowall-sg.id
}

output "instance_id" {
  value = aws_instance.webserver.id
}

output "elastic_ip_id" {
  value = aws_eip.webserver-eip.id
}

output "elastic_ip_private_ip" {
  value = aws_eip.webserver-eip.private_ip
}

output "elastic_ip_instance" {
  value = aws_eip.webserver-eip.instance
}
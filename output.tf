#print app server ip
output "public_ip" {
  value       = aws_instance.public-server.public_ip
  
}
# print db server ip
output "private-server" {
  value = aws_instance.private-server.private_ip

}

output "private-server2" {
  value = aws_instance.private-server2
}
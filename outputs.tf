output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.splunk_server.public_ip
}

output "instance_id" {
  description = "Instance ID of the EC2 instance"
  value       = aws_instance.splunk_server.id
}

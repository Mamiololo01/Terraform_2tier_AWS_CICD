output "Project-db-instance-endpoint" {
  description = "The Project DB instance endpoint"
  value       = aws_db_instance.projectdbinstance.endpoint
}
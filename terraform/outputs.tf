output "api_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "mongo_private_ip" {
  value = aws_instance.mongo.private_ip
}

output "mongo_instance_id" {
  description = "Connect with: aws ssm start-session --target <id>"
  value       = aws_instance.mongo.id
}

output "mongo_uri_secret_arn" {
  value = aws_secretsmanager_secret.mongo.arn
}

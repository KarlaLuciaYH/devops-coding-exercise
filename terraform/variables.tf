variable "region" {
  type    = string
  default = "us-east-1"
}

variable "name" {
  type    = string
  default = "flights"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "mongo_instance_type" {
  type    = string
  default = "t3.small"
}

variable "mongo_volume_size_gb" {
  type    = number
  default = 20
}

variable "mongo_db_name" {
  type    = string
  default = "flights"
}

variable "lambda_zip_path" {
  description = "Path to the Lambda package built by scripts/build_lambda.sh"
  type        = string
  default     = "../build/lambda.zip"
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "random_password" "mongo" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "mongo" {
  name_prefix = "${var.name}-mongo-uri-"
}

resource "aws_secretsmanager_secret_version" "mongo" {
  secret_id     = aws_secretsmanager_secret.mongo.id
  secret_string = local.mongo_uri
}

locals {
  mongo_user = "app"
  mongo_uri  = "mongodb://${local.mongo_user}:${random_password.mongo.result}@${aws_instance.mongo.private_ip}:27017/${var.mongo_db_name}?authSource=${var.mongo_db_name}"
}

resource "aws_iam_role" "mongo" {
  name = "${var.name}-mongo-ec2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

# SSM Session Manager replaces SSH (no inbound port needed)
resource "aws_iam_role_policy_attachment" "mongo_ssm" {
  role       = aws_iam_role.mongo.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "mongo" {
  name = "${var.name}-mongo-ec2"
  role = aws_iam_role.mongo.name
}

resource "aws_instance" "mongo" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = var.mongo_instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.mongo.id]
  iam_instance_profile   = aws_iam_instance_profile.mongo.name

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    volume_size = var.mongo_volume_size_gb
    volume_type = "gp3"
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user_data.sh.tftpl", {
    db_name  = var.mongo_db_name
    user     = local.mongo_user
    password = random_password.mongo.result
  })
  user_data_replace_on_change = true

  tags = { Name = "${var.name}-mongo" }

  depends_on = [aws_route_table_association.private]
}

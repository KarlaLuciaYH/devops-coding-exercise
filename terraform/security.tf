# SG attached to the app (Lambda) that is allowed to talk to MongoDB
resource "aws_security_group" "app" {
  name        = "${var.name}-app-sg"
  description = "API application; may reach MongoDB"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_egress_rule" "app_to_mongo" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.mongo.id
  ip_protocol                  = "tcp"
  from_port                    = 27017
  to_port                      = 27017
}

# SG for the MongoDB EC2: only accepts 27017 from the app SG
resource "aws_security_group" "mongo" {
  name        = "${var.name}-mongo-sg"
  description = "MongoDB; ingress only from the app SG"
  vpc_id      = aws_vpc.main.id
}

resource "aws_vpc_security_group_ingress_rule" "mongo_from_app" {
  security_group_id            = aws_security_group.mongo.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 27017
  to_port                      = 27017
}

# Outbound HTTPS/HTTP only (package install, SSM) via NAT
resource "aws_vpc_security_group_egress_rule" "mongo_https" {
  security_group_id = aws_security_group.mongo.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "mongo_http" {
  security_group_id = aws_security_group.mongo.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

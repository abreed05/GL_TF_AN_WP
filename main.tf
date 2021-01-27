resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "ext_route" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-gw.id
  depends_on             = [aws_internet_gateway.main-gw]
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  }


resource "aws_security_group" "Allow_SSH" {
  name = "Allow_SSH"
  vpc_id = aws_vpc.main.id
  depends_on = [aws_vpc.main]
}

resource "aws_security_group" "Allow_Web" {
  name = "Allow_Web"
  vpc_id = aws_vpc.main.id
  depends_on = [aws_vpc.main]
  }

resource "aws_security_group_rule" "Allow_SSH_Rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [ "youriphere/cidr" ]
  security_group_id = aws_security_group.Allow_SSH.id 

}

resource "aws_security_group_rule" "Allow_Mysql_Rule" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [ "10.0.1.0/24" ]
  security_group_id = aws_security_group.Allow_SSH.id 

}

resource "aws_security_group_rule" "Allow_SSH_ALL_Rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.Allow_SSH.id 

}

resource "aws_security_group_rule" "Allow_Web_HTTP_Rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.Allow_Web.id 

}

resource "aws_security_group_rule" "Allow_Web_HTTPS_Rule" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.Allow_Web.id 

}

resource "aws_security_group_rule" "Allow_Web_ALL_Rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = [ "0.0.0.0/0" ]
  security_group_id = aws_security_group.Allow_Web.id 

}

resource "aws_instance" "WebServer" {
  ami             = var.ec2_image
  instance_type   = var.ec2_instance_type
  key_name        = var.ec2_keypair
  security_groups = [aws_security_group.Allow_SSH.id, aws_security_group.Allow_Web.id]
  subnet_id = aws_subnet.public.id
  availability_zone = "us-east-1a"
  private_ip = "10.0.1.10"
  tags = {
    Name = var.ec2_tags
  }
  depends_on      = [aws_security_group.Allow_SSH, aws_security_group.Allow_Web]
  
}

resource "aws_instance" "DBServer" {
  ami           = var.ec2_image
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_keypair
  security_groups = [aws_security_group.Allow_SSH.id]
  availability_zone = "us-east-1a"
  subnet_id = aws_subnet.public.id
  private_ip = "10.0.1.100"

  tags = {
    Name = var.ec2_tags
  }
  depends_on = [aws_security_group.Allow_SSH]
}

data "aws_route53_zone" "selected" {
  name = var.domain
}

resource "aws_route53_record" "ec2-prime" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = var.domain
  type    = "A"
  ttl     = "300"
  records = [aws_instance.WebServer.public_ip]
  depends_on = [aws_instance.WebServer]
}

resource "null_resource" "Create_host" {

  depends_on = [aws_instance.WebServer, aws_instance.DBServer]

  provisioner "local-exec" {
      command = "echo ${aws_instance.WebServer.public_ip} >> hosts/hosts.ini"
  
  }

  provisioner "local-exec" {
    command = "echo [db] >> hosts/hosts.ini"
  
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.DBServer.public_ip} >> hosts/hosts.ini"
  }

}
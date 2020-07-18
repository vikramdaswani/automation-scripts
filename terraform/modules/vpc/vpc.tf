resource "aws_vpc" "primary" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "Primary_VPC"
  }
}

resource "aws_internet_gateway" "primary_igw" {
  vpc_id = aws_vpc.primary.id
  tags = {
    Name = "Primary_IGW"
  }
}

resource "aws_subnet" "primary-subnet" {
  vpc_id            = aws_vpc.primary.id
  cidr_block        = "10.1.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "primary-subnet1"
  }
}

resource "aws_route_table" "primary-rt" {
  vpc_id = aws_vpc.primary.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.primary_igw.id
  }
}

resource "aws_route_table_association" "primary-rt-association" {
  subnet_id      = aws_subnet.primary-subnet.id
  route_table_id = aws_route_table.primary-rt.id
}

resource "aws_network_acl" "allowall-acl" {
  vpc_id = aws_vpc.primary.id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_security_group" "allowall-sg" {
  name        = "allowall-sg"
  description = "security group for allowing all traffic"
  vpc_id      = aws_vpc.primary.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "webserver-eip" {
  instance   = aws_instance.webserver.id
  vpc        = true
  depends_on = [aws_internet_gateway.primary_igw]
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.ubuntu.id
  availability_zone      = "us-east-1a"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allowall-sg.id]
  subnet_id              = aws_subnet.primary-subnet.id

  tags = {
    Name = "test_webserver"
  }
}
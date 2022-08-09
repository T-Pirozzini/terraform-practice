// 1. create virtual private cloud
resource "aws_vpc" "hockey_vpc" {
  cidr_block = "10.0.0.0/16" //classless inter-domain routing

  tags = {
    Name = "hockey-production"
  }
}

// 2. create internet gateway
resource "aws_internet_gateway" "hockey_igw" {
  vpc_id = aws_vpc.hockey_vpc.id

  tags = {
    Name = "hockey-igw"
  }
}

// 3. create custom route table
resource "aws_route_table" "hockey_rt" {
  vpc_id = aws_vpc.hockey_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.hockey_igw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.hockey_igw.id
  }

  tags = {
    Name = "hockey-rt"
  }
}

// 4. configure subnet
resource "aws_subnet" "hockey_subnet" {
  vpc_id            = aws_vpc.hockey_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-1a"

  tags = {
    Name = "hockey-subnet"
  }
}

// 5. associate subnet with route table
resource "aws_route_table_association" "hockey_assoc" {
  subnet_id      = aws_subnet.hockey_subnet.id
  route_table_id = aws_route_table.hockey_rt.id
}

// 6. create security group
resource "aws_security_group" "hockey_sg" {
  name        = "allow_web_traffic"
  description = "allow web inbound traffic"
  vpc_id      = aws_vpc.hockey_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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

  tags = {
    Name = "allow_web_hockey"
  }
}

// 7. create a network interface
resource "aws_network_interface" "hockey_nic" {
  subnet_id       = aws_subnet.hockey_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.hockey_sg.id]
}

// 8. assign an elastic IP to the network interface
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.hockey_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.hockey_igw]
}

resource "aws_key_pair" "hockey_auth" {
  key_name   = "hockey-key"
  public_key = file("~/.ssh/hockey-key.pub")
}

// 9. create Ubuntu server (Elastic Compute Cloud instance (EC2))& install/enable apache2
resource "aws_instance" "hockey_server" {
  ami               = "ami-067f8db0a5c2309c0" // Amazon Machine Image (Ubuntu 18.04)
  instance_type     = "t2.micro"              // type of server
  availability_zone = "us-west-1a"
  key_name          = "hockey-key"
  user_data         = file("userdata.tpl")

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.hockey_nic.id
  }

  tags = {
    Name = "hockey-server"
  }
}

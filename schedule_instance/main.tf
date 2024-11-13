resource "aws_vpc" "waters_vpc" {
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "waters_subnet" {
  vpc_id            = aws_vpc.waters_vpc.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_security_group" "waters_security_group" {
	name = "waters_SG"
	vpc_id = aws_vpc.waters_vpc.id

	ingress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
		from_port        = 0
		to_port          = 0
		protocol         = "-1"
		cidr_blocks      = ["0.0.0.0/0"]
	}

}

resource "aws_route_table" "waters_rt" {
  vpc_id = aws_vpc.waters_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.waters_gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.waters_gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_internet_gateway" "waters_gw" {
  vpc_id = aws_vpc.waters_vpc.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table_association" "waters_rt_a" {
  subnet_id = aws_subnet.waters_subnet.id
  route_table_id = aws_route_table.waters_rt.id

}

resource "aws_key_pair" "eogbonna_keys" {
  key_name   = "eogbonna_keypair"
  public_key = file("/Users/emmanuel.ogbonna/.ssh/id_rsa.pub")
}

resource "aws_instance" "waters_host01" {
	ami = "ami-0ad9796167d61b7ae"
	instance_type = "t2.micro"
	vpc_security_group_ids = [aws_security_group.waters_security_group.id]
	key_name = aws_key_pair.eogbonna_keys.key_name
	associate_public_ip_address = true
	subnet_id = aws_subnet.waters_subnet.id
	tags = {
		Name = "dev_test"
	}
	root_block_device {
		volume_size = 40
		volume_type = "gp3"
	}
}
output "ec2instance" {
  value = aws_instance.waters_host01.public_ip
}

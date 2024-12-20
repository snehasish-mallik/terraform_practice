terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
    region = var.region
  
}

resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block_vpc
  
}

# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.cidr_block_subnet
    map_public_ip_on_launch = true
  
}

# Add route to the Internet Gateway in the subnet's route table
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
}

# Create the route that directs internet-bound traffic to the internet gateway
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Associate the route table with the subnet
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}


resource "aws_security_group" "sg01" {
  vpc_id = aws_vpc.vpc.id

  egress = [
    {
      cidr_blocks      = [ "0.0.0.0/0", ]
      description      = ""
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "-1"
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
 ingress                = [
   {
     cidr_blocks      = [ "0.0.0.0/0", ]
     description      = ""
     from_port        = 22
     ipv6_cidr_blocks = []
     prefix_list_ids  = []
     protocol         = "tcp"
     security_groups  = []
     self             = false
     to_port          = 22
  }
  ]
}

resource "aws_instance" "my-server-1" {
    ami = var.ec2_ami
    key_name = var.key_pair
    subnet_id = aws_subnet.subnet.id
    instance_type = var.instance_type
    security_groups = [ aws_security_group.sg01.id ]
    associate_public_ip_address = true 
  
}
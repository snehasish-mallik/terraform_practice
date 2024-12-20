terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

#Creating a S3 bucket with versioning enabled.

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-0081"
}

# adding versioning to s3 test new branch test with git
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.example.id
  versioning_configuration {
    status = "Enabled"
  }
}


# Step 1: Create a Key Pair
resource "aws_key_pair" "my_keypair" {
  key_name   = "my-key-pair-2"
  public_key = file("~/.ssh/my-private-key.pub")  # Path to your public key (generated earlier)
}

# Step 2: Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Step 3: Create a Public Subnet (for Bastion Host)
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true  # Public IP for bastion host
}

# Step 4: Create a Private Subnet (for EC2 Instance)
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = false
}

# Step 5: Create a Security Group for SSH (Bastion Host)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open SSH to any IP (You can restrict this to specific IPs later)
  }
}

# Step 6: Create a Bastion Host (in the public subnet)
resource "aws_instance" "bastion" {
  ami           = "ami-0c55b159cbfafe1f0"  # Use a valid AMI for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = aws_key_pair.my_keypair.key_name  # Associate the key pair

  security_groups = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "Bastion-Host"
  }
}

# Step 7: Create a Security Group for the Private EC2 Instance (only allow SSH from Bastion Host)
resource "aws_security_group" "private_ec2_sg" {
  name        = "private_ec2_sg"
  description = "Allow SSH only from Bastion Host"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]  # Only allow SSH from the Bastion Host
  }

  tags = {
    Name = "Private-EC2-SG"
  }
}

# Step 8: Create the Private EC2 Instance (in the private subnet)
resource "aws_instance" "private_ec2" {
  ami           = "ami-0c55b159cbfafe1f0"  # Use a valid AMI for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id
  key_name      = aws_key_pair.my_keypair.key_name  # Associate the key pair

  security_groups = [aws_security_group.private_ec2_sg.id]

  tags = {
    Name = "Private-EC2"
  }
}


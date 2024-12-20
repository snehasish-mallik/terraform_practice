variable "region" {
    description = "region name"
    type = string
    default = "us-east-1"
  
}

variable "instance_type" {
    description = "ec2 instance type value"
    type = string
    default = "t2.micro"
  
}

variable "ec2_ami" {
    description = "ami value"
    type = string
    default = "ami-01816d07b1128cd2d"
  
}

variable "cidr_block_vpc" {
    description = "vpc cidr block"
    type = string
    default = "10.0.0.0/16"
}

variable "cidr_block_subnet" {
    description = "subnet cidr block"
    type = string
    default = "10.0.1.0/24"
  
}


variable "key_pair" {
    description = "key pair name"
    type = string
    default = "key_ec2"
  
}

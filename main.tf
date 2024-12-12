#1.configure the provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}


#2.VPC
resource "aws_vpc" "vpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "terraform_vpc"
    Managed_by = "terraform"
  }
}

#3. internet gateway
resource "aws_internet_gateway" "igw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "terraform_vpc"
    Managed_by = "terraform"
  }
}

#4.public subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "terraform_pub_sub_1"
    Managed_by = "terraform"
  }
}

#5.private subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "terraform_pri_sub_1"
    Managed_by = "terraform"
  }
}

#6. Public route table 
resource "aws_route_table" "public_RT" {
  vpc_id = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw1.id
  }

  tags = {
    Name = "terraform_pub_rt"
    Managed_by = "terraform"
  }
}

#7. Private route table
resource "aws_route_table" "private_RT" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "terraform_pri_rt"
    Managed_by = "terraform"
  }
}

#8.public subnet association
resource "aws_route_table_association" "pubsub1_pubrt" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_RT.id
}

#9.private subnet association
resource "aws_route_table_association" "prisub1_prirt" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_RT.id
}

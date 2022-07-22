terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.17.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
 
  

}
resource "aws_vpc" "threetierpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "demo-vpc"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.threetierpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "demo-subnet-for-my-private-vpc"
  }
}
# count or for-each terraform 
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.threetierpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "demo-subnet-for-my-public-vpc"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.threetierpc.id

  route = []

  tags = {
    Name = "public-route-table-threetierpc"
  }
}



resource "aws_default_route_table" "private-route-table" {
  default_route_table_id = aws_vpc.threetierpc.default_route_table_id 

 
  tags = {
    Name = "private-route-table-threetierpc"
  }
}

resource "aws_route" "public-route" {
  route_table_id              = aws_route_table.public-route-table.id
  gateway_id      =             aws_internet_gateway.igw-public.id
  destination_cidr_block = "0.0.0.0/0"
}

/*No Private route is required as created by default  Eg 10.0.0.0/24	local*/

resource "aws_internet_gateway" "igw-public" {
  vpc_id = aws_vpc.threetierpc.id

  tags = {
    Name = "igw-public"
  }
}

resource "aws_route_table_association" "public association" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.public-route-table.id

}

resource "aws_route_table_association" "private association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_default_route_table.private-route-table.id

}

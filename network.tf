#create a custom VPC
resource "aws_vpc" "Project-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "Project_Env"
    Terraform   = "true"
  }

  enable_dns_hostnames = true
}

#create internet gateway to attach to custom VPC
resource "aws_internet_gateway" "Project-igw" {
  vpc_id = aws_vpc.Project-vpc.id

  tags = {
    Name = "Project-igw"
  }
}

#A public subnet launched in the us-east-1a AZ (Web-Tier)
resource "aws_subnet" "Project-pubsub1" {
  vpc_id                  = aws_vpc.Project-vpc.id
  cidr_block              = "10.50.1.0/24"
  availability_zone       = var.az1a
  map_public_ip_on_launch = true

  tags = {
    Name = "Project-pub1"
  }
}

#A public subnet launched in the us-east-1b AZ (Web-Tier)
resource "aws_subnet" "Project-pubsub2" {
  vpc_id                  = aws_vpc.Project-vpc.id
  cidr_block              = "10.50.2.0/24"
  availability_zone       = var.az1b
  map_public_ip_on_launch = true

  tags = {
    Name = "Project-pubsub2"
  }
}

#create an elastic IP to assign to NAT Gateway
resource "aws_eip" "Project-eip1" {
  vpc        = true
  depends_on = [aws_vpc.Project-vpc]
  tags = {
    Name = "Project-eip1"
  }
}

#create an elastic IP to assign to NAT Gateway
resource "aws_eip" "Project-eip2" {
  vpc        = true
  depends_on = [aws_vpc.Project-vpc]
  tags = {
    Name = "Project-eip2"
  }
}

#create NAT Gateway
resource "aws_nat_gateway" "Project-nat-gw1" {
  depends_on    = [aws_eip.Project-eip1]
  allocation_id = aws_eip.Project-eip1.id
  subnet_id     = aws_subnet.Project-pubsub1.id
  tags = {
    Name = "Project-nat-gw"
  }
}

#create NAT Gateway
resource "aws_nat_gateway" "Project-nat-gw2" {
  depends_on    = [aws_eip.Project-eip2]
  allocation_id = aws_eip.Project-eip2.id
  subnet_id     = aws_subnet.Project-pubsub2.id
  tags = {
    Name = "Project-nat-gw"
  }
}

#A private subnet launched in the AZ us-east-1a (RDS-Tier)
resource "aws_subnet" "Project-privsub1" {
  vpc_id            = aws_vpc.Project-vpc.id
  cidr_block        = "10.50.3.0/24"
  availability_zone = var.az1a

  tags = {
    Name = "Project-privsub1"
  }
}

#A private subnet launched in the AZ us-east-1b  (RDS-Tier)
resource "aws_subnet" "Project-privsub2" {
  vpc_id            = aws_vpc.Project-vpc.id
  cidr_block        = "10.50.4.0/24"
  availability_zone = var.az1b

  tags = {
    Name = "Project-privsub2"
  }
}

#create public route table with route for internet gateway 
resource "aws_route_table" "Project-public-rt" {
  vpc_id = aws_vpc.Project-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Project-igw.id
  }

  tags = {
    Name = "Project-igw"
  }
}

#public route table with public subnet associations
resource "aws_route_table_association" "publicsub-route1" {
  route_table_id = aws_route_table.Project-public-rt.id
  subnet_id      = aws_subnet.Project-pubsub1.id
}

resource "aws_route_table_association" "publicsub-route2" {
  route_table_id = aws_route_table.Project-public-rt.id
  subnet_id      = aws_subnet.Project-pubsub2.id
}

#create private route table with route for NAT gateway
resource "aws_route_table" "Project-private-rt1" {
  vpc_id = aws_vpc.Project-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Project-nat-gw1.id
  }

  tags = {
    Name = "Project-private-rt1"
  }
}

#private route table with private subnet associations
resource "aws_route_table_association" "privsub-route1" {
  route_table_id = aws_route_table.Project-private-rt1.id
  subnet_id      = aws_subnet.Project-privsub1.id
}

#create private route table with route for NAT gateway
resource "aws_route_table" "Project-private-rt2" {
  vpc_id = aws_vpc.Project-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.Project-nat-gw2.id
  }

  tags = {
    Name = "Project-private-rt2"
  }
}

#private route table with private subnet associations
resource "aws_route_table_association" "privsub-route2" {
  route_table_id = aws_route_table.Project-private-rt2.id
  subnet_id      = aws_subnet.Project-privsub2.id
}
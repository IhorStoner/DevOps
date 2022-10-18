#----------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "main"
  }
}

#Public
resource "aws_subnet" "main_public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_cidr_public
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main Public network"
  }
}

## Private
resource "aws_subnet" "main_private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.vpc_cidr_private
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Main Private network"
  }
}
#Internet  GW
resource "aws_internet_gateway" "mainGW" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "internet_gateway"
  }
}

#Elastic IP for GW
resource "aws_eip" "mainEIP" {
  vpc        = true
  depends_on = [aws_internet_gateway.mainGW]
}

#NAT gateway
resource "aws_nat_gateway" "mainNatGW" {
  allocation_id = aws_eip.mainEIP.id
  subnet_id     = aws_subnet.main_public.id
  depends_on    = [aws_internet_gateway.mainGW]
}

#Output
output "GW_IP" {
  value = aws_eip.mainEIP.public_ip
}

#Default route to Internet
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mainGW.id
}

#Routing table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.mainNatGW.id
}

#Routing table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mainGW.id
  }
}

#Associate  public subnet to public route table
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.main_public.id
  route_table_id = aws_vpc.main.main_route_table_id
}

#Associate  private subnet to private route table
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.main_private.id
  route_table_id = aws_route_table.private.id
}

#----------------------------------------------------

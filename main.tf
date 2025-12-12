terraform {
  backend "s3" {
    bucket = "raj-lambda-bucket-20251206-01"
    key = "terraform.tfstate"
    region = "ap-south-1"
  }
}
provider "aws" {
  region=var.region
}
# create a vpc 
resource "aws_vpc" "my-vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.project_name}-vpc"
  }
}
#create a private subnet
resource "aws_subnet" "private-subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.private-vpc_cidr
  availability_zone = var.az1
  tags = {
    Name = "${var.project_name}-private-subnet"
  }
}

# create a private subnet in az2
resource "aws_subnet" "private-subnet2" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.private-vpc_cidr2
  availability_zone = var.az2
  tags = {
    Name = "${var.project_name}-private-subnet2"
  }
}


# public subnet

resource "aws_subnet" "public-subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = var.public-cidr
  availability_zone = var.az1
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}
# create a internet gateway
resource "aws_internet_gateway" "my-IGW" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.project_name}-IGW"
  }
}
# create NAT gateway
resource "aws_nat_gateway" "aws-NAT-GW" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id = aws_subnet.private-subnet.id
  depends_on = [ aws_internet_gateway.my-IGW ]
  tags = {
    Name = "${var.project_name}-NAT-GW"
  }
}
  
  # create elastic IP for NAT gateway
resource "aws_eip" "nat-eip" {
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}
# create a route table for private subnets with NAT gateway
resource "aws_route_table" "private-RT" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "${var.project_name}-private-RT"
  }
}

# add nat gateway route in private subnet route table
resource "aws_route" "aws-route-NAT-GW" {
  route_table_id = aws_route_table.private-RT.id
  destination_cidr_block = var.igw_cidr
  nat_gateway_id = aws_nat_gateway.aws-NAT-GW.id
}

# create a route table for public subnets
resource "aws_default_route_table" "main-RT" {
    default_route_table_id = aws_vpc.my-vpc.default_route_table_id
    tags = {
      Name = "${var.project_name}-main-RT"
    }
}
# add a route in main route table
resource "aws_route" "aws-route-IGW" {
  route_table_id = aws_default_route_table.main-RT.id
  destination_cidr_block = var.igw_cidr
  gateway_id = aws_internet_gateway.my-IGW.id
}
#route table association for private subnet
resource "aws_route_table_association" "private-RT-association" {
  subnet_id = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private-RT.id
}

#route table association for private subnet 2
resource "aws_route_table_association" "private-RT-association2" {
  subnet_id = aws_subnet.private-subnet2.id
  route_table_id = aws_route_table.private-RT.id
}

#route table association for public subnet
resource "aws_route_table_association" "public-RT-association" {
  subnet_id = aws_subnet.public-subnet.id
  route_table_id = aws_default_route_table.main-RT.id
}
# create security group 
resource "aws_security_group" "my-sg" {
  vpc_id = aws_vpc.my-vpc.id
  name = "${var.project_name}-sg"
  description = "Allow SSH and HTTP , mysql access"
  ingress {
     protocol = "tcp"
     to_port = 22
        from_port = 22
        cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol = "tcp"
    to_port = 80
    from_port = 80
    cidr_blocks = ["0.0.0.0/0"]
}

ingress {
    protocol = "tcp"
    to_port = 3306
    from_port = 3306
    cidr_blocks = ["0.0.0.0/0"]

}
    egress {
        protocol = "-1"
        from_port = 0
        to_port = 0
        cidr_blocks = ["0.0.0.0/0"]
}
depends_on = [ aws_vpc.my-vpc ]  # explicite dependency
}
# create a public server
resource "aws_instance" "public-server" {
  subnet_id = aws_subnet.public-subnet.id
  ami = var.ami
    instance_type = var.instance_type
    key_name = var.key
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    tags = {
        Name = "${var.project_name}-app-server"
    }
    depends_on = [ aws_security_group.my-sg ]
}
#create a private server
resource "aws_instance" "private-server" {
    subnet_id = aws_subnet.private-subnet.id
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    tags = {
        Name = "${var.project_name}-db-server"
    }
  depends_on = [ aws_security_group.my-sg ]
}
 # create a second private server
resource "aws_instance" "private-server2" {
    subnet_id = aws_subnet.private-subnet2.id
    ami = var.ami
    instance_type = var.instance_type
    key_name = var.key
    vpc_security_group_ids = [aws_security_group.my-sg.id]
    tags = {
        Name = "${var.project_name}-db-server2"
    }
  depends_on = [ aws_security_group.my-sg ]
}


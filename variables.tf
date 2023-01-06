resource "aws_vpc" "main" {
cidr_block = "10.0.0.0/16"

tags = {
Name = "Project VPC"
}
}

# creating public and private subnets across our multiple AZ
resource "aws_subnet" "public_subnets" {
count             = length(var.public_subnet_cidrs)
vpc_id            = aws_vpc.main.id
cidr_block        = element(var.public_subnet_cidrs, count.index)
availability_zone = element(var.azs, count.index)

tags = {
Name = "Public Subnet ${count.index + 1}"
}
}

resource "aws_subnet" "private_subnets" {
count             = length(var.private_subnet_cidrs)
vpc_id            = aws_vpc.main.id
cidr_block        = element(var.private_subnet_cidrs, count.index)
availability_zone = element(var.azs, count.index)

tags = {
Name = "Private Subnet ${count.index + 1}"
}
}

# for public subnets, we need to provide access to the internet in the given VPC
resource "aws_internet_gateway" "gw" {
vpc_id = aws_vpc.main.id

tags = {
Name = "Project VPC IG"
}
}

# As a default setting all the subnets are associated implicitly. To change this we create a second route table to explicit public subnet
resource "aws_route_table" "second_rt" {
vpc_id = aws_vpc.main.id

route {
cidr_block = "0.0.0.0/0"
gateway_id = aws_internet_gateway.gw.id
}

tags = {
Name = "2nd Route Table"
}
}

# Associating second RT with public subnet
resource "aws_route_table_association" "public_subnet_asso" {
count = length(var.public_subnet_cidrs)
subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
route_table_id = aws_route_table.second_rt.id
}

# security group for nginx
resource "aws_security_group" "ssh-allowed" {
vpc_id = aws_vpc.main.id
egress {
from_port   = 0
to_port     = 0
protocol    = -1
cidr_blocks = ["0.0.0.0/0"]
}
ingress {
from_port = 22
to_port   = 22
protocol  = "tcp"
cidr_blocks = ["0.0.0.0/0"] // Ideally best to use your machines' IP. However if it is dynamic you will need to change this in the vpc every so often.
}
ingress {
from_port   = 80
to_port     = 80
protocol    = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}
}
resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "r42-aws-vpc"
    }
}

resource "aws_internet_gateway" "default_gateway" {
    vpc_id = "${aws_vpc.default.id}"
}

//  Create one public subnet per key in the subnet map.
resource "aws_subnet" "public-subnet" {
  count                   = "${length(var.public_subnets)}"
  
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${element(values(var.public_subnets), count.index)}"
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.default_gateway"]
  availability_zone       = "${element(keys(var.public_subnets), count.index)}"
  tags {
        Name = "r42-public-subnet-${count.index}"
    }
}

//  Create a route table allowing all addresses access to the IGW.
resource "aws_route_table" "public" {
  vpc_id       = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.default_gateway.id}"
  }
}

//  Now associate the route table with the public subnet - giving
//  all public subnet instances access to the internet.
resource "aws_route_table_association" "public-subnet" {
  count          = "${length(var.public_subnets)}"
  
  subnet_id      = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

//private subnets

//  Create one public subnet per key in the subnet map.
resource "aws_subnet" "private-subnet" {
  count                   = "${length(var.private_subnets)}"
  
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${element(values(var.private_subnets), count.index)}"
  //map_public_ip_on_launch = true
  //depends_on              = ["aws_internet_gateway.default_gateway"]
  availability_zone       = "${element(keys(var.private_subnets), count.index)}"
  tags {
        Name = "r42-private-subnet-${count.index}"
    }
}

# resource "aws_eip" "nat_gw_eip" {
#   //count = "${length(var.public_subnets)}"
#   vpc = true
# }

# resource "aws_nat_gateway" "gw" {
 
#   //subnet_id     = "${aws_subnet.public.id}"
#   # count          = "${length(var.public_subnets)}"
#   allocation_id = "${aws_eip.nat_gw_eip.id}"
#   //subnet_id      = "${element(aws_subnet.public-subnet.*.id, count.index)}"
#   subnet_id = "${aws_subnet.public-subnet.1.id}"
# }

//  Create a route table allowing all addresses access to the IGW.
# resource "aws_route_table" "private" {
#   vpc_id       = "${aws_vpc.default.id}"

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = "${aws_eip.nat_gw_eip.id}"
#   }
# }

//  Now associate the route table with the public subnet - giving
//  all public subnet instances access to the internet.
# resource "aws_route_table_association" "private-subnet" {
#   count          = "${length(var.private_subnets)}"
  
#   subnet_id      = "${element(aws_subnet.private-subnet.*.id, count.index)}"
#   route_table_id = "${aws_route_table.private.id}"
# }


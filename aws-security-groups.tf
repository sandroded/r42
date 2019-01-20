//  This security group allows intra-node communication on all ports with all
//  protocols.
# resource "aws_security_group" "intra_node_communication" {
#   name        = "intra-node-communication"
#   description = "Default security group that allows all instances in the VPC to talk to each other over any port and protocol."
#   vpc_id      = "${aws_vpc.default.id}"

#   ingress {
#     from_port = "0"
#     to_port   = "0"
#     protocol  = "-1"
#     self      = true
#   }

#   egress {
#     from_port = "0"
#     to_port   = "0"
#     protocol  = "-1"
#     self      = true
#   }
# }

//  This security group allows public ingress to the ALB for HTTP, HTTPS
resource "aws_security_group" "public_ingress" {
  name        = "public_ingress"
  description = "Security group that allows public ingress to instances on HTTP and HTTPS."
  vpc_id      = "${aws_vpc.default.id}"

  //  HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  //  HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

//  This security group allows public egress from the clean web servers ( used to create AMI) for HTTP and
//  HTTPS, which is needed for apt updates, git access etc etc.
resource "aws_security_group" "public_egress" {
  name        = "-"
  description = "Security group that allows egress to the internet for instances over HTTP and HTTPS."
  vpc_id      = "${aws_vpc.default.id}"

  //  HTTP
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  //  HTTPS
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

//  Security group which allows SSH access to a host. Should not be used in production scenarios
resource "aws_security_group" "ssh_access_bastion" {
  name        = "ssh_access_bastion"
  description = "Security group that allows public access over SSH."
  vpc_id      = "${aws_vpc.default.id}"

  //  SSH from allowed external IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.corporate_subnet}"]
  }
  //  SSH from allowed external IP
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
}

//  Security group which allows SSH access to a web-servers .
resource "aws_security_group" "ssh_access_from_bastion" {
  name        = "ssh_access_from_bastion"
  description = "Security group that allows access from bastion to web-servers over SSH."
  vpc_id      = "${aws_vpc.default.id}"

  //  SSH from bastion internal IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion.private_ip}/32"]
  }

}

//  Security group which allows  to 8080 on a host. used on ALB
resource "aws_security_group" "http_8080_to_intra" {
  name        = "http_8080_to_intra"
  description = "Security group that allows egress to web-servers."
  vpc_id      = "${aws_vpc.default.id}"


  //  ALB to 8080
  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
}

//  Security group which allows  access to port 8080 on a host from VPC. 
resource "aws_security_group" "ingress_http_8080" {
  name        = "ingress_http_8080"
  description = "Security group that allows incoming traffic to 8080"
  vpc_id      = "${aws_vpc.default.id}"


  //  8080 from ALB
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.vpc_cidr}"]
  }
}
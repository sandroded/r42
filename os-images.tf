// look for the latest ubuntu 18.04 image from Canonical
data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

// instance for ssh access to the internal nodes
resource "aws_instance" "bastion" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type  = "${var.instance_size}"
    vpc_security_group_ids = ["${aws_security_group.ssh_access_bastion.id}"]
    subnet_id = "${aws_subnet.public-subnet.0.id}"
    key_name = "${aws_key_pair.keypair.key_name}"
    associate_public_ip_address = true

    tags {
        Name = "bastion"
    }
}

// run clean image and apply ansible-playbook to install web-app. 
resource "aws_instance" "web_server_clean" {
    ami           = "${data.aws_ami.ubuntu.id}"
    instance_type  = "${var.instance_size}"
    vpc_security_group_ids = ["${aws_security_group.ssh_access_bastion.id}","${aws_security_group.public_egress.id}"]
    subnet_id = "${aws_subnet.public-subnet.0.id}"
    key_name = "${aws_key_pair.keypair.key_name}"
    associate_public_ip_address = true

    tags {
        Name = "web_server_clean"
    }
    provisioner "local-exec" {
       command = <<CMD
       sleep 30 \
       && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ubuntu  -i ${aws_instance.web_server_clean.public_ip}, --private-key ${aws_key_pair.keypair.key_name} ansible-playbooks/web-server.yaml
       CMD
    }

}

// Create AMI from the configured web_server_clean instance
resource "aws_ami_from_instance" "template_ami" {
  name               = "r42-template"
  source_instance_id = "${aws_instance.web_server_clean.id}"
}


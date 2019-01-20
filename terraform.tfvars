
public_subnets           = {
    eu-central-1a = "10.0.0.0/24"
    eu-central-1b = "10.0.2.0/24"
    eu-central-1c = "10.0.4.0/24"
  }
private_subnets           = {
    eu-central-1a = "10.0.1.0/24"
    eu-central-1b = "10.0.3.0/24"
    eu-central-1c = "10.0.5.0/24"
  }
public_key_path = "files/r42-key.pub"

certificate_body = "${file("${path.module}/files/cert1.pem")}"
certificate_chain = "${file("${path.module}/files/fullchain1.pem")}"
private_key = "${file("${path.module}/files/privkey1.pem")}"



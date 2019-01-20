variable "region" {
        default = "eu-central-1"
}

# variable "profile" {
#     description = "AWS credentials profile you want to use"
# }
variable "aws-akey" {}
variable "aws-skey" {}
variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}


variable "public_subnets" {
  description = "A map of availability zones to CIDR blocks, which will be set up as subnets."
  type = "map"
}
variable "private_subnets" {
  description = "A map of availability zones to CIDR blocks, which will be set up as subnets."
  type = "map"
}
variable "web_server_count" {
  description = "The number of web servers to run"
  type = "string"
  default = "3"
}

variable "public_key_path" {
  description = "The local public key path, e.g. ~/.ssh/id_rsa.pub"
  type = "string"
  default = ""
}
variable "instance_size" {
        default = "t2.micro"
}
variable "image_id" {
        description = "The ami-id of the customised image: with configured web-server"
        default = "ami-0d343041850cc1d9f"
}
variable "dns_name" {
        description = "DNS name to be registered on Cloudflare"
        default = "www"
}
variable "domain" {
        description = "DNS zone to register dns_name"
        default = "example.com"
}
variable "corporate_subnet" {
        description = "List of allowed IPs, subnets to connect to Bastion host"
        default = ["0.0.0.0/0"]
}
variable "cf-email" {
  description = "The email for Cloudflare login"
}
variable "cf-token" {
  description = "The token for Cloudflare login"
}
variable "certificate_body" {
  description = "The body of already generated certificate"
  default = "cert.pem"
}
variable "certificate_chain" {
  description = "The body of already generated certificate"
  default = "fullchain1.pem"
}
variable "private_key" {
  description = "The key of already generated certificate"
  default = "privkey1.pem"
}

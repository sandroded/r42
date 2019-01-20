output "alb-dns" {
    value = "${aws_alb.cluster-alb.dns_name}"
}

output "application-url" {
    value = "https://${var.dns_name}.${var.domain}/hello"
}

output "bastion-ip" {
    value = "ssh -A ubuntu@${aws_instance.bastion.public_ip}"
}
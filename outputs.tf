output "alb-dns" {
    value = "${aws_alb.cluster-alb.dns_name}"
}

output "dns-fqdn" {
    value = "${cloudflare_record.dns_record.hostname}"
}
output "bastion-ip" {
    value = "ssh -A ubuntu@${aws_instance.bastion.public_ip}"
}
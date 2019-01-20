resource "aws_acm_certificate" "cert" {
  domain_name       = "${var.dns_name}.${var.domain}"
  validation_method = "DNS"
}
 
resource "aws_route53_record" "cert_validation_dns_record" {
  name    = "${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"
  type    = "CNAME"
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  records = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}
 
resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${aws_acm_certificate.cert.domain_validation_options.0.resource_record_name}"]
}
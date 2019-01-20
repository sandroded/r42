//  A keypair for SSH access to the instances.
resource "aws_key_pair" "keypair" {
  key_name   = "r42-key"
  public_key = "${file(var.public_key_path)}"
}
//  Create the master userdata script.
data "template_file" "userdata" {
  template = "${file("${path.module}/files/userdata.sh")}"
}

//  A Launch Configuration for cluster instances.
resource "aws_launch_configuration" "cluster_node" {

  name_prefix   = "r42-alc-"
  image_id                    = "${aws_ami_from_instance.template_ami.id}"
  instance_type               = "${var.instance_size}"

  //  Recommended for auto-scaling groups and launch configurations.
  lifecycle {
    create_before_destroy = true
  }


  security_groups = [
    "${aws_security_group.ingress_http_8080.id}","${aws_security_group.ssh_access_from_bastion.id}"
  ]

  user_data                   = "${data.template_file.userdata.rendered}"
  key_name = "${aws_key_pair.keypair.key_name}"
}

resource "aws_autoscaling_group" "cluster_node" {
  name                        = "r42-asg"
  min_size                    = "${var.web_server_count}"
  max_size                    = "${var.web_server_count}"
  desired_capacity            = "${var.web_server_count}"
  vpc_zone_identifier         = ["${aws_subnet.private-subnet.*.id}"]
  launch_configuration        = "${aws_launch_configuration.cluster_node.name}"
  health_check_type           = "ELB"

  //  Recommended for auto-scaling groups and launch configurations.
  lifecycle {
    create_before_destroy = true
  }
}

# A load balancer for the cluster.
resource "aws_alb" "cluster-alb" {
    name                = "r42-alb"
    security_groups     = [
      "${aws_security_group.public_ingress.id}",
      "${aws_security_group.http_8080_to_intra.id}"
    ]
    subnets             = ["${aws_subnet.public-subnet.*.id}"]
}

// target group which makes health checks to /hello 
resource "aws_alb_target_group" "web" {
  name     = "r42-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"
  health_check { 
    healthy_threshold   = 3    
    unhealthy_threshold = 10    
    timeout             = 5    
    interval            = 10    
    path  = "/hello"
  }
}



// HTTP listener for ALB
# resource "aws_alb_listener" "web_listener" {  
#   load_balancer_arn = "${aws_alb.cluster-alb.arn}"  
#   port              = 80  
#   protocol          = "HTTP"
  
#   default_action {    
#     target_group_arn = "${aws_alb_target_group.web.arn}"
#     type             = "forward"  
#   }
# }
resource "aws_alb_listener" "web_listener" {  
  load_balancer_arn = "${aws_alb.cluster-alb.arn}"  
  port              = 443  
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  # certificate_arn   = "${aws_iam_server_certificate.cert.arn}"
  certificate_arn   = "${aws_acm_certificate_validation.cert_validation.certificate_arn}"
  default_action {    
    target_group_arn = "${aws_alb_target_group.web.arn}"
    type             = "forward"  
  }
}
# resource "aws_iam_server_certificate" "cert" {
#   name             = "test_cert"
#   certificate_body = "${var.certificate_body}"
#   private_key      = "${var.private_key}"
#   certificate_chain = "${var.certificate_chain}"
#   lifecycle {
#     create_before_destroy = true
#   }
# }

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "web-attachment" {
  autoscaling_group_name = "${aws_autoscaling_group.cluster_node.id}"
  alb_target_group_arn   = "${aws_alb_target_group.web.arn}"
}

// Proxied Cloudflare record to hide infra details. 
# resource "cloudflare_record" "dns_record" {
#     domain = "${var.domain}"
#     name   = "${var.dns_name}"
#     value  = "${aws_alb.cluster-alb.dns_name}"
#     type   = "CNAME"
#     ttl    = 1
#     proxied = true
# }
data "aws_route53_zone" "primary" {
  name         = "${var.domain}."
  # private_zone = true
}
resource "aws_route53_record" "alb" {
  zone_id = "${data.aws_route53_zone.primary.zone_id}"
  name    = "${var.dns_name}.${var.domain}"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_alb.cluster-alb.dns_name}"]
}
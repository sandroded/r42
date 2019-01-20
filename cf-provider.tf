provider "cloudflare" {
    email = "${var.cf-email}"
    token = "${var.cf-token}"
}
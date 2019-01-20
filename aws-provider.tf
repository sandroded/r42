provider "aws" {
    # profile = "${var.profile}"
    access_key = "${var.aws-akey}"
    secret_key = "${var.aws-skey}"
    region = "${var.region}"
}
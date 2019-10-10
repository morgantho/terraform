provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {}
}


resource "aws_vpc" "vpc" {
    cidr_block            = "${var.vpc_cidr}"
    enable_dns_hostnames  = true
    enable_dns_support    = true
}

resource "aws_subnet" "subnets" {
    vpc_id                    = "${aws_vpc.vpc.id}"
    count                     = "${length(var.subnet_cidr)}"
    cidr_block                = "${element(var.subnet_cidr, count.index)}"
    availability_zone         = "${element(var.availablity_zones, count.index)}"
    map_public_ip_on_launch   = "${var.public_ip_response}"
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"
}


resource "aws_route_table" "route_table" {
    vpc_id = "${aws_vpc.vpc.id}"

    route = {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
    }
}

resource "aws_route_table_association" "route_table_association" {
    route_table_id  = "${aws_route_table.route_table.id}"
    subnet_id       = "${aws_subnet.subnets.0.id}"
}


resource "aws_network_acl" "network_acl" {
    vpc_id    = "${aws_vpc.vpc.id}"
    subnet_ids = ["${aws_subnet.subnets.*.id}"]

    ingress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
}

egress {
    from_port  = 0
    to_port    = 0
    rule_no    = 100
    action     = "allow"
    protocol   = "-1"
    cidr_block = "0.0.0.0/0"
 }
}

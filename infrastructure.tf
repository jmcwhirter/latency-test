provider "aws" {
  region     = "us-east-1"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["137112412989"] #Amazon Linux
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_instance" "pinger" {
  ami                         = "${data.aws_ami.amazon-linux-2.id}"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  key_name                    = "aws-us-east-1"
  user_data                   = "${file("userdata_datadog.sh")}"
}

resource "aws_instance" "netdata" {
  ami                         = "${data.aws_ami.amazon-linux-2.id}"
  instance_type               = "t3.medium"
  associate_public_ip_address = true
  key_name                    = "aws-us-east-1"
  user_data                   = "${file("userdata_netdata.sh")}"
  tags                        = {
                                  Name = "Netdata"
                                }
}

output "netdata-ip" {
  value = "${aws_instance.netdata.public_ip}"
}

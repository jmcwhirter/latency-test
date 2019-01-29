provider "aws" {
  region     = "us-east-1"
}

variable "azs" {
  description = "Run the EC2 Instances in these Availability Zones"
  type = "list"
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
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

data "template_file" "netdata_master" {
  template = "${file("userdata_netdata_master.sh.tpl")}"

  vars {
    host_names = "${join(" ", aws_instance.netdata_slave.*.availability_zone)}"
    host_entries = "${join("\n", formatlist("%s %s", aws_instance.netdata_slave.*.private_ip, aws_instance.netdata_slave.*.availability_zone))}"
  }
}

# resource "random_uuid" "guuid" { }

resource "aws_instance" "netdata_master" {
  ami                         = "${data.aws_ami.amazon-linux-2.id}"
  availability_zone           = "us-east-1a"
  instance_type               = "t3.medium"
  associate_public_ip_address = true
  key_name                    = "aws-us-east-1"
  user_data                   = "${data.template_file.netdata_master.rendered}"
  tags                        = {
                                  Name = "Netdata master"
                                }
}

resource "aws_instance" "netdata_slave" {
  count                       = 6
  ami                         = "${data.aws_ami.amazon-linux-2.id}"
  availability_zone           = "${element(var.azs, count.index)}"
  instance_type               = "t2.micro"
  # associate_public_ip_address = true
  key_name                    = "aws-us-east-1"
  # user_data                   = "${file("userdata_netdata_slave.sh")}"
  tags                        = {
                                  Name = "Netdata slave ${count.index}"
                                }
}

output "netdata-master-ip" {
  value = "${aws_instance.netdata_master.public_ip}"
}

# output "netdata-slave-ips" {
#   value = "${aws_instance.netdata_slave.*.public_ip}"
# }

# output "guid" {
#   value = "${random_uuid.guuid.result}"
# }


data "template_file" "server1_userdata" {
  template = "${file("${path.module}/userdata/server.userdata")}"
  vars {
    hostname = "${var.sid}${count.index + 1}server1"
  }
}

resource "aws_instance" "server1" {
  count                  = "${var.lab_count}"
  ami                    = "${lookup(var.ami_centos, var.aws_region)}"
  availability_zone      = "${lookup(var.aws_az, var.aws_region)}"
  instance_type          = "t2.medium"
  key_name               = "${var.internal_key_name}"
  vpc_security_group_ids = ["${element(aws_security_group.privsg.*.id, count.index)}"]
  subnet_id              = "${element(aws_subnet.PoolNet.*.id, count.index)}"
  private_ip             = "172.16.2.21"
  source_dest_check      = false
  user_data              = "${data.template_file.server1_userdata.rendered}"
  depends_on             = ["aws_nat_gateway.ngw"]

  tags {
    Name = "${var.sid}${count.index + 1}server1"
    Owner = "${var.owner}"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = "${var.instance_volume_size}"
    delete_on_termination = "true"
  }
}

data "template_file" "server2_userdata" {
  template = "${file("${path.module}/userdata/server.userdata")}"
  vars {
    hostname = "${var.sid}${count.index + 1}server2"
  }
}

resource "aws_instance" "server2" {
  count                  = "${var.lab_count}"
  ami                    = "${lookup(var.ami_centos, var.aws_region)}"
  availability_zone      = "${lookup(var.aws_az, var.aws_region)}"
  instance_type          = "t2.medium"
  key_name               = "${var.internal_key_name}"
  vpc_security_group_ids = ["${element(aws_security_group.privsg.*.id, count.index)}"]
  subnet_id              = "${element(aws_subnet.PoolNet.*.id, count.index)}"
  private_ip             = "172.16.2.22"
  source_dest_check      = false
  user_data              = "${data.template_file.server2_userdata.rendered}"
  depends_on             = ["aws_nat_gateway.ngw"]

  tags {
    Name = "${var.sid}${count.index + 1}server2"
    Owner = "${var.owner}"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = "${var.instance_volume_size}"
    delete_on_termination = "true"
  }
}

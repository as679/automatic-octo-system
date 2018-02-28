resource "aws_network_interface" "ctrl_publicnic" {
  count             = "${var.lab_count}"
  subnet_id         = "${element(aws_subnet.pubnet.*.id, count.index)}"
  #private_ips       = ["172.16.1.5"]
  security_groups   = ["${element(aws_security_group.pubsg.*.id, count.index)}"]
  source_dest_check = false
  depends_on = ["aws_instance.ctrl"]
  attachment {
    instance     = "${element(aws_instance.ctrl.*.id, count.index)}"
    device_index = 2
  }
  tags {
    Name = "${var.sid}${count.index + 1}ctrl_publicnic"
  }
}

resource "aws_eip" "ctrl_eip" {
  count = "${var.lab_count}"
  vpc                       = true
  network_interface         = "${element(aws_network_interface.ctrl_publicnic.*.id, count.index)}"
}

resource "aws_instance" "ctrl" {
  count                  = "${var.lab_count}"
  ami                    = "${lookup(var.ami_avi_controller, var.aws_region)}"
  availability_zone      = "${lookup(var.aws_az, var.aws_region)}"
  instance_type          = "m4.xlarge"
  key_name               = "${var.internal_key_name}"
  vpc_security_group_ids = ["${element(aws_security_group.privsg.*.id, count.index)}"]
  subnet_id              = "${element(aws_subnet.Management.*.id, count.index)}"
  private_ip             = "172.16.1.11"
  source_dest_check      = false
  user_data              = "${file("${path.module}/userdata/ctrl.userdata")}"

  tags {
    Name = "${var.sid}${count.index + 1}controller"
    Owner = "${var.owner}"
  }
}

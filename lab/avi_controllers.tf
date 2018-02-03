
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

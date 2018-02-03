
resource "aws_security_group" "pubsg" {
  count = "${var.lab_count}"
  description = "Allow incoming connections."
  vpc_id      = "${element(aws_vpc.student.*.id, count.index)}"

  tags {
    Name = "${var.sid}${count.index + 1}_pubsg"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "jumpbox_userdata" {
  template = "${file("${path.module}/userdata/jumpbox.userdata")}"
  vars {
    hostname = "${var.sid}${count.index + 1}jumpbox"
    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
    aws_region = "${var.aws_region}"
    pkey = "${var.pkey_training_internal}"
  }
}

resource "aws_network_interface" "jump_mgmtnic" {
  count             = "${var.lab_count}"
  subnet_id         = "${element(aws_subnet.Management.*.id, count.index)}"
  private_ips       = ["172.16.1.5"]
  security_groups   = ["${element(aws_security_group.privsg.*.id, count.index)}"]
  source_dest_check = false
  depends_on = ["aws_instance.jump"]
  attachment {
    instance     = "${element(aws_instance.jump.*.id, count.index)}"
    device_index = 1
  }
  tags {
    Name = "${var.sid}${count.index + 1}jumpbox_mgmtnic"
  }
}

resource "aws_instance" "jump" {
  count = "${var.lab_count}"
  ami                         = "${lookup(var.ami_centos, var.aws_region)}"
  availability_zone           = "${lookup(var.aws_az, var.aws_region)}"
  instance_type               = "${var.instance_flavour}"
  key_name                    = "${var.access_key_name}"
  vpc_security_group_ids      = ["${element(aws_security_group.pubsg.*.id, count.index)}"]
  subnet_id                   = "${element(aws_subnet.pubnet.*.id, count.index)}"
  associate_public_ip_address = true
  source_dest_check           = false
  user_data                   = "${data.template_file.jumpbox_userdata.rendered}"
  depends_on                  = ["aws_internet_gateway.igw"]

  tags {
    Name = "${var.sid}${count.index + 1}jumpbox"
    Owner = "${var.owner}"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = "${var.instance_volume_size}"
    delete_on_termination = "true"
  }
}

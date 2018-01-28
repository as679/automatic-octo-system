
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
  #user_data                   = "${file("${path.module}/userdata/jumpbox.userdata")}"
  depends_on                  = ["aws_internet_gateway.igw"]

  tags {
    Name = "${var.sid}${count.index + 1}_JumpHost"
    Owner = "${var.owner}"
  }

  root_block_device {
    volume_type           = "standard"
    volume_size           = "${var.instance_volume_size}"
    delete_on_termination = "true"
  }
}

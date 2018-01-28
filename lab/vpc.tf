resource "aws_vpc" "student" {
  count = "${var.lab_count}"
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "${var.sid}${count.index + 1}"
  }
}

resource "aws_subnet" "pubnet" {
  count = "${var.lab_count}"
  vpc_id = "${element(aws_vpc.student.*.id, count.index)}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, 0)}"
  availability_zone = "${lookup(var.aws_az, var.aws_region)}"

  tags {
    Name = "${var.sid}${count.index + 1}_PublicNetwork"
  }
}

resource "aws_internet_gateway" "igw" {
  count = "${var.lab_count}"
  vpc_id = "${element(aws_vpc.student.*.id, count.index)}"

  tags {
    Name = "${var.sid}${count.index + 1}_igw"
  }
}

resource "aws_route_table" "pubrt" {
  count = "${var.lab_count}"
  vpc_id = "${element(aws_vpc.student.*.id, count.index)}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${element(aws_internet_gateway.igw.*.id, count.index)}"
  }

  tags {
    Name = "${var.sid}${count.index + 1}_pubrt"
  }
}

resource "aws_route_table_association" "pubrta" {
  count = "${var.lab_count}"
  subnet_id      = "${element(aws_subnet.pubnet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.pubrt.*.id, count.index)}"
}

#privnet.0 172.16.1.0/24
#privnet.1 172.16.2.0/24
#privnet.2 172.16.3.0/24
#etc...
resource "aws_subnet" "Management" {
  count             = "${var.lab_count}"
  vpc_id            = "${element(aws_vpc.student.*.id, count.index)}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, 1)}"
  availability_zone = "${lookup(var.aws_az, var.aws_region)}"

  tags {
    Name = "${var.sid}${count.index + 1}_Managment"
  }
}

resource "aws_subnet" "PoolNet" {
  count             = "${var.lab_count}"
  vpc_id            = "${element(aws_vpc.student.*.id, count.index)}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, 2)}"
  availability_zone = "${lookup(var.aws_az, var.aws_region)}"

  tags {
    Name = "${var.sid}${count.index + 1}_PoolNet"
  }
}

resource "aws_subnet" "VSNet" {
  count             = "${var.lab_count}"
  vpc_id            = "${element(aws_vpc.student.*.id, count.index)}"
  cidr_block        = "${cidrsubnet(var.vpc_cidr, 8, 3)}"
  availability_zone = "${lookup(var.aws_az, var.aws_region)}"

  tags {
    Name = "${var.sid}${count.index + 1}_VSNet"
  }
}

resource "aws_eip" "snat" {
  count = "${var.lab_count}"
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  count = "${var.lab_count}"
  allocation_id = "${element(aws_eip.snat.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.pubnet.*.id, count.index)}"

  tags {
    Name = "${var.sid}${count.index + 1}_ngw"
  }
}

resource "aws_route_table" "privrt" {
  count = "${var.lab_count}"
  vpc_id = "${element(aws_vpc.student.*.id, count.index)}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.ngw.*.id, count.index)}"
  }

  tags {
    Name = "${var.sid}${count.index + 1}_privrt"
  }
}

resource "aws_route_table_association" "privrta1" {
  count          = "${var.lab_count}"
  subnet_id      = "${element(aws_subnet.Management.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.privrt.*.id, count.index)}"
}

resource "aws_route_table_association" "privrta2" {
  count          = "${var.lab_count}"
  subnet_id      = "${element(aws_subnet.PoolNet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.privrt.*.id, count.index)}"
}

resource "aws_route_table_association" "privrta3" {
  count          = "${var.lab_count}"
  subnet_id      = "${element(aws_subnet.VSNet.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.privrt.*.id, count.index)}"
}

resource "aws_security_group" "privsg" {
  count = "${var.lab_count}"
  description = "Allow incoming / outgoing connections."
  vpc_id      = "${element(aws_vpc.student.*.id, count.index)}"

  tags {
    Name = "${var.sid}${count.index + 1}_privsg"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = "true"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

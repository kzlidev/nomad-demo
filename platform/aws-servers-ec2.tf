resource "aws_instance" "nomad_servers" {
  count = 3

  ami                         = data.aws_ami.this.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  # Server private IP address will be first usable IP in each subnet
  # "10.0.1.4", "10.0.2.4", "10.0.3.4"
  private_ip             = "10.0.${count.index + 1}.4"
  subnet_id              = aws_subnet.public_subnets[count.index].id
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    Name    = "${var.prefix}-nomad-server-${count.index + 1}"
    Purpose = "nomad-cluster"
  }

  user_data = templatefile("${path.module}/script/server-userdata.tftpl", {
    instance_name = "${var.prefix}-nomad-server-${count.index + 1}"
    private_ip    = "10.0.${count.index + 1}.4"
    tag_key       = "Purpose"
    tag_value     = "nomad-cluster"
  })
}

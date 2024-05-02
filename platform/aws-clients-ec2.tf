resource "aws_instance" "nomad_clients" {
  count = 3

  ami                         = data.aws_ami.this.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name

  private_ip             = "10.0.${count.index + 1}.10"
  subnet_id              = aws_subnet.public_subnets[count.index].id
  vpc_security_group_ids = [data.aws_security_group.default.id]

  tags = {
    Name    = "${var.prefix}-nomad-client-${count.index + 1}"
    Purpose = "nomad-cluster"
  }

  user_data = templatefile("${path.module}/script/client-userdata.tftpl", {
    instance_name = "${var.prefix}-nomad-client-${count.index + 1}"
    private_ip    = "10.0.${count.index + 1}.10"
    tag_key       = "Purpose"
    tag_value     = "nomad-cluster"
  })
}

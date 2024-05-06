resource "aws_launch_template" "webapp" {
  name_prefix            = "${var.prefix}-launch-template"
  image_id               = data.aws_ami.this.id
  instance_type          = "t3.micro"
  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.instance_profile.arn
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [data.aws_security_group.default.id]
  }

  tags = {
    Name    = "${var.prefix}-nomad-client"
    Purpose = "nomad-cluster"
  }

  user_data = base64encode(
    templatefile("${path.module}/script/client-userdata.tftpl", {
      tag_key                          = "Purpose"
      tag_value                        = "nomad-cluster"
      purpose                          = "application"
      ca_crt_content                   = file("${path.module}/certs/ca.crt")
      nomad_cert_content               = file("${path.module}/certs/nomad-client.crt")
      nomad_key_content                = file("${path.module}/certs/nomad-client.key")
      update_certificate_store_s3_path = "s3://${aws_s3_bucket_object.file_upload.bucket}/${aws_s3_bucket_object.file_upload.key}"
    })
  )
}

resource "aws_autoscaling_group" "webapp" {
  target_group_arns   = [aws_lb_target_group.webapp.arn]
  vpc_zone_identifier = [for subnet in aws_subnet.public_subnets : subnet.id]
  desired_capacity    = 3
  max_size            = 5
  min_size            = 3

  launch_template {
    id      = aws_launch_template.webapp.id
    version = aws_launch_template.webapp.latest_version
  }
}

#resource "aws_instance" "nomad_clients" {
#  count = 3
#
#  ami                         = data.aws_ami.this.id
#  instance_type               = "t3.micro"
#  associate_public_ip_address = true
#  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
#
#  private_ip             = "10.0.${count.index + 1}.10"
#  subnet_id              = aws_subnet.public_subnets[count.index].id
#  vpc_security_group_ids = [data.aws_security_group.default.id]
#
#  tags = {
#    Name    = "${var.prefix}-nomad-client-${count.index + 1}"
#    Purpose = "nomad-cluster"
#  }
#
#  user_data = templatefile("${path.module}/script/client-userdata.tftpl", {
#    instance_name = "${var.prefix}-nomad-client-${count.index + 1}"
#    private_ip    = "10.0.${count.index + 1}.10"
#    tag_key       = "Purpose"
#    tag_value     = "nomad-cluster"
#    purpose       = "application"
#  })
#}
#
#resource "aws_instance" "nomad_lb_clients" {
#  count = 1
#
#  ami                         = data.aws_ami.this.id
#  instance_type               = "t3.micro"
#  associate_public_ip_address = true
#  iam_instance_profile        = aws_iam_instance_profile.instance_profile.name
#
#  private_ip             = "10.0.${count.index + 1}.100"
#  subnet_id              = aws_subnet.public_subnets[count.index].id
#  vpc_security_group_ids = [data.aws_security_group.default.id]
#
#  tags = {
#    Name    = "${var.prefix}-nomad-lb-client-${count.index + 1}"
#    Purpose = "nomad-cluster"
#  }
#
#  user_data = templatefile("${path.module}/script/client-userdata.tftpl", {
#    instance_name = "${var.prefix}-nomad-lb-client-${count.index + 1}"
#    private_ip    = "10.0.${count.index + 1}.100"
#    tag_key       = "Purpose"
#    tag_value     = "nomad-cluster"
#    purpose       = "load-balancer"
#  })
#}

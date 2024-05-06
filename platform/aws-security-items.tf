data "aws_security_group" "default" {
  name   = "default"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "allow_all_internal" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = data.aws_security_group.default.id
  security_group_id        = data.aws_security_group.default.id
}

resource "aws_security_group_rule" "http_from_all" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.default.id
}

resource "aws_security_group_rule" "https_from_all" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.default.id
}

resource "aws_security_group_rule" "nomad_ui_from_all" {
  type              = "ingress"
  from_port         = 4646
  to_port           = 4646
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = data.aws_security_group.default.id
}

resource "aws_security_group_rule" "ssh_from_ic" {
  type              = "ingress"
  description       = "AWS Instance Connect IP Address (ap-southeast-1)"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["3.0.5.32/29"]
  security_group_id = data.aws_security_group.default.id
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance_role" {
  name               = "${var.prefix}-instance-role"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.prefix}-instasnce-profile"
  role = aws_iam_role.instance_role.name
}

resource "aws_iam_policy" "instance_policy" {
  name        = "${var.prefix}-instance-policy"
  path        = "/"
  description = "Policy for Nomad Instances"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action = [
          "s3:*",
        ]
        Effect   = "Allow"
        Resource = [
          aws_s3_bucket.my_bucket.arn,
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "server_role_attachment" {
  policy_arn = aws_iam_policy.instance_policy.arn
  role       = aws_iam_role.instance_role.name
}
resource "aws_lb" "webapp_lb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.default.id]
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "webapp" {
  name     = "${var.prefix}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "webapp" {
  load_balancer_arn = aws_lb.webapp_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp.arn
  }
}

#resource "aws_autoscaling_attachment" "example" {
#  autoscaling_group_name = aws_autoscaling_group.webapp.id
#  lb_target_group_arn    = aws_lb_target_group.webapp.arn
#}

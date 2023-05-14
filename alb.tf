resource "aws_lb" "Project-alb" {
  name               = "Project-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.Project-pubsub1.id, aws_subnet.Project-pubsub2.id]

  security_groups = [
    aws_security_group.Project-alb-sg.id,
  ]

  tags = {
    Name = "Project-alb-sg"
  }
}

resource "aws_lb_listener" "Project-http-listener" {
  load_balancer_arn = aws_lb.Project-alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.Project-launch-template.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "Project-launch-template" {
  name        = "Project-launch-template"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.Project-vpc.id

  health_check {
    healthy_threshold   = 2
    interval            = 30
    protocol            = "HTTP"
    timeout             = 10
    unhealthy_threshold = 5
    path                = "/"
    matcher             = "200"
  }

  depends_on = [aws_lb.Project-alb]
}
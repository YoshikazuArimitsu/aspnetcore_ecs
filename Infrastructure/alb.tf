
resource "aws_security_group" "alb" {
  name        = "${var.prefix}-alb-sg"
  description = "sg for ${var.prefix}-alb"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "allow_https_for_alb" {
  security_group_id = aws_security_group.alb.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "${var.prefix}-alb-ingress"
}

resource "aws_lb" "alb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.alb.id
  ]
  subnets = local.public_subnets
}

resource "aws_lb_target_group" "alb" {
  name                 = "${var.prefix}-albtg"
  port                 = "80"
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.vpc.id
  deregistration_delay = "60"

  health_check {
    interval            = "300"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "10"
    healthy_threshold   = "2"
    unhealthy_threshold = "10"
    matcher             = "200-302"
  }
}

resource "aws_alb_listener" "alb_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.alb.arn
    type             = "forward"
  }
}

# resource "aws_alb_listener" "alb_https" {
#   load_balancer_arn = aws_lb.alb.arn
#   certificate_arn   = var.cert_arn
#   port              = 443
#   protocol          = "HTTPS"
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

#   default_action {
#     target_group_arn = aws_lb_target_group.alb.arn
#     type             = "forward"
#   }
# }

# resource "aws_alb_listener_certificate" "cert" {
#   listener_arn    = aws_alb_listener.alb_https.arn
#   certificate_arn = var.cert_arn
# }

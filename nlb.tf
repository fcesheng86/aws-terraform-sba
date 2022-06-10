#nic-nlb-test-91497c178c6f7cfc.elb.us-east-1.amazonaws.com
resource "aws_lb" "nic_front_nlb" {
  depends_on         = [aws_subnet.public_subnets]
  name               = "Nic-Frontend-NLB-TF"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_subnets["tf_public_subnet_1"].id, aws_subnet.public_subnets["tf_public_subnet_2"].id]

  tags = {
    Environment = "production"
    Terraform   = "true"
    Type        = "frontend"
  }
}

resource "aws_lb" "nic_api_nlb" {
  depends_on         = [aws_subnet.public_subnets]
  name               = "Nic-Api-NLB-TF"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_subnets["tf_public_subnet_1"].id, aws_subnet.public_subnets["tf_public_subnet_2"].id]

  tags = {
    Environment = "production"
    Terraform   = "true"
    Type        = "api"
  }
}

#Target Groups for ports 80 and 8080
resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg-nic-tf"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group" "api_tg" {
  name     = "api-tg-nic-tf"
  port     = 8080
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id
}

#Listener for Frontend NLB - 80 & HTTPS
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.nic_front_nlb.arn
  port              = "80"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

resource "aws_lb_listener" "https_frontend_listener" {
  depends_on = [
    aws_acm_certificate.cert1
  ]
  load_balancer_arn = aws_lb.nic_front_nlb.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate.cert1.arn
  alpn_policy       = "None"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

#Listener for Frontend NLB - 8080 & HTTPS

resource "aws_lb_listener" "api_listener" {
  load_balancer_arn = aws_lb.nic_api_nlb.arn
  port              = "8080"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
}

resource "aws_lb_listener" "https_api_listener" {
  depends_on = [
    aws_acm_certificate.cert2
  ]
  load_balancer_arn = aws_lb.nic_api_nlb.arn
  port              = "443"
  protocol          = "TLS"
  certificate_arn   = aws_acm_certificate.cert2.arn
  alpn_policy       = "None"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
}


output "nlb_dns" {
  description = "DNS of NLB created"
  value       = aws_lb.nic_api_nlb.dns_name
}

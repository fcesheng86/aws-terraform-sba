data "aws_route53_zone" "main" {
  name = "cloudtech-training.com"
}

resource "aws_route53_record" "frontend_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "jupiterfrontendnlb.cloudtech-training.com"
  type    = "A"

  alias {
    name                   = aws_lb.nic_front_nlb.dns_name
    zone_id                = aws_lb.nic_front_nlb.zone_id
    evaluate_target_health = false
  }

}

resource "aws_route53_record" "apiserver_record" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = "jupiterapinlb.cloudtech-training.com"
  type    = "A"

  alias {
    name                   = aws_lb.nic_api_nlb.dns_name
    zone_id                = aws_lb.nic_api_nlb.zone_id
    evaluate_target_health = false
  }

}


resource "aws_acm_certificate" "cert1" {
  domain_name       = "jupiterfrontendnlb.cloudtech-training.com"
  validation_method = "DNS"

  tags = {
    Environment = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate" "cert2" {
  domain_name       = "jupiterapinlb.cloudtech-training.com"
  validation_method = "DNS"

  tags = {
    Environment = "Terraform"
  }

  lifecycle {
    create_before_destroy = true
  }
}

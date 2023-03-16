data "aws_route53_zone" "hosted_zone" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "a_record" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = data.aws_route53_zone.hosted_zone.name
  type    = "A"
  ttl     = "60"
  records = var.webapp_server_public_ip
}

output "zone_id" {
  value = data.aws_route53_zone.hosted_zone.id
}
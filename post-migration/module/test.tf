variable "vpc_id" {
    type = string
}

variable "ingress_ssh" {
    type = map(any)
}

resource "aws_security_group" "test" {
    name                   = "test"
    vpc_id                 = var.vpc_id
    revoke_rules_on_delete = true
}

resource "aws_security_group_rule" "egress_to_all" {
    security_group_id = aws_security_group.test.id
    description       = "Allow egress to all"
    type              = "egress"
    protocol          = "-1"
    from_port         = 0
    to_port           = 0
    cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ingress_ssh" {
    for_each = var.ingress_ssh

    security_group_id        = aws_security_group.test.id
    description              = "Allow ingress ssh from ${each.key}"
    type                     = "ingress"
    protocol                 = "tcp"
    from_port                = 22
    to_port                  = 22
    source_security_group_id = each.value
}
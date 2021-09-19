terraform {
    required_providers {
    aws = {
        source  = "hashicorp/aws"
        version = "~> 3.57"
        }
    }
}

# Configure the AWS Provider
provider "aws" {
    region = "eu-west-1"
}

resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "test" {
    name                   = "test"
    vpc_id                 = aws_vpc.main.id
    revoke_rules_on_delete = true
}

resource "aws_security_group" "test2" {
    name                   = "test2"
    vpc_id                 = aws_vpc.main.id
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

resource "aws_security_group_rule" "ingress_ssh_bastion" {
    security_group_id        = aws_security_group.test.id
    description              = "Allow ingress ssh from the bastion"
    type                     = "ingress"
    protocol                 = "tcp"
    from_port                = 22
    to_port                  = 22
    source_security_group_id = aws_security_group.test2.id
}







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

resource "aws_security_group" "test2" {
    name                   = "test2"
    vpc_id                 = aws_vpc.main.id
    revoke_rules_on_delete = true
}

variable "module_enable" {
    type = bool 
    default = false
}

module "test" {
    count  = var.module_enable ? 1 : 0

    source = "./module"

    vpc_id = aws_vpc.main.id

    ingress_ssh = {
        item1 = aws_security_group.test2.id
    }
    
}
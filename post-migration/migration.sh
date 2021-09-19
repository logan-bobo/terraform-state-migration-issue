#!/bin/bash

terraform init 
cp ../pre-migration/terraform.tfstate ./

terraform state mv aws_security_group.test module.test[0].aws_security_group.test

terraform state mv aws_security_group_rule.egress_to_all module.test[0].aws_security_group_rule.egress_to_all

terraform state mv aws_security_group_rule.ingress_ssh_bastion module.test[0].aws_security_group_rule.ingress_ssh[\"item1\"]

terraform apply -auto-approve
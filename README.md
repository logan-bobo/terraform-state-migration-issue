# terraform-state-migration-issue

### The issue

Terraform will remove resrouce dependencies when running `terraform state mv source destination` therefore if you attempt to remove items post state migration terraformm will remove resources in an incorrect order producing a non zero exit code upon execution. 


### Reproducing the issue

please run the provided `issue.sh` for a one step reproduction

#### At a high level the actions to reproduce are 
 - Deploy base infrastructure found in `./pre-migration`
 - Run state migration script found in `./post-migration`
 - Run terraform apply in `./post-migration`

### Evidence

We can see in the pre migrated state our security group rule has an explicit dependency on the security group exisitng

```
{
"mode": "managed",
"type": "aws_security_group_rule",
"name": "gress_to_all",
"provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
"instances": [
    {
    "schema_version": 2,
    "attributes": {
        "cidr_blocks": [
        "0.0.0.0/0"
        ],
        "description": "Allow egress to all",
        "from_port": 0,
        "id": "sgrule-",
        "ipv6_cidr_blocks": null,
        "prefix_list_ids": null,
        "protocol": "-1",
        "security_group_id": "sg-",
        "self": false,
        "source_security_group_id": null,
        "to_port": 0,
        "type": "egress"
    },
    "sensitive_attributes": [],
    "private": "",
    "dependencies": [
        "aws_security_group.test",
        "aws_vpc.main"
    ]
    }
]
},
```

Then we run `terraform state mv x y` (command can be found in `post-migration/migration.sh`) items will loose their dependencies

```
    {
      "module": "module.test[0]",
      "mode": "managed",
      "type": "aws_security_group_rule",
      "name": "egress_to_all",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 2,
          "attributes": {
            "cidr_blocks": [
              "0.0.0.0/0"
            ],
            "description": "Allow egress to all",
            "from_port": 0,
            "id": "sgrule-",
            "ipv6_cidr_blocks": null,
            "prefix_list_ids": null,
            "protocol": "-1",
            "security_group_id": "sg-",
            "self": false,
            "source_security_group_id": null,
            "to_port": 0,
            "type": "egress"
          },
          "sensitive_attributes": [],
          "private": "=="
        }
      ]
    },
```

Now we have moved the resources to their new module and they have lost their dependenices. If the resource is set to be destroyed terraform apply will not execute cleanley as shown in the output below. This is because the security group is removed before the security group rule.

```
module.test[0].aws_security_group_rule.gress_to_all: Destroying... [id=sgrule-]
module.test[0].aws_security_group_rule.ingress_ssh["item1"]: Destroying... [id=sgrule-]
module.test[0].aws_security_group.test: Destroying... [id=sg-]
module.test[0].aws_security_group_rule.gress_to_all: Destruction complete after 0s
module.test[0].aws_security_group.test: Destruction complete after 1s
╷
│ Error: Error revoking security group sg- rules: InvalidPermission.NotFound: The specified rule does not exist in this security group.
│       status code: 400, request id: 10b7936d-fea1-414f-81eb-146edf08683e
│ 
│ 
╵
```

This is not the expected behaviour.






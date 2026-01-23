---
tags:
  - component/security-group
  - layer/network
  - provider/aws
---

# Component: `security-group`

This component provisions AWS Security Groups that can be shared across multiple components.
It is a thin wrapper around the `cloudposse/security-group/aws` module that integrates with the
Atmos stack configuration and remote state patterns.

## Usage

**Stack Level**: Regional

### Basic Configuration

```yaml
# catalog/security-group/defaults
components:
  terraform:
    security-group/defaults:
      metadata:
        type: abstract
        component: security-group
      vars:
        enabled: true
        allow_all_egress: true
```

```yaml
# catalog/security-group/lambda
import:
  - catalog/security-group/defaults

components:
  terraform:
    security-group/lambda:
      metadata:
        inherits:
          - security-group/defaults
      vars:
        name: "lambda"
        security_group_description: "Security group for Lambda functions"
        rules:
          - type: "egress"
            from_port: 0
            to_port: 0
            protocol: "-1"
            cidr_blocks: ["0.0.0.0/0"]
            ipv6_cidr_blocks: ["::/0"]
```

```yaml
# stacks/orgs/acme/plat/dev/us-east-2/network.yaml
import:
  - catalog/security-group/lambda

components:
  terraform:
    security-group/lambda:
      vars:
        enabled: true
```

### Providing VPC ID Directly

You can provide the VPC ID directly via the `vpc_id` variable, which overrides the remote state lookup:

```yaml
components:
  terraform:
    security-group/lambda:
      vars:
        # Provide VPC ID directly (overrides remote state lookup)
        vpc_id: "vpc-12345678"
```

This is useful when:
- The VPC was created outside of Atmos/Terraform
- You want to reference a VPC from a different state backend
- You're using Atmos functions like `!terraform.output` to fetch the VPC ID

### Using Rule Matrix for Complex Rules

The `rule_matrix` variable provides a convenient way to apply the same set of rules to multiple subjects:

```yaml
components:
  terraform:
    security-group/app:
      vars:
        name: "app"
        security_group_description: "Security group for application tier"
        rule_matrix:
          - source_security_group_ids:
              - "sg-111111111"
              - "sg-222222222"
            rules:
              - type: "ingress"
                from_port: 443
                to_port: 443
                protocol: "tcp"
```

### Referencing the Security Group from Other Components

Once deployed, other components can reference this security group via remote state:

```yaml
components:
  terraform:
    lambda/my-function:
      vars:
        vpc_config:
          security_group_ids:
            - '{{ atmos.Store "my-store" .stack "security-group/lambda" "security_group_id" }}'
```

<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | cloudposse/security-group/aws | 2.2.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.8.0 |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the Security Group will be created. If provided, this overrides the VPC ID from remote state lookup. | `string` | `null` | no |
| <a name="input_vpc_component_name"></a> [vpc\_component\_name](#input\_vpc\_component\_name) | The name of the VPC component to fetch remote state from | `string` | `"vpc"` | no |
| <a name="input_vpc_environment_name"></a> [vpc\_environment\_name](#input\_vpc\_environment\_name) | The name of the environment where the VPC component is provisioned. Defaults to the current environment. | `string` | `null` | no |
| <a name="input_vpc_stage_name"></a> [vpc\_stage\_name](#input\_vpc\_stage\_name) | The name of the stage where the VPC component is provisioned. Defaults to the current stage. | `string` | `null` | no |
| <a name="input_vpc_tenant_name"></a> [vpc\_tenant\_name](#input\_vpc\_tenant\_name) | The name of the tenant where the VPC component is provisioned. Defaults to the current tenant. | `string` | `null` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | The description to assign to the created Security Group. Warning: Changing the description causes the security group to be replaced. | `string` | `"Managed by Terraform"` | no |
| <a name="input_allow_all_egress"></a> [allow\_all\_egress](#input\_allow\_all\_egress) | A convenience that adds to the rules specified elsewhere a rule that allows all egress. | `bool` | `true` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | A list of Security Group rule objects. | `list(any)` | `[]` | no |
| <a name="input_rules_map"></a> [rules\_map](#input\_rules\_map) | A map-like object of lists of Security Group rule objects. | `any` | `{}` | no |
| <a name="input_rule_matrix"></a> [rule\_matrix](#input\_rule\_matrix) | A convenient way to apply the same set of rules to a set of subjects. | `any` | `[]` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | The name to assign to the created security group. Must be unique within the VPC. | `list(string)` | `[]` | no |
| <a name="input_target_security_group_id"></a> [target\_security\_group\_id](#input\_target\_security\_group\_id) | The ID of an existing Security Group to which Security Group rules will be assigned. | `list(string)` | `[]` | no |
| <a name="input_create_before_destroy"></a> [create\_before\_destroy](#input\_create\_before\_destroy) | Set `true` to enable terraform `create_before_destroy` behavior on the created security group. | `bool` | `true` | no |
| <a name="input_preserve_security_group_id"></a> [preserve\_security\_group\_id](#input\_preserve\_security\_group\_id) | When `false` and `create_before_destroy` is `true`, changes to security group rules cause a new security group to be created. | `bool` | `false` | no |
| <a name="input_inline_rules_enabled"></a> [inline\_rules\_enabled](#input\_inline\_rules\_enabled) | NOT RECOMMENDED. Create rules "inline" instead of as separate `aws_security_group_rule` resources. | `bool` | `false` | no |
| <a name="input_revoke_rules_on_delete"></a> [revoke\_rules\_on\_delete](#input\_revoke\_rules\_on\_delete) | Instruct Terraform to revoke all of the Security Group's attached ingress and egress rules before deleting. | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The ID of the created Security Group |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the created Security Group |
| <a name="output_name"></a> [name](#output\_name) | The name of the created Security Group |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the created Security Group (alias for `id` output) |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the created Security Group (alias for `arn` output) |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | The name of the created Security Group (alias for `name` output) |
| <a name="output_rules_terraform_ids"></a> [rules\_terraform\_ids](#output\_rules\_terraform\_ids) | List of Terraform IDs of created `security_group_rule` resources |
<!-- markdownlint-restore -->

## References

- [cloudposse/security-group/aws](https://github.com/cloudposse/terraform-aws-security-group) - The underlying Terraform module
- [cloudposse-terraform-components](https://github.com/orgs/cloudposse-terraform-components/repositories) - Cloud Posse's upstream component library

[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/homepage?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-security-group&utm_content=)

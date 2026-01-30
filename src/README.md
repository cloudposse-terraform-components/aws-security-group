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

Here's an example snippet for how to use this component.

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
        # Configure where account-map is deployed (required when account_map_enabled: true)
        account_map_tenant_name: core
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

### Account Map Bypass Pattern

By default, this component uses the `account-map` component via remote state for IAM role lookups
(`account_map_enabled: true`). For environments migrating to Atmos Auth or using static account
mappings, you can disable this and provide a static `account_map` variable instead:

```yaml
# stacks/orgs/acme/_defaults.yaml
vars:
  # Disable account-map remote state lookup
  account_map_enabled: false
  # Provide static account mapping
  account_map:
    full_account_map:
      acme-core-root: "111111111111"
      acme-core-audit: "222222222222"
      acme-plat-dev: "333333333333"
      acme-plat-prod: "444444444444"
    audit_account_account_name: "acme-core-audit"
    root_account_account_name: "acme-core-root"
    identity_account_account_name: "acme-core-identity"
    aws_partition: "aws"
    iam_role_arn_templates:
      terraform: "arn:aws:iam::%s:role/acme-core-gbl-auto-terraform"
```

When `account_map_enabled: false`, the component bypasses the remote state lookup and uses
the static `account_map` variable directly.

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

### Referencing the Security Group from Other Components

Once deployed, other components can reference this security group using the `!terraform.state` Atmos function:

```yaml
components:
  terraform:
    lambda/my-function:
      vars:
        vpc_config:
          security_group_ids:
            - !terraform.state security-group/lambda security_group_id
```


<!-- markdownlint-disable -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.9.0, < 6.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_iam_roles"></a> [iam\_roles](#module\_iam\_roles) | ../account-map/modules/iam-roles | n/a |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | cloudposse/security-group/aws | 2.2.0 |
| <a name="module_this"></a> [this](#module\_this) | cloudposse/label/null | 0.25.0 |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | cloudposse/stack-config/yaml//modules/remote-state | 1.8.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tag_map"></a> [additional\_tag\_map](#input\_additional\_tag\_map) | Additional key-value pairs to add to each map in `tags_as_list_of_maps`. Not added to `tags` or `id`.<br/>This is for some rare cases where resources want additional configuration of tags<br/>and therefore take a list of maps with tag key, value, and additional configuration. | `map(string)` | `{}` | no |
| <a name="input_allow_all_egress"></a> [allow\_all\_egress](#input\_allow\_all\_egress) | A convenience that adds to the rules specified elsewhere a rule that allows all egress.<br/>If this is false and no egress rules are specified via `rules` or `rule-matrix`, then no egress will be allowed. | `bool` | `true` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`,<br/>in the order they appear in the list. New attributes are appended to the<br/>end of the list. The elements of the list are joined by the `delimiter`<br/>and treated as a single ID element. | `list(string)` | `[]` | no |
| <a name="input_context"></a> [context](#input\_context) | Single object for setting entire context at once.<br/>See description of individual variables for details.<br/>Leave string and numeric variables as `null` to use default value.<br/>Individual variable settings (non-null) override settings in context object,<br/>except for attributes, tags, and additional\_tag\_map, which are merged. | `any` | <pre>{<br/>  "additional_tag_map": {},<br/>  "attributes": [],<br/>  "delimiter": null,<br/>  "descriptor_formats": {},<br/>  "enabled": true,<br/>  "environment": null,<br/>  "id_length_limit": null,<br/>  "label_key_case": null,<br/>  "label_order": [],<br/>  "label_value_case": null,<br/>  "labels_as_tags": [<br/>    "unset"<br/>  ],<br/>  "name": null,<br/>  "namespace": null,<br/>  "regex_replace_chars": null,<br/>  "stage": null,<br/>  "tags": {},<br/>  "tenant": null<br/>}</pre> | no |
| <a name="input_create_before_destroy"></a> [create\_before\_destroy](#input\_create\_before\_destroy) | Set `true` to enable terraform `create_before_destroy` behavior on the created security group.<br/>We only recommend setting this `false` if you are importing an existing security group<br/>that you do not want replaced and therefore need full control over its name.<br/>Note that changing this value will always cause the security group to be replaced. | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to be used between ID elements.<br/>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| <a name="input_descriptor_formats"></a> [descriptor\_formats](#input\_descriptor\_formats) | Describe additional descriptors to be output in the `descriptors` output map.<br/>Map of maps. Keys are names of descriptors. Values are maps of the form<br/>`{<br/>   format = string<br/>   labels = list(string)<br/>}`<br/>(Type is `any` so the map values can later be enhanced to provide additional options.)<br/>`format` is a Terraform format string to be passed to the `format()` function.<br/>`labels` is a list of labels, in order, to pass to `format()` function.<br/>Label values will be normalized before being passed to `format()` so they will be<br/>identical to how they appear in `id`.<br/>Default is `{}` (`descriptors` output will be empty). | `any` | `{}` | no |
| <a name="input_enabled"></a> [enabled](#input\_enabled) | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| <a name="input_id_length_limit"></a> [id\_length\_limit](#input\_id\_length\_limit) | Limit `id` to this many characters (minimum 6).<br/>Set to `0` for unlimited length.<br/>Set to `null` for keep the existing setting, which defaults to `0`.<br/>Does not affect `id_full`. | `number` | `null` | no |
| <a name="input_inline_rules_enabled"></a> [inline\_rules\_enabled](#input\_inline\_rules\_enabled) | NOT RECOMMENDED. Create rules "inline" instead of as separate `aws_security_group_rule` resources.<br/>See the `cloudposse/security-group/aws` module documentation for caveats. | `bool` | `false` | no |
| <a name="input_label_key_case"></a> [label\_key\_case](#input\_label\_key\_case) | Controls the letter case of the `tags` keys (label names) for tags generated by this module.<br/>Does not affect keys of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper`.<br/>Default value: `title`. | `string` | `null` | no |
| <a name="input_label_order"></a> [label\_order](#input\_label\_order) | The order in which the labels (ID elements) appear in the `id`.<br/>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br/>You can omit any of the 6 labels ("tenant" is the 6th), but at least one must be present. | `list(string)` | `null` | no |
| <a name="input_label_value_case"></a> [label\_value\_case](#input\_label\_value\_case) | Controls the letter case of ID elements (labels) as included in `id`,<br/>set as tag values, and output by this module individually.<br/>Does not affect values of tags passed in via the `tags` input.<br/>Possible values: `lower`, `title`, `upper` and `none` (no transformation).<br/>Set this to `title` and set `delimiter` to `""` to yield Pascal Case IDs.<br/>Default value: `lower`. | `string` | `null` | no |
| <a name="input_labels_as_tags"></a> [labels\_as\_tags](#input\_labels\_as\_tags) | Set of labels (ID elements) to include as tags in the `tags` output.<br/>Default is to include all labels.<br/>Tags with empty values will not be included in the `tags` output.<br/>Set to `[]` to suppress all generated tags.<br/>**Notes:**<br/>  The value of the `name` tag, if included, will be the `id`, not the `name`.<br/>  Unlike other `null-label` inputs, the initial setting of `labels_as_tags` cannot be<br/>  changed in later chained modules. Attempts to change it will be silently ignored. | `set(string)` | <pre>[<br/>  "default"<br/>]</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'.<br/>This is the only ID element not also included as a `tag`.<br/>The "name" tag is set to the full `id` string. There is no tag with the value of the `name` input. | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique | `string` | `null` | no |
| <a name="input_preserve_security_group_id"></a> [preserve\_security\_group\_id](#input\_preserve\_security\_group\_id) | When `false` and `create_before_destroy` is `true`, changes to security group rules<br/>cause a new security group to be created with the new rules, and the existing security group is then<br/>replaced with the new one, eliminating any service interruption.<br/>When `true` or when changing the value (from `false` to `true` or from `true` to `false`),<br/>existing security group rules will be deleted before new ones are created, resulting in a service interruption,<br/>but preserving the security group itself.<br/>**NOTE:** Setting this to `true` does not guarantee the security group will never be replaced,<br/>it only keeps changes to the security group rules from triggering a replacement. | `bool` | `false` | no |
| <a name="input_regex_replace_chars"></a> [regex\_replace\_chars](#input\_regex\_replace\_chars) | Terraform regular expression (regex) string.<br/>Characters matching the regex will be removed from the ID elements.<br/>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region | `string` | n/a | yes |
| <a name="input_revoke_rules_on_delete"></a> [revoke\_rules\_on\_delete](#input\_revoke\_rules\_on\_delete) | Instruct Terraform to revoke all of the Security Group's attached ingress and egress rules before deleting<br/>the Security Group itself. This is normally not needed, however certain AWS services such as<br/>Elastic Map Reduce may automatically add required rules to security groups used with the service,<br/>and those rules may contain a cyclic dependency that prevent the security groups from being destroyed. | `bool` | `false` | no |
| <a name="input_rule_matrix"></a> [rule\_matrix](#input\_rule\_matrix) | A convenient way to apply the same set of rules to a set of subjects. See the `cloudposse/security-group/aws` module documentation for details. | `any` | `[]` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | A list of Security Group rule objects. All elements of a list must be exactly the same type;<br/>use `rules_map` if you want to supply multiple lists of rules.<br/>Rules are defined in a map of rule objects. See the `cloudposse/security-group/aws` module documentation for details. | `list(any)` | `[]` | no |
| <a name="input_rules_map"></a> [rules\_map](#input\_rules\_map) | A map-like object of lists of Security Group rule objects. See the `cloudposse/security-group/aws` module documentation for details. | `any` | `{}` | no |
| <a name="input_security_group_description"></a> [security\_group\_description](#input\_security\_group\_description) | The description to assign to the created Security Group.<br/>Warning: Changing the description causes the security group to be replaced. | `string` | `"Managed by Terraform"` | no |
| <a name="input_security_group_name"></a> [security\_group\_name](#input\_security\_group\_name) | The name to assign to the created security group. Must be unique within the VPC.<br/>If not provided, will be derived from the `null-label` context. | `list(string)` | `[]` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`).<br/>Neither the tag keys nor the tag values will be modified by this module. | `map(string)` | `{}` | no |
| <a name="input_target_security_group_id"></a> [target\_security\_group\_id](#input\_target\_security\_group\_id) | The ID of an existing Security Group to which Security Group rules will be assigned.<br/>The Security Group's name and description will not be changed.<br/>Not compatible with `inline_rules_enabled` or `revoke_rules_on_delete`.<br/>If not provided, a new security group will be created. | `list(string)` | `[]` | no |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | ID element \_(Rarely used, not included by default)\_. A customer identifier, indicating who this instance of a resource is for | `string` | `null` | no |
| <a name="input_vpc_component_name"></a> [vpc\_component\_name](#input\_vpc\_component\_name) | The name of the VPC component to fetch remote state from | `string` | `"vpc"` | no |
| <a name="input_vpc_environment_name"></a> [vpc\_environment\_name](#input\_vpc\_environment\_name) | The name of the environment where the VPC component is provisioned. Defaults to the current environment. | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC where the Security Group will be created.<br/>If provided, this overrides the VPC ID from remote state lookup. | `string` | `null` | no |
| <a name="input_vpc_stage_name"></a> [vpc\_stage\_name](#input\_vpc\_stage\_name) | The name of the stage where the VPC component is provisioned. Defaults to the current stage. | `string` | `null` | no |
| <a name="input_vpc_tenant_name"></a> [vpc\_tenant\_name](#input\_vpc\_tenant\_name) | The name of the tenant where the VPC component is provisioned.<br/>Defaults to the current tenant. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the created Security Group |
| <a name="output_id"></a> [id](#output\_id) | The ID of the created Security Group |
| <a name="output_name"></a> [name](#output\_name) | The name of the created Security Group |
| <a name="output_rules_terraform_ids"></a> [rules\_terraform\_ids](#output\_rules\_terraform\_ids) | List of Terraform IDs of created `security_group_rule` resources, primarily provided to enable `depends_on` |
| <a name="output_security_group_arn"></a> [security\_group\_arn](#output\_security\_group\_arn) | The ARN of the created Security Group (alias for `arn` output) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The ID of the created Security Group (alias for `id` output) |
| <a name="output_security_group_name"></a> [security\_group\_name](#output\_security\_group\_name) | The name of the created Security Group (alias for `name` output) |
<!-- markdownlint-restore -->



## References


- [cloudposse/security-group/aws](https://github.com/cloudposse/terraform-aws-security-group) - The underlying Terraform module

- [cloudposse-terraform-components](https://github.com/orgs/cloudposse-terraform-components/repositories) - Cloud Posse's upstream component library




[<img src="https://cloudposse.com/logo-300x69.svg" height="32" align="right"/>](https://cpco.io/homepage?utm_source=github&utm_medium=readme&utm_campaign=cloudposse-terraform-components/aws-security-group&utm_content=)


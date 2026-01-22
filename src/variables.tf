variable "region" {
  type        = string
  description = "AWS Region"
}

variable "account_map_component_name" {
  type        = string
  description = "The name of the account-map component"
  default     = "account-map"
}

variable "account_map_environment_name" {
  type        = string
  description = "The name of the environment where `account_map` is provisioned"
  default     = "gbl"
}

variable "account_map_stage_name" {
  type        = string
  description = "The name of the stage where `account_map` is provisioned"
  default     = "root"
}

variable "account_map_tenant_name" {
  type        = string
  description = <<-EOT
  The name of the tenant where `account_map` is provisioned.

  If the `tenant` label is not used, leave this as `null`.
  EOT
  default     = null
}

variable "vpc_component_name" {
  type        = string
  description = "The name of the VPC component to fetch remote state from"
  default     = "vpc"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the Security Group will be created. If not provided, will be looked up via remote state using `vpc_component_name`"
  default     = null
}

variable "security_group_description" {
  type        = string
  description = <<-EOT
    The description to assign to the created Security Group.
    Warning: Changing the description causes the security group to be replaced.
    EOT
  default     = "Managed by Terraform"
}

variable "allow_all_egress" {
  type        = bool
  description = <<-EOT
    A convenience that adds to the rules specified elsewhere a rule that allows all egress.
    If this is false and no egress rules are specified via `rules` or `rule-matrix`, then no egress will be allowed.
    EOT
  default     = true
}

variable "rules" {
  type        = list(any)
  description = <<-EOT
    A list of Security Group rule objects. All elements of a list must be exactly the same type;
    use `rules_map` if you want to supply multiple lists of rules.
    Rules are defined in a map of rule objects. See the `cloudposse/security-group/aws` module documentation for details.
    EOT
  default     = []
}

variable "rules_map" {
  type        = any
  description = <<-EOT
    A map-like object of lists of Security Group rule objects. See the `cloudposse/security-group/aws` module documentation for details.
    EOT
  default     = {}
}

variable "rule_matrix" {
  type        = any
  description = <<-EOT
    A convenient way to apply the same set of rules to a set of subjects. See the `cloudposse/security-group/aws` module documentation for details.
    EOT
  default     = []
}

variable "security_group_name" {
  type        = list(string)
  description = <<-EOT
    The name to assign to the created security group. Must be unique within the VPC.
    If not provided, will be derived from the `null-label` context.
    EOT
  default     = []
}

variable "target_security_group_id" {
  type        = list(string)
  description = <<-EOT
    The ID of an existing Security Group to which Security Group rules will be assigned.
    The Security Group's name and description will not be changed.
    Not compatible with `inline_rules_enabled` or `revoke_rules_on_delete`.
    If not provided, a new security group will be created.
    EOT
  default     = []
}

variable "create_before_destroy" {
  type        = bool
  description = <<-EOT
    Set `true` to enable terraform `create_before_destroy` behavior on the created security group.
    We only recommend setting this `false` if you are importing an existing security group
    that you do not want replaced and therefore need full control over its name.
    Note that changing this value will always cause the security group to be replaced.
    EOT
  default     = true
}

variable "preserve_security_group_id" {
  type        = bool
  description = <<-EOT
    When `false` and `create_before_destroy` is `true`, changes to security group rules
    cause a new security group to be created with the new rules, and the existing security group is then
    replaced with the new one, eliminating any service interruption.
    When `true` or when changing the value (from `false` to `true` or from `true` to `false`),
    existing security group rules will be deleted before new ones are created, resulting in a service interruption,
    but preserving the security group itself.
    **NOTE:** Setting this to `true` does not guarantee the security group will never be replaced,
    it only keeps changes to the security group rules from triggering a replacement.
    EOT
  default     = false
}

variable "inline_rules_enabled" {
  type        = bool
  description = <<-EOT
    NOT RECOMMENDED. Create rules "inline" instead of as separate `aws_security_group_rule` resources.
    See the `cloudposse/security-group/aws` module documentation for caveats.
    EOT
  default     = false
}

variable "revoke_rules_on_delete" {
  type        = bool
  description = <<-EOT
    Instruct Terraform to revoke all of the Security Group's attached ingress and egress rules before deleting
    the Security Group itself. This is normally not needed, however certain AWS services such as
    Elastic Map Reduce may automatically add required rules to security groups used with the service,
    and those rules may contain a cyclic dependency that prevent the security groups from being destroyed.
    EOT
  default     = false
}

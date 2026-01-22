locals {
  enabled = module.this.enabled

  vpc_id = var.vpc_id != null ? var.vpc_id : module.vpc[0].outputs.vpc_id
}

module "security_group" {
  source  = "cloudposse/security-group/aws"
  version = "2.2.0"

  enabled = local.enabled

  vpc_id                     = local.vpc_id
  security_group_description = var.security_group_description

  allow_all_egress           = var.allow_all_egress
  rules                      = var.rules
  rules_map                  = var.rules_map
  rule_matrix                = var.rule_matrix
  security_group_name        = var.security_group_name
  target_security_group_id   = var.target_security_group_id
  create_before_destroy      = var.create_before_destroy
  preserve_security_group_id = var.preserve_security_group_id
  inline_rules_enabled       = var.inline_rules_enabled
  revoke_rules_on_delete     = var.revoke_rules_on_delete

  context = module.this.context
}

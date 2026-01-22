module "account_map" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.8.0"

  component   = var.account_map_component_name
  environment = var.account_map_enabled ? var.account_map_environment_name : ""
  stage       = var.account_map_enabled ? var.account_map_stage_name : ""
  tenant      = var.account_map_enabled ? var.account_map_tenant_name : ""

  bypass   = !var.account_map_enabled
  defaults = var.account_map

  context = module.this.context
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "1.8.0"

  component   = var.vpc_component_name
  environment = coalesce(var.vpc_environment_name, module.this.environment)
  stage       = coalesce(var.vpc_stage_name, module.this.stage)
  tenant      = coalesce(var.vpc_tenant_name, module.this.tenant)

  defaults = {
    vpc_id = var.vpc_id
  }

  context = module.this.context
}

locals {
  # Determine if we need to look up the VPC from remote state
  # If vpc_id is provided directly, we can bypass the remote state lookup
  vpc_remote_state_enabled = var.vpc_id == null
}

module "vpc" {
  source  = "cloudposse/stack-config/yaml//modules/remote-state"
  version = "2.0.0"

  component   = var.vpc_component_name
  environment = local.vpc_remote_state_enabled ? coalesce(var.vpc_environment_name, module.this.environment) : ""
  stage       = local.vpc_remote_state_enabled ? coalesce(var.vpc_stage_name, module.this.stage) : ""
  tenant      = local.vpc_remote_state_enabled ? coalesce(var.vpc_tenant_name, module.this.tenant) : ""

  bypass = !local.vpc_remote_state_enabled
  defaults = {
    vpc_id = var.vpc_id
  }

  context = module.this.context
}

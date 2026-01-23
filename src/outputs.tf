output "id" {
  description = "The ID of the created Security Group"
  value       = module.security_group.id
}

output "arn" {
  description = "The ARN of the created Security Group"
  value       = module.security_group.arn
}

output "name" {
  description = "The name of the created Security Group"
  value       = module.security_group.name
}

output "security_group_id" {
  description = "The ID of the created Security Group (alias for `id` output)"
  value       = module.security_group.id
}

output "security_group_arn" {
  description = "The ARN of the created Security Group (alias for `arn` output)"
  value       = module.security_group.arn
}

output "security_group_name" {
  description = "The name of the created Security Group (alias for `name` output)"
  value       = module.security_group.name
}

output "rules_terraform_ids" {
  description = "List of Terraform IDs of created `security_group_rule` resources, primarily provided to enable `depends_on`"
  value       = module.security_group.rules_terraform_ids
}

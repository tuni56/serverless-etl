output "state_machine_arn" { value = module.sf.arn }
output "event_bus_name"    { value = module.eb.bus_name }
output "raw_bucket"        { value = module.raw.bucket }
output "curated_bucket"    { value = module.curated.bucket }

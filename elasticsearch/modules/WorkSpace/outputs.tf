output "space_ids" {
  description = "Map of space names to their IDs"
  value = {
    for key, space in elasticstack_kibana_space.spaces : key => space.id
  }
}
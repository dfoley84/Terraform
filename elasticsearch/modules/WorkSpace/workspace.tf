resource "elasticstack_kibana_space" "spaces" {
  for_each          = var.spaces
  space_id          = each.value.space_id
  name              = each.value.name
  initials          = each.value.initials
}
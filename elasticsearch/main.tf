module "WorkSpace" {
  source = "./modules/WorkSpace"
  spaces = local.spaces_workspace
   providers = {
    elasticstack = elasticstack
    }
}

module "Connectors" {
  source = "./modules/Connectors"
  depends_on = [ module.WorkSpace ]
  workspace = module.WorkSpace.space_ids
  slack = local.slack_connectors
  jira = local.jira_connectors
  server_log = local.server_log_connectors
   providers = {
    elasticstack = elasticstack
    }
  
}





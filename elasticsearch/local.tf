locals {
   spaces_workspace = {

    logs = {
      space_id = "logs"
      name     = "Logs"
      initials = "lg"
    }

  }

  slack_connectors = {
    alert = {
      name       = ""
      webhookUrl = ""
      space_id   = module.WorkSpace.space_ids["logs"]
    }
  }

  jira_connectors = {
     jira = {
      name       = ""
      projectKey = ""
      space_id   = module.WorkSpace.space_ids["logs"]
    }
   
  }

 server_log_connectors = {
    monitoring_kibana_log = {
      name     = "Monitoring: Write to Kibana log"
      space_id = "default"
    }
  }

}
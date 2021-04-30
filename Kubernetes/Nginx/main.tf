#Ran on Local Kubernetes Master Server
esource "kubernetes_replication_controller" "nginx" {
  metadata {
    name = "nginx"
    labels {
      name = "nginx"
      role = "client"
      app  = "nginx"
    }
  }

  spec {
    replicas = 5
    selector {
      name = "nginx"
      role = "client"
      app = "nginx"
    }

    template {
      container {
        image = "nginx:lastest"
        name  = "nginx-deployment"

        port {
        protocol = "TCP"
        container_port = 81
        }

        resources{
          limits{
            cpu    = "0.5"
            memory = "512Mi"
          }
          requests{
            cpu    = "250m"
            memory = "50Mi"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginxservice" {
  metadata {
    name = "test-nginx"
  }
  spec {
    selector {
      app = "nginx-deployment"
    }
      port {
      port = 30005
      target_port = 81
    }
     type = "NodePort"
  }
}

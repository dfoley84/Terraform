resource "aws_ecs_task_definition" "prometheus" {
  family = "prometheus-grafana-definition"
  task_role_arn = var.arn_prometheus_role
  container_definitions = jsonencode([
    {
        name = "prometheus"
        image = "prom/prometheus:v2.4.0"
        cpu = 512
        memory = 512
        MemoryReservation = 256
        portMappings = [
        {
            containerPort = 9090
            hostPort = 9090
            protocol = "tcp"
        }]
        essential = true
    }   
    ])
}

resource "aws_ecs_task_definition" "cadvisor" {
  family = "cadvisor-node-exporter-definition"
  task_role_arn = var.arn_prometheus_role
  container_definitions = jsonencode([
    {
        name = "cadvisor"
        image = "google/cadvisor"
        cpu = 512
        memory = 512
        MemoryReservation = 256
        portMappings = [
        {
            containerPort = 8080
            hostPort = 9200
            protocol = "tcp"
        }]
        mountPoints = [
            {
                sourceVolume = "root"
                containerPath  = "/rootfs"
                readOnly = true
            },
            {
                sourceVolume = "cgroup"
                containerPath  = "/cgroup"
                readOnly = true
            },
            {
                sourceVolume = "cgroup"
                containerPath  = "/sys/fs/cgroup"
                readOnly = true
            },
            {
                sourceVolume = "var_run"
                containerPath  = "/var/run"
                readOnly = true
            },
            {
                sourceVolume = "var_lib_docker"
                containerPath  = "/var/lib/docker"
                readOnly = true
            },
            {
                sourceVolume = "dev_disk"
                containerPath  = "/dev/disk"
                readOnly = true
            } 
        ]
        essential = true
    },
    {
        name = "node-exporter"
        image = "prom/node-exporter"
        cpu = 512
        memory = 512
        MemoryReservation = 256
        portMappings = [
        {
            containerPort = 9100
            hostPort = 9100
            protocol = "tcp"
        }]
        essential = true
    }
    ])

    volume {
        name = "root"
        host_path  = "/"
    }
    volume {
       name =  "cgroup"
       host_path  = "/cgroup"
    }
    volume {
       name =  "var_run"
       host_path  = "/var/run"
    }
    volume {
       name =  "var_lib_docker"
       host_path  = "/var/lib/docker"
    }
    volume {
       name =  "dev_disk"
       host_path  = "/dev/disk"
    }
}

























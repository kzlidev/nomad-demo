job "tetris" {
  # Specify which data center to run this application on
  datacenters = ["dc1"]

  # Service is default
  type = "service"

  # Only run this job on Linux
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  # Tell Nomad how to update
  update {
    max_parallel = 1
  }

  # Tasks in the same group runs on the same node
  group "games" {
    count = 1

    network {
      mode = "host"
      port "http" {
        to = 80
      }
    }

    task "tetris" {
      driver = "docker"

      config {
        image          = "bsord/tetris"
        ports          = ["http"] # Where we define what we want job we want this task to run with
        auth_soft_fail = true
      }
      resources {
        cpu    = 500 #500MHz
        memory = 256 #256MB
        network {
          mbits = 10
        }
      }
    }
  }
}
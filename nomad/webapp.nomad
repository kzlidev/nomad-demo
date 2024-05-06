job "webapp" {
  # Specify which data center to run this application on
  datacenters = ["dc1"]

  # Service is default
  type = "service"

  # Only run this job on Linux
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  # Only run this job on instance marked with application as purpose
  constraint {
    attribute = "${meta.purpose}"
    value     = "application"
  }

  # Tell Nomad how to update
  update {
    max_parallel = 1
  }

  # Tasks in the same group runs on the same node
  group "web_group" {
    count = 3

    # Spread deployment evenly across each nodes
    spread {
      attribute = "${node.unique.id}"
    }

    network {
      mode = "host"
      port "http" {
        to     = 5678
        static = 80
      }
    }

    task "webapp" {
      driver = "docker"

      service {
        name     = "webapp"
        port     = "http"
        provider = "nomad"
      }

      config {
        image = "hashicorp/http-echo"
        args  = [
          "-listen", ":5678",
          "-text", "hello world ${attr.unique.platform.aws.instance-id}",
        ]
        ports = ["http"] # Maps back to network.port stanza
      }

      resources {
        cpu    = 500 # 500MHz
        memory = 256 # 256MB
      }
    }
  }
}

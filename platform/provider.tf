provider "aws" {
  default_tags {
    tags = {
      purpose   = "demo"
      ttl       = 3
      terraform = true
    }
  }
  region = var.region
}
terraform {
  required_version = ">= 1.6.6, < 2.0.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 8.3.0"
    }
  }

  backend "gcs" {}
}

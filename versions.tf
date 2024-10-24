terraform {
  required_version = ">=1.3"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.44.2, !=6.0.0, !=6.0.1, !=6.1.0, !=6.2.0, !=6.3.0, !=6.4.0, !=6.5.0, !=6.6.0, < 7"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-kubernetes-engine/v33.1.0"
  }
}

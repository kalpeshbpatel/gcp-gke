terraform {
  required_version = "~> 1.5.2"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.6.0, < 7.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.22"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

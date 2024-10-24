variable "region" {
  type    = string
  default = ""
}

variable "project_id" {
  type    = string
  default = ""
}

variable "cluster_name" {
  type    = string
  default = ""
}

variable "enable" {
  type    = bool
  default = false
}

variable "name" {
  type    = string
  default = "cert-manager"
}

variable "namespace" {
  type    = string
  default = "kube-addons"
}

variable "release_version" {
  type    = string
  default = "1.16.1"
}

variable "replicas" {
  type    = number
  default = "2"
}

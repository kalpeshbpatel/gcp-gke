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
  default = "kubernetes-dashboard"
}

variable "namespace" {
  type    = string
  default = "kubernetes-dashboard"
}

variable "release_version" {
  type    = string
  default = "7.9.0"
}

variable "ingress" {
  type    = bool
  default = false
}

variable "url" {
  type    = string
  default = "dashboard"
}

variable "cert_issuer" {
  type    = string
  default = "certmanager"
}

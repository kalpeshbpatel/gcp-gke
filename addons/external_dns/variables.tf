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
  default = "external-dns"
}

variable "namespace" {
  type    = string
  default = "kube-addons"
}

variable "release_version" {
  type    = string
  default = "8.3.9"
}

variable "dns_project_id" {
  type    = string
  default = null
}

variable "zone" {
  type    = string
  default = ""
}

variable "domain" {
  type    = string
  default = ""
}

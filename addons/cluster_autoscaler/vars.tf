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
  default = "cluster-autoscaler"
}

variable "namespace" {
  type    = string
  default = "kube-addons"
}

variable "release_version" {
  type    = string
  default = "9.29.3"
}

variable "system_node_group" {
  type    = string
  default = ""
}

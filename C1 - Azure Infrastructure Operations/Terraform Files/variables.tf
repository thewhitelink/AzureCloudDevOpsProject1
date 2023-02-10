variable "prefix" {
  description = "The prefix which should be used for all resources of this type"
  default = "project-1"
}
variable "location" {
  description = "The Azure Region in which all resources should be created"
  default = "East US"
}
variable "username" {
  description = "default username for VMs"
  default = "thewhitelink"
}
variable "password" {
  description = "default password for VMs"
  default = "P@ssw0rd!"
}
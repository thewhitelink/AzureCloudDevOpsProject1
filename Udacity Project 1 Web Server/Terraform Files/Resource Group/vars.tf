variable "prefix" {
  description = "The prefix which should be used for all resources of this type"
  default = "project-1"
}
variable "location" {
  description = "The Azure Region in which all resources should be created"
  default = "South Central US"
}
variable "username" {
  description = "default username for VMs"
  default = "thewhitelink"
}
variable "password" {
  description = "default password for VMs"
  default = "P@ssw0rd!"
}
variable "vmnumber" {
  description = "number of VMs"
  default = "3"
}
variable "image_id" {
  description = "The ID for the image to be used on VM"
  default = "/subscriptions/d06323f0-ffb0-484c-9e89-0ca5e1d58412/resourceGroups/Azuredevops/providers/Microsoft.Compute/images/ubuntuimage"
}
variable "client_id" {
  description = ""
  default = "a1af734c-eec0-4ae5-82af-43a92240e29e"
}
variable "client_secret" {
  description = ""
  default = "FNf8Q~4cVgxLOVZeIwRPe-byXr~1ykgCL8o~ydaz"
}
variable "tenant_id" {
  description = ""
  default = "f958e84a-92b8-439f-a62d-4f45996b6d07"
}
variable "subscription_id" {
  description = ""
  default = "0b72aa91-69d1-4842-8da0-1dbc098c1665"
}

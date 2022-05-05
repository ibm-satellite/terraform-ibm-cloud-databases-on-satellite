variable "location_name" {
  type        = string
  description = "Location name"
}

variable "image" {
  type        = string
  description = "Image for the VPC instances"
}

variable "existing_ssh_key" {
  type        = string
  description = "Existing SSH key name in same VPC region as 'geo' variable value"
}

variable "region" {
  type        = string
  description = "The IBM Cloud region which is used for your VPC instances & zones"
}

variable "hosts" {
  type = object({
    count = number
    name  = string
    type  = string
  })
  description = "Number of hosts and their VPC profile"
}

variable "host_script" {
  description = "Location host script"
}

variable "location_vpc" {}

variable "location_subnet" {}

variable "location_security_group" {}

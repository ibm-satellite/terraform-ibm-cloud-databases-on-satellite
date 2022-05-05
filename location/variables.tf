variable "location_name" {
  type        = string
  description = "Location name"
}

variable "is_location_exist" {
  type        = bool
  description = "Whether the location already exists or needs to be created"
}

variable "managed_from" {
  type        = string
  description = "The IBM Cloud region to manage the Satellite location from"
}

variable "region" {
  type        = string
  description = "The IBM Cloud region which is used for your VPC instances & zones"
}

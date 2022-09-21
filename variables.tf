variable "ibmcloud_api_key" {
  type        = string
  sensitive   = true
  description = "IBM Cloud API key"
}

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

variable "image" {
  type        = string
  description = "Image for the VPC instances"
}

variable "existing_ssh_key" {
  type        = string
  description = "Existing SSH key name in same VPC region as 'geo' variable value"
}

variable "control_plane_hosts" {
  type = object({
    count = number
    name  = string
    type  = string
  })
  description = "Number of control-plane hosts and the VPC profile"
}

variable "customer_hosts" {
  type = object({
    count = number
    name  = string
    type  = string
  })
  description = "Number of customer hosts and the VPC profile"
}

variable "internal_hosts" {
  type = object({
    count = number
    name  = string
    type  = string
  })
  description = "Number of internal hosts and the VPC profile"
}

variable "manage_iam_policy" {
  type        = bool
  description = "Whether the IAM policies for service-to-service functionality on Satellite should be managed by Terraform"
  default     = true
}

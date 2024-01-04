

# List of available regions:
# https://docs.aws.amazon.com/general/latest/gr/rande.html

variable "aws_region" {
  type        = string
  description = "Change the region if you want to deploy the resources in another region."
  default     = "us-east-1"
}

variable "aws_profile" {
  type        = string
  description = "Change the profile if you want to deploy the resources in another account/role."
  default     = "default"
}

variable "thing_name" {
  type        = string
  description = "Device name referenced in AWS IoT Core."
  default     = "default"
}

variable "device_storage_bucket" {
  type        = string
  description = "S3 bucket name to store the device data."
  default     = "iot-storage-bucket"
}

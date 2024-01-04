variable "bucket_name" {
  type        = string
  description = "S3 bucket name to store the device data."
  default     = "iot-default-bucket-storage"
}

variable "thing_arn" {
  type        = string
  description = "The ARN of the thing."

}

variable "thing_name" {
  type        = string
  description = "The name of the thing."

}

variable "thing_region" {
  type        = string
  description = "The region of the thing."

}

variable "thing_account" {
  type        = string
  description = "The account ID of the thing."

}

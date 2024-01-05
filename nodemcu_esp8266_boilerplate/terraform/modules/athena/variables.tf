# Based on article: https://www.linkedin.com/pulse/have-quick-sight-your-data-amazon-quicksight-s3-sachin-adi/

# variable "admin_email_address" {
#   type        = string
#   description = "(required) Your email address. QuickSight uses your email address as part of your identity in the console."
# }

variable "athena_db_name" {
  type        = string
  description = "(required) The name of the Athena database to be created."
  default     = "iot_analytics_db"
}

variable "athena_main_table_name" {
  type        = string
  description = "(required) The name of the Athena main table to hold sensor data."
  default     = "sensor_data"
}


variable "s3_source_bucket_name" {
  type        = string
  description = "(required) The name of S3 bucket that holds sensor data."
}

variable "s3_source_bucket_address" {
  type        = string
  description = "(required) The name of the S3 object (subfolder) that holds sensor data."
  default     = ""
}

variable "columns" {
  type = list(object({
    name = string,
    type = string,
  }))
  default     = []
  description = "The columns in the table, where the key is the name of the column and the value the type"
}

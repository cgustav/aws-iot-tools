# Visit Related Articles and Documentation:
# https://aws.amazon.com/es/dynamodb/iot/
# https://aws.amazon.com/es/dynamodb/pricing/
# https://repost.aws/articles/AR7uHw_LKuT-GqP7v_4tIcOg/cost-optimization-tips-for-aws-iot-workloads


# ------------------------------
# Cloud Provider Configuration (AWS)
# ------------------------------

provider "aws" {}


# ------------------------------
# MODULES
# ------------------------------

# The following module creates an AWS IoT thing,
# a certificate, and a policy to grant the device
# permission to connect to AWS IoT Core and publish
# and subscribe to topics in the AWS IoT message broker.
module "iot" {
  source = "./modules/iot"

  # Pass specific variables to module
  thing_name = var.thing_name
}

# The following module creates an S3 bucket to store
# the device data and a policy to grant the device
# permission to store data in the S3 bucket.
module "iot_bucket_storage" {
  source = "./modules/bucket_storage"

  depends_on = [module.iot]

  # Pass specific variables to module
  bucket_name   = var.device_storage_bucket
  thing_arn     = module.iot.thing_arn
  thing_name    = module.iot.thing_name
  thing_region  = module.iot.thing_region
  thing_account = module.iot.thing_account
}

module "iot_athena" {
  source = "./modules/athena"

  # Pass specific variables to module
  s3_source_bucket_name    = var.device_storage_bucket
  s3_source_bucket_address = module.iot.thing_name
  columns = [
    {
      name = "humidity"
      type = "double"
    },
    {
      name = "temperature"
      type = "double"
    },
    {
      name = "timestamp"
      type = "bigint"
    }
  ]
}


# ------------------------------
# ROOT OUTPUTS
# ------------------------------
output "iot_thing_name" {
  value = module.iot.thing_name
}

output "iot_thing_arn" {
  value = module.iot.thing_arn
}

output "iot_endpoint" {
  value = module.iot.iot_endpoint
}

output "iot_root_ca_cert" {
  value = module.iot.root_ca_cert
}

output "iot_thing_cert" {
  value = module.iot.device_cert
}

output "iot_thing_private_key" {
  sensitive = true
  value     = module.iot.private_key_pem
}

output "iot_thing_public_key" {
  value = module.iot.public_key_pem
}


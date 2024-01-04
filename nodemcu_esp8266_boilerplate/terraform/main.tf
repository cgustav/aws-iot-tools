# Related Articles and Documentation:
# https://aws.amazon.com/es/dynamodb/iot/
# https://aws.amazon.com/es/dynamodb/pricing/
# https://repost.aws/articles/AR7uHw_LKuT-GqP7v_4tIcOg/cost-optimization-tips-for-aws-iot-workloads


# ------------------------------
# Cloud Provider Configuration (AWS)
# ------------------------------

provider "aws" {
  # region = var.aws_region
  # profile = var.aws_profile
}



# ------------------------------
# MODULES
# ------------------------------

module "iot" {
  source = "./modules/iot"

  # Pasar variables específicas al módulo
  thing_name = var.thing_name
}

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



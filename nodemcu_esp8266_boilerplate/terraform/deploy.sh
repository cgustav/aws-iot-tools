#!/bin/bash

# Make a plan and apply it to all modules
terraform plan -var-file=variables/main.tfvars --target=module.iot --target=module.iot_bucket_storage --target=module.iot_athena --out=out.tfplan
terraform apply "out.tfplan"
terraform output -json > outputs.json

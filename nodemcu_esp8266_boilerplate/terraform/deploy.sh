#!/bin/bash

terraform plan -var-file=variables/main.tfvars
terraform apply -var-file=variables/main.tfvars --auto-approve
terraform output -json > outputs.json

#!/bin/bash

terraform init -reconfigure -backend-config=variables/backend.tfvars -var-file=variables/main.tfvars
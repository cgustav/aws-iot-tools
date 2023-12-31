# Related Articles and Documentation:
# https://aws.amazon.com/es/dynamodb/iot/
# https://aws.amazon.com/es/dynamodb/pricing/
# https://repost.aws/articles/AR7uHw_LKuT-GqP7v_4tIcOg/cost-optimization-tips-for-aws-iot-workloads


# ------------------------------
# Cloud Provider Configuration (AWS)
# ------------------------------

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}


# ------------------------------
# Things
# ------------------------------

# An AWS IoT Thing refers to a device or entity in Amazon Web Services' 
# (AWS) Internet of Things (IoT) ecosystem. It represents any physical device, 
# such as a sensor, appliance, or machine, or a logical entity that can connect 
# to the internet and interact with other devices and services in the AWS cloud. 

resource "random_id" "id" {
  byte_length = 8
}

resource "aws_iot_thing" "thing" {
  name = "thing_${random_id.id.hex}"
}


# ------------------------------
# Certificates
# ------------------------------

# Certificates in AWS IoT play a crucial role in authenticating and securing 
# communication between IoT devices (things) and the AWS cloud. Here's how 
# they work:

resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.key.private_key_pem

  validity_period_hours = 240

  allowed_uses = [
  ]

  subject {
    organization = "test"
  }
}

resource "aws_iot_certificate" "thing_cert" {
  certificate_pem = trimspace(tls_self_signed_cert.cert.cert_pem)
  active          = true
}

resource "aws_iot_thing_principal_attachment" "thing_cert_attachment" {
  principal = aws_iot_certificate.thing_cert.arn
  thing     = aws_iot_thing.thing.name
}


# ------------------------------
# Policies
# ------------------------------

# The following data source retrieves the ARN of the thing
# created in the previous step. The ARN is used in the policy
# to grant the device permission to connect to AWS IoT Core.
data "aws_arn" "thing" {
  arn = aws_iot_thing.thing.arn
}

# The following policy grants the device permission to connect 
# to AWS IoT Core and publish and subscribe to topics in the
# AWS IoT message broker.

resource "aws_iot_policy" "thing_pubsub_policy" {
  name = "ThingPubSubPolicy"
  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iot:Connect",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${data.aws_arn.thing.region}:${data.aws_arn.thing.account}:client/$${iot:Connection.Thing.ThingName}"
      },

      {
        Action = [
          "iot:Publish",
          "iot:Receive",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${data.aws_arn.thing.region}:${data.aws_arn.thing.account}:topic/$aws/things/$${iot:Connection.Thing.ThingName}/*"
      },

      {
        Action = [
          "iot:Subscribe",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${data.aws_arn.thing.region}:${data.aws_arn.thing.account}:topicfilter/$aws/things/$${iot:Connection.Thing.ThingName}/*"
      }
    ]
    },

  )
}

# The following resource attaches the policy to the device certificate.

resource "aws_iot_policy_attachment" "thing_pubsub_policy_attachment" {
  policy = aws_iot_policy.thing_pubsub_policy.name
  target = aws_iot_certificate.thing_cert.arn
}


# ------------------------------
# OUTPUTS
# ------------------------------


data "aws_iot_endpoint" "iot_endpoint" {
  endpoint_type = "iot:Data-ATS"
}

# You can use these endpoints to perform the operations in 
# the AWS IoT API Reference. The endpoints in the following 
# sections are different from the device endpoints, 
# which provide devices an MQTT publish/subscribe interface 
# and a subset of the API operations.
output "iot_endpoint" {
  value = data.aws_iot_endpoint.iot_endpoint.endpoint_address
}

data "http" "root_ca" {
  url = "https://www.amazontrust.com/repository/AmazonRootCA1.pem"
}


# Purpose: Certificate Authority (CA) certificates are used to verify 
# the authenticity of the device certificate. 
# They help establish a chain of trust from the device certificate to 
# a trusted root CA.
# 
# How to use: CA certificates are installed on the device and on AWS IoT. 
# When the device connects to AWS IoT Core, AWS uses these CA certificates 
# to validate the device's certificate.
output "root_ca_certificate" {
  value       = data.http.root_ca.response_body
  description = "Certificate Authority (CA) certificates are used to verify the authenticity of the device certificate."
}

# Simple name to identify the device (thing).
output "device_name" {
  value       = aws_iot_thing.thing.name
  description = "Simple name to identify the device (thing)."
}


# Device Certificate:

# This certificate is used to uniquely identify each device (thing) 
# in AWS IoT. It acts as an identity for the device, ensuring that 
# only authorized devices can connect and communicate with AWS IoT Core.
output "device_certificate" {
  value       = tls_self_signed_cert.cert.cert_pem
  description = "Used to uniquely identify each device (thing) in AWS IoT"
}


# Device Private Key:

# Purpose: The private key is used in conjunction with 
# the device's certificate to create a digital signature. 
# This signature is essential to the TLS authentication process, 
# ensuring that communications between the device and 
# AWS IoT Core are secure and verified.
# 
# How it is used: The private key must be kept secret and stored 
# securely on the device. It is used during the TLS handshake 
# process to prove that the device possesses the private key 
# corresponding to the certificate presented.
output "private_key_pem" {
  value       = tls_private_key.key.private_key_pem
  description = "This signature is essential to the TLS authentication process. Keep it secret and store it securely on the device."
  sensitive   = true
}

# Device Public Key:

# Authentication: The public key certificate is used to authenticate 
# the device to AWS IoT Core. When a device establishes a connection 
# to AWS IoT, it presents its certificate. 
# AWS IoT Core verifies this certificate against the known CA to 
# confirm the identity of the device.
output "public_key_pem" {
  value       = tls_private_key.key.public_key_pem
  description = "The public key certificate is used to authenticate the device to AWS IoT Core."
}




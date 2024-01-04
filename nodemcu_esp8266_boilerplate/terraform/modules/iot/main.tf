# ------------------------------
# Things
# ------------------------------

# An AWS IoT Thing refers to a device or entity in Amazon Web Services' 
# (AWS) Internet of Things (IoT) ecosystem. It represents any physical device, 
# such as a sensor, appliance, or machine, or a logical entity that can connect 
# to the internet and interact with other devices and services in the AWS cloud. 

# resource "random_id" "id" {
#   byte_length = 8
# }

resource "aws_iot_thing" "thing" {
  name = var.thing_name
}


# ------------------------------
# IOT Certificates
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
        Resource = "arn:aws:iot:${data.aws_arn.thing.region}:${data.aws_arn.thing.account}:topic/${aws_iot_thing.thing.name}/*"
      },

      {
        Action = [
          "iot:Subscribe",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${data.aws_arn.thing.region}:${data.aws_arn.thing.account}:topicfilter/${aws_iot_thing.thing.name}/*"
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

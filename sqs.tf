resource "aws_sqs_queue" "terraform_queue" {
  provider = aws.apsouth1
  name     = "Nic-TF-SQS-apsouth1"
  #   delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  redrive_policy = jsonencode({
    deadLetterTargetArn = "arn:aws:sqs:ap-south-1:175652158808:nic-sqs-DLQ"
    maxReceiveCount     = 4
  })

  tags = {
    Environment = "production"
    Terraform   = true
  }
}

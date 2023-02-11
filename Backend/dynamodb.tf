resource "aws_dynamodb_table" "resume_counter" {
  name             = "resume_counter"
  hash_key         = "id"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }
}
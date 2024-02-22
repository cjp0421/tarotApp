provider "aws" {
  region = "us-east-1"  # Replace with your desired region
}

resource "aws_s3_bucket" "cards_bucket" {
  bucket = "tarot_card_bucket_37921"  # Replace with a globally unique bucket name
  acl    = "private"
}

resource "aws_lambda_function" "tarot_backend" {
  filename      = "path/to/your/deployment-package.zip"  # Replace with the path to your deployment package
  function_name = "tarot-backend"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "main"
  runtime       = "go1.x"

  environment = {
    variables = {
      AWS_REGION      = "us-east-1",  # Replace with your desired region
      S3_BUCKET_NAME  = aws_s3_bucket.cards_bucket.bucket,
      ACCESS_KEY      = "your-access-key-id",  # Replace with your AWS access key
      SECRET_KEY      = "your-secret-access-key",  # Replace with your AWS secret access key
    }
  }

  depends_on = [aws_s3_bucket.cards_bucket]
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_api_gateway_rest_api" "tarot_api" {
  name        = "tarot-api"
  description = "API for Tarot cards"
}

resource "aws_api_gateway_resource" "cards_resource" {
  rest_api_id = aws_api_gateway_rest_api.tarot_api.id
  parent_id   = aws_api_gateway_rest_api.tarot_api.root_resource_id
  path_part   = "cards"
}

resource "aws_api_gateway_resource" "major_arcana_resource" {
  rest_api_id = aws_api_gateway_rest_api.tarot_api.id
  parent_id   = aws_api_gateway_rest_api.tarot_api.root_resource_id
  path_part   = "majorArcana"
}

resource "aws_api_gateway_resource" "minor_arcana_resource" {
  rest_api_id = aws_api_gateway_rest_api.tarot_api.id
  parent_id   = aws_api_gateway_rest_api.tarot_api.root_resource_id
  path_part   = "minorArcana"
}

resource "aws_api_gateway_resource" "minor_arcana_suit_resource" {
  rest_api_id = aws_api_gateway_rest_api.tarot_api.id
  parent_id   = aws_api_gateway_resource.minor_arcana_resource.id
  path_part   = "{suit}"
}

resource "aws_api_gateway_method" "cards_method" {
  rest_api_id   = aws_api_gateway_rest_api.tarot_api.id
  resource_id   = aws_api_gateway_resource.cards_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "cards_id_method" {
  rest_api_id   = aws_api_gateway_rest_api.tarot_api.id
  resource_id   = aws_api_gateway_resource.cards_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "major_arcana_method" {
  rest_api_id   = aws_api_gateway_rest_api.tarot_api.id
  resource_id   = aws_api_gateway_resource.major_arcana_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "minor_arcana_method" {
  rest_api_id   = aws_api_gateway_rest_api.tarot_api.id
  resource_id   = aws_api_gateway_resource.minor_arcana_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "minor_arcana_suit_method" {
  rest_api_id   = aws_api_gateway_rest_api.tarot_api.id
  resource_id   = aws_api_gateway_resource.minor_arcana_suit_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "tarot_integration" {
  rest_api_id             = aws_api_gateway_rest_api.tarot_api.id
  resource_id             = aws_api_gateway_resource.cards_resource.id
  http_method             = aws_api_gateway_method.cards_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.tarot_backend.invoke_arn
}

resource "aws_api_gateway_integration" "tarot_id_integration" {
  rest_api_id             = aws_api_gateway_rest_api.tarot_api.id
  resource_id             = aws_api_gateway_resource.cards_resource.id
  http_method             = aws_api_gateway_method.cards_id_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.tarot_backend.invoke_arn
}

resource "aws_api_gateway_integration" "major_arcana_integration" {
  rest_api_id             = aws_api_gateway_rest_api.tarot_api.id
  resource_id             = aws_api_gateway_resource.major_arcana_resource.id
  http_method             = aws_api_gateway_method.major_arcana_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.tarot_backend.invoke_arn
}

resource "aws_api_gateway_integration" "minor_arcana_integration" {
  rest_api_id             = aws_api_gateway_rest_api.tarot_api.id
  resource_id             = aws_api_gateway_resource.minor_arcana_resource.id
  http_method             = aws_api_gateway_method.minor_arcana_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.tarot_backend.invoke_arn
}

resource "aws_api_gateway_integration" "minor_arcana_suit_integration" {
  rest_api_id             = aws_api_gateway_rest_api.tarot_api.id
  resource_id             = aws_api_gateway_resource.minor_arcana_suit_resource.id
  http_method             = aws_api_gateway_method.minor_arcana_suit_method.http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.tarot_backend.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tarot_backend.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.tarot_api.execution_arn}/*/*"
}
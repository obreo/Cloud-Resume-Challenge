# My Resume Challenge
#### Description: Implementing my resume challenge using on AWS Cloud

## Intro
I created a resume page and deployed it on AWS Cloud - using IaC; Terraform - as a S3 static website.

This project used DynamoDB with lambda to put & get the number of visitor with every access done to the website. 

To make this possible, I used an API gateway to trigger the lambda function whenever traffic occures in the resume page.

## Preparing the Resume
I chose to get a resume template and modified it the way it fits me.

## 1- Terraform
I created am S3 & DynamoDB database resources:

- The S3 Bucket was assigned to a variable name. Then I configured the static site options and assigned the default page.
```
# Create Bucket
resource "aws_s3_bucket" "myresume_website" {
  bucket = var.bucket_name
  #acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "website_conf" {
  bucket = aws_s3_bucket.myresume_website.bucket

# HTML file name
  index_document {
    suffix = var.static_page_file_name
  }
  # Error file name
  #error_document {
    key = "error.html"
  }
}
```
Here I assigned an access policy to the bucket and this is required to allow public access to the bucket pages:
```
# Attach Bucket with policy
resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.myresume_website.id
  policy = data.aws_iam_policy_document.allow_public_access.json
}


# Public Access Policy
data "aws_iam_policy_document" "allow_public_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:ListBucket"
      ,"s3:DeleteObject"
      ,"s3:GetObject"
    ]

    resources = [
      #aws_s3_bucket.myresume_website,
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }
}
```
- DynamoDB:
Setting DynamoDB is easy, assign the hashkey(primary key) and set the attribute with the type (S = string), I chose Pay per request which is more economical for this project:
```
resource "aws_dynamodb_table" "resume_counter" {
  name             = "resume_counter"
  hash_key         = "id"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "id"
    type = "S"
  }
}
```
- SDK - S3 Upload files:
I created a side dynamic python code which uploads files to S3 bucket.
- Upload the files to the bucket and make sure they are set to the root directory and have the same names as assigned in the static pages (typically only index.html and error.html) work.

## CloudFront - AWS Console

I created a cloud front distribution, assigned the static bucket URL and made sure it runs the same files.

## Lambda & API Gateway
1.Create an API gateway as REST API, deploy it with a lambda funcion. The functio will run a code which will communicate with dynamodb to add +1 record whenever lambda is triggerd by the API Gateway.

The Gateway will be fetched in the HTML File by Javascript code whenver traffic access the page.
```
		<script>
			fetch('')
				.then(response => response.json())
				.then((data) =>{
					document.getElementById('visits').innerText =data
				})
		</script> 
```

## CodeCommit - CI CD

I used code commit to automate deployment of the static pages:

1. Create a Github repository and set the ssh credintials of your local machien to the github account.

2. upload your files using git, as instructed by the repository's page.

3. Using codecommit, from code pipeline, add the respository and choose the source of S3 bucket and apply the pipeline. Now any change in the repository will change the s3 buvket files automatically.
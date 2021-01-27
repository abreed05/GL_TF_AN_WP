terraform {
    backend "s3" {
        bucket         = "name-of-your-bucket"
        key            = "global/s3/gl-tf-an.tfstate"
        region         = "us-east-1"

        dynamodb_table = "name-of-your-dynamodb-table"
        encrypt        = true
    }
}
terraform {
    backend "s3" {
        bucket         = "abreed05-terraform-up-and-running"
        key            = "global/s3/gl-tf-an-dns.tfstate"
        region         = "us-east-1"

        dynamodb_table = "abreed05-terraform-up-and-running-locks"
        encrypt        = true
    }
}
terraform {
	backend "s3" {
		bucket = "terraform-takehome-test-akbar1"
		key = "somepath/terraform.tfstate"
		region = "us-west-2"
		profile = "fargate_deployment"
	}
}
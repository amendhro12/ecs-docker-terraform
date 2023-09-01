# Deploying a Docker Image to AWS ECS using Fargate with Terraform

# Getting Started
This repository provides the Terraform configurations needed to deploy a Docker image to Amazon Elastic Container Service (ECS) using the Fargate launch type.
The given Terraform code assumes that you have an existing VPC, subnets, security group and a load balancer with a target group setup for nginx.


### The Template Creates the following 
* ECR Repo Creation
* Pushes a Docker image to AWS ECR
* Creates an ECS Cluster along with an AWS IAM execution role for ecs 
* Launches the docker container with fargate 

### Setup instructions 
Connect to an instance that has the following 
* AWS CLI 
* Docker 
* Terraform 
* IAM instance role with the example-policy.json permissions included in this repo
* Ensure an instance profile named fargate_deployment 

Update the backend-state.tf putting the path of the tf state 

``` bash
vi backend-state.tf
```

Update the required vars.tfvars file with the appropriate variables values 

* app_name is the name of the application 
* aws_region is the region of the ecs/fargate deployment
* ecs_cluster_name is the name of the ecs cluster that will be created 
* security_group_name will be the security group already created for the ecs service, terraform will pull the security group id 
* vpc_name will be the existing vpc that has been created for the ecs container, terraform will get the subents from the vpc 

```bash
vi vars.tfvars 
```
Update providers.tf region with the region for your deployment

```bash
vi providers.tf
```

Run the terraform 

```bash 
terraform init
terraform plan --var-file=vars.tfvars
terraform apply --var-file=vars.tfvars
```




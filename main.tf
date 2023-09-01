#Create ECR Repo

data "aws_caller_identity" "current" {}

resource "aws_ecr_repository" "app_repo" {
  name = var.app_name
}

#Create the Docker Image and Push to ECR

resource "null_resource" "push_docker_image" {
  # Use a trigger to ensure that the local-exec is run whenever the ECR repository URL changes.
  triggers = {
    repo_url = aws_ecr_repository.app_repo.repository_url
  }

  provisioner "local-exec" {
    command = <<EOL
      # Authenticate Docker to the ECR registry

      aws ecr get-login-password --region ${var.aws_region} --profile fargate_deployment | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

      
      # Build the Docker image
      docker build -t ${aws_ecr_repository.app_repo.name} -f ${path.module}/Dockerfile ${path.module}
      
      # Tag the Docker image
      docker tag ${aws_ecr_repository.app_repo.name}:latest ${aws_ecr_repository.app_repo.repository_url}:latest
      
      # Push the Docker image to the ECR repository
      docker push ${aws_ecr_repository.app_repo.repository_url}:latest
    EOL
  }
}



#Create the ECS Cluster
resource "aws_ecs_cluster" "my_cluster" {
	name = var.ecs_cluster_name
}


resource "aws_ecs_task_definition" "fargate_task" {
  family                   = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  container_definitions    = jsonencode([{
    name  = var.app_name
    image = "${aws_ecr_repository.app_repo.repository_url}:latest"
    portMappings = [{
      containerPort = 80
      hostPort      = 80
    }]
  }])
}

#Create the IAM Role/Policy for ECS 

resource "aws_iam_role" "ecs_execution_role" {
	name = "ecs_execution_role"

	assume_role_policy = jsonencode({
		Version = "2012-10-17",
		Statement = [{
			Action = "sts:AssumeRole",
			Effect = "Allow",
			Principal = {
				Service = "ecs-tasks.amazonaws.com"
			}
		}]
	})
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy_attach" {
	role = aws_iam_role.ecs_execution_role.name
	policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#Get Existing Network for ECS Service Fargate deployment 

data "aws_vpc" "selected" {
	filter {
		name = "tag:Name"
		values = [var.vpc_name]
	}
}

data "aws_subnet_ids" "vpc_subents" {
	vpc_id = data.aws_vpc.selected.id
}

data "aws_security_group" "selected" {
	filter {
		name = "group-name"
		values = [var.security_group_name]
	}
}

data "aws_lb_target_group" "example" {
  name = var.target_group_name
}

resource "aws_ecs_service" "fargate_service" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.fargate_task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    subnets = data.aws_subnet_ids.vpc_subnets.ids
    security_groups = [data.aws_security_groups.selected.id]
  }

  load_balancer {
    target_group_arn = data.aws_lb_target_group.example.arn
    container_name   = var.app_name
    container_port   = 80
  }
}



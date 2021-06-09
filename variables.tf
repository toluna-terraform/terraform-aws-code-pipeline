variable "aws_profile" {
type = string
default = "080660034022_AdministratorAccess"
}

variable "aws_region" {
type = string
default = "us-east-1"
}

variable "env_name" {
type = string
default = "shaked"
}

variable "source_repository" {
type = string
default = "tolunaengineering/chorus"
}

variable "trigger_branch" {
type = string
default = "develop"
}

variable "trigger_events" {
type = list(string)
default = ["push","merge"]
}

variable "code_build_projects" {
type = list(string)
default = ["codebuild-test-devops-chorus","infra-pipeline-test"]
}

variable "connection_arn" {
type = string
default = "arn:aws:codestar-connections:us-west-2:080660034022:connection/a34c159c-b9cb-43be-b110-7b7ce8e244da"
}

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

variable "builds_stages" {
     type = list(string)
     default = ["codebuild-test-devops-chorus"]
 }


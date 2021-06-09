 variable "aws_profile" {
     type = string
 }

  variable "aws_region" {
     type = string
     default = "us-east-1"
 }

 variable "env_name" {
     type = string
 }

 variable "source_repository" {
     type = string
 }

 variable "trigger_branch" {
     type = string
     default = "develop"
 }

variable "trigger_events" {
     type = list(string)
     default = ["push","merge"]
 }

variable "build_stage" {
     type = string
 }

variable "connection_arn" {
    type = string
    default = "arn:aws:codestar-connections:us-west-2:080660034022:connection/a34c159c-b9cb-43be-b110-7b7ce8e244da"
}

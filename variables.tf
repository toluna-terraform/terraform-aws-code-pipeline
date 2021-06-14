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

variable "code_build_projects" {
type = list(string)
}

variable "connection_arn" {
type = string
}

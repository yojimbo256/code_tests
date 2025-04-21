terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 16.11.0" # Replace with your approved version if needed
    }
  }
}

provider "gitlab" {
  token = var.gitlab_token
  base_url = "https://gitlab.mda.mil/api/v4" # Update if internal GitLab differs
}

variable "gitlab_token" {
  description = "GitLab personal access token"
  type        = string
  sensitive   = true
}

variable "project_path" {
  description = "GitLab project path (e.g., group/project-name)"
  type        = string
  default     = "infrastructure/coder-templates/coder-templates.security-policy-project" # Update if needed
}

data "gitlab_project" "security_policy_project" {
  path_with_namespace = var.project_path
}

resource "gitlab_project_security_policy" "sast_policy" {
  project = data.gitlab_project.security_policy_project.id

  configuration = jsonencode({
    type    = "scan_execution_policy"
    name    = "enforce-sast"
    enabled = true
    rules = [
      {
        type     = "pipeline"
        branches = ["main"]
      }
    ]
    actions = [
      {
        scan = "sast"
      }
    ]
  })
}


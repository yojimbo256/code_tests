# =============================
# CODEOWNERS + Branch Protection via Terraform
# =============================

terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 16.6.1"
    }
  }
}

provider "gitlab" {
  token    = var.gitlab_token
  base_url = ""  # Replace if internal mirror differs
}

# Define project variables
variable "gitlab_token" {
  description = "GitLab personal access token"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "GitLab project ID (e.g. 'group/project')"
  type        = string
}

# Upload CODEOWNERS file
resource "gitlab_repository_file" "codeowners" {
  project        = var.project_id
  file_path      = ".gitlab/CODEOWNERS"
  branch         = "main"
  content        = "@safety_team *"
  commit_message = "Add CODEOWNERS to enforce approval from safety team"
}

# Enforce branch protection
resource "gitlab_branch_protection" "protect_main" {
  project             = var.project_id
  branch              = "main"
  push_access_level   = "no_access"
  merge_access_level  = "developer"
  unprotect_access_level = "maintainer"
  allow_force_push    = false
  code_owner_approval_required = true
}

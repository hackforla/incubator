variable "project_name" {
  type = string
  description = "HfLA project name (vrms, home-unite-us, etc)"
}

variable "application_type" {
  type = string
  description = "frontend, backend, or fullstack"
}

variable "environment" {
  type = string
  default = ""
  description = "what environment this is for - staging, production, etc"
}

variable "name" {
  type = string
  description = "secret name"
}

variable "length" {
  type    = number
  default = 48
  description = "if letting the module set the secret value, the length of the generated random secret"
}

variable "value" {
  type = string
  default = null
  description = "when set, the secret value, otherwise generated at random"
}
// --------------------------
// Amazon Certificate Manager (ACM)
// --------------------------

variable "domain_names" {
  type        = list(string)
  description = "The domains where the applications will be deployed"
}

variable "tags" {
  default = { terraform_managed = "true" }
  type    = map(any)
}

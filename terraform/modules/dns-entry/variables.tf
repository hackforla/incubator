variable "zone_id" {
  type = string
  description = "the Route 53 hosted zone id to create the entry"
}


variable "subdomain" {
    type = string
    description = "DNS entry - for example, in `qa.vrms.io` the subdomain is `qa`"
} 

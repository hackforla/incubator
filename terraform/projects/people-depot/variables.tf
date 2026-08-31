// peopledepot-dev.vrms.io sits in the vrms.io zone, which is owned by the vrms
// project. main.tf passes it in rather than repeating the zone id as a literal.
variable "vrms_zone_id" {
  type        = string
  description = "the vrms.io hosted zone id, owned by the vrms project"
}

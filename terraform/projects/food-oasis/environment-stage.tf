// postgis for neighborhood lookups (ST_* functions); earthdistance for location search,
// which uses its point <@> point operator. earthdistance brings cube with it, so cube is
// not listed. No Food Oasis migration creates either of the last two.
module "food_oasis_stage_database" {
  source           = "../../modules/database"
  project_name     = local.project_name_food_oasis
  application_type = "fullstack"
  environment      = "stage"
  extensions       = ["postgis", "earthdistance"]
}

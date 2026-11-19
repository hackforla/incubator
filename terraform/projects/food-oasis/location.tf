// Amazon Location place indexes for address search, one per environment. The containers
// reach them through their task role, so no Cognito identity pool is needed. Food Oasis is
// the only project using Location, so this stays here rather than becoming a module.
//
// These replace the place indexes foodoasisdev and foodoasisprod in the Food Oasis account
// (470363915259), which use the same data source and intended use. Production on Heroku
// actually uses foodoasisdev; foodoasisprod is unused (hackforla/devops#236).
//
// The app only uses the task role once hackforla/incubator#277 lands. Until then it turns
// address search off whenever IDENTITY_POOL_ID is unset, and these policies have no effect.

locals {
  food_oasis_environments = toset(["stage", "prod"])
}

resource "aws_location_place_index" "this" {
  for_each = local.food_oasis_environments

  index_name  = "${local.project_name_food_oasis}-${each.key}"
  description = "Food Oasis ${each.key} address search"
  data_source = "Esri"

  // SingleUse: results are shown and discarded, not stored. Storing results needs Storage.
  data_source_configuration {
    intended_use = "SingleUse"
  }

  tags = {
    project = local.project_name_food_oasis
  }
}

// searchPlaceIndexForText in hackforla/food-oasis server/app/services/aws-service.ts is the
// app's only Location call. Attached to the service's task role in hackforla/incubator#281
// (stage) and hackforla/incubator#282 (prod).
resource "aws_iam_policy" "location_search" {
  for_each = local.food_oasis_environments

  name        = "${local.project_name_food_oasis}-${each.key}-location-search"
  description = "Search the Food Oasis ${each.key} place index"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "SearchPlaceIndex"
        Effect   = "Allow"
        Action   = ["geo:SearchPlaceIndexForText"]
        Resource = aws_location_place_index.this[each.key].index_arn
      },
    ]
  })

  tags = {
    project = local.project_name_food_oasis
  }
}

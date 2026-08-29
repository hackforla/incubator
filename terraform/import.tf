# Adopts the two civictechindex ECR repositories, which predate the Terraform
# rewrite and were never brought into state. See hackforla/incubator#165.
import {
  to = module.civic-tech-index.module.ecr_backend_prod.aws_ecr_repository.this
  id = "civictechindex-backend-prod"
}

import {
  to = module.civic-tech-index.module.ecr_backend_stage.aws_ecr_repository.this
  id = "civictechindex-backend-stage"
}

# Adopts the civictechindex.org production frontend bucket. In AWS provider v4 and
# later the website configuration, policy and public access block are each their own
# resource, so each needs its own import. See hackforla/incubator#165.
import {
  to = module.civic-tech-index.aws_s3_bucket.website
  id = "civictechindex.org"
}

import {
  to = module.civic-tech-index.aws_s3_bucket_website_configuration.website
  id = "civictechindex.org"
}

import {
  to = module.civic-tech-index.aws_s3_bucket_public_access_block.website
  id = "civictechindex.org"
}

import {
  to = module.civic-tech-index.aws_s3_bucket_policy.website
  id = "civictechindex.org"
}

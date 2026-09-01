/**
 * # platform
 *
 * The shared AWS platform every incubator workload runs on: the VPC and its networking, the
 * ECS cluster and the EC2 capacity behind it, the load balancer, the security groups no
 * project owns, and the IAM the container instances and tasks assume.
 *
 * A singleton, instantiated once from `terraform/main.tf`. It takes no variables and writes
 * every name as a literal, because the live names do not follow one pattern -- the capacity
 * provider is `incubator-proc-ec2`, typo included.
 *
 * Everything here was adopted, not created; the `import` blocks are in `terraform/import.tf`.
 * See hackforla/incubator#184.
 *
 * Three things are deliberately left unmanaged, because Terraform cannot usefully own them:
 * the container instances and their EBS volumes (the autoscaling group creates them), the
 * EventBridge rule `ecs-managed-capacity-provider-rule` (ECS owns it), and two of the three
 * elastic IPs (the ELB service owns them).
 *
 * The outputs are not consumed yet. `modules/container` and `database.tf` still hardcode the
 * cluster name, VPC id, subnet ids, listener arn and role arn; rewiring them is follow-up.
 */

resource "aws_vpc" "this" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  tags = {
    Name = "incubator-prod-vpc"

    # Terragrunt-era, from a state file that no longer exists. Adopted, not believed.
    terraform_managed  = "true"
    terraform_user_arn = "arn:aws:iam::035866691871:user/DarrenP"
    last_changed       = "Sat 2021-May-08 20:09:31"
  }

  # Everything in the account lives in this VPC; a replacement is not recoverable.
  lifecycle {
    prevent_destroy = true
  }
}

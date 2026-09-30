// VRMS's app client in the shared Cognito user pool, adopted in place. See
// hackforla/incubator#17.
//
// No task_role_name: nothing in VRMS's container configuration references Cognito, so
// it is not granted admin operations on the pool.
module "shared_user_pool_access" {
  source = "../../modules/shared-user-pool-access"

  user_pool_id  = var.shared_user_pool_id
  user_pool_arn = var.shared_user_pool_arn

  clients = {
    vrms = {
      name = "VRMS"
    }
  }
}

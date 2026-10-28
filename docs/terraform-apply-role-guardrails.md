# Terraform apply role guardrails

This document answers [issue #138](https://github.com/hackforla/incubator/issues/138): which permissions should be explicitly denied while the Terraform apply role retains `AdministratorAccess`?

## Current state

`.github/workflows/terraform-apply.yaml` assumes `arn:aws:iam::035866691871:role/incubator-tf-apply` through GitHub OIDC after a push to `main` or a manual dispatch from `main`. The role is declared in `hackforla/devops-security`, where the AWS-managed `AdministratorAccess` policy is attached.

The Incubator Terraform currently creates and updates workload roles, inline policies, managed policies, policy attachments, and instance profiles. It does not manage IAM users, access keys, login profiles, group memberships, billing, or cost-management resources. A blanket deny on `iam:*` would therefore break legitimate applies, while targeted user and billing denies should not conflict with the current configuration.

## Recommendation

As the short-term control, attach a customer-managed explicit-deny policy named `IncubatorTerraformApplyGuardrail` to `incubator-tf-apply` in `hackforla/devops-security`, beside `AdministratorAccess`.

AWS evaluates an applicable explicit deny before an allow, so these statements override `AdministratorAccess`. Keeping the guardrail in `devops-security` also separates ownership: Incubator's apply role can use the policy but cannot change the Terraform that defines it.

The policy should deny four categories:

1. IAM-user lifecycle, console credentials, access keys, group membership, user policies, user permissions boundaries, and MFA-device changes.
2. Billing and cost-management namespaces, including both the legacy `aws-portal` namespace and the granular namespaces that replaced it.
3. Changes to the apply role or guardrail policy itself.
4. Direct role chaining with `sts:AssumeRole`.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyIamUserLifecycleAndCredentials",
      "Effect": "Deny",
      "Action": [
        "iam:AddUserToGroup",
        "iam:AttachUserPolicy",
        "iam:ChangePassword",
        "iam:CreateAccessKey",
        "iam:CreateLoginProfile",
        "iam:CreateServiceSpecificCredential",
        "iam:CreateUser",
        "iam:CreateVirtualMFADevice",
        "iam:DeactivateMFADevice",
        "iam:DeleteAccessKey",
        "iam:DeleteLoginProfile",
        "iam:DeleteServiceSpecificCredential",
        "iam:DeleteSigningCertificate",
        "iam:DeleteSSHPublicKey",
        "iam:DeleteUser",
        "iam:DeleteUserPermissionsBoundary",
        "iam:DeleteUserPolicy",
        "iam:DeleteVirtualMFADevice",
        "iam:DetachUserPolicy",
        "iam:EnableMFADevice",
        "iam:PutUserPermissionsBoundary",
        "iam:PutUserPolicy",
        "iam:RemoveUserFromGroup",
        "iam:ResetServiceSpecificCredential",
        "iam:ResyncMFADevice",
        "iam:TagUser",
        "iam:UntagUser",
        "iam:UpdateAccessKey",
        "iam:UpdateLoginProfile",
        "iam:UpdateServiceSpecificCredential",
        "iam:UpdateSigningCertificate",
        "iam:UpdateSSHPublicKey",
        "iam:UpdateUser",
        "iam:UploadSigningCertificate",
        "iam:UploadSSHPublicKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyBillingAndCostManagement",
      "Effect": "Deny",
      "Action": [
        "account:*",
        "aws-portal:*",
        "bcm-data-exports:*",
        "billing:*",
        "billingconductor:*",
        "budgets:*",
        "ce:*",
        "consolidatedbilling:*",
        "cur:*",
        "freetier:*",
        "invoicing:*",
        "payments:*",
        "purchase-orders:*",
        "tax:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyChangesToApplyRole",
      "Effect": "Deny",
      "Action": [
        "iam:AttachRolePolicy",
        "iam:DeleteRole",
        "iam:DeleteRolePermissionsBoundary",
        "iam:DeleteRolePolicy",
        "iam:DetachRolePolicy",
        "iam:PutRolePermissionsBoundary",
        "iam:PutRolePolicy",
        "iam:UpdateAssumeRolePolicy",
        "iam:UpdateRole",
        "iam:UpdateRoleDescription"
      ],
      "Resource": "arn:aws:iam::035866691871:role/incubator-tf-apply"
    },
    {
      "Sid": "DenyChangesToGuardrailPolicy",
      "Effect": "Deny",
      "Action": [
        "iam:CreatePolicyVersion",
        "iam:DeletePolicy",
        "iam:DeletePolicyVersion",
        "iam:SetDefaultPolicyVersion"
      ],
      "Resource": "arn:aws:iam::035866691871:policy/IncubatorTerraformApplyGuardrail"
    },
    {
      "Sid": "DenyDirectRoleChaining",
      "Effect": "Deny",
      "Action": "sts:AssumeRole",
      "Resource": "*"
    }
  ]
}
```

The billing statement intentionally denies reads as well as writes. Terraform apply has no billing responsibility, denying each namespace avoids gaps as AWS's fine-grained billing actions evolve, and no current Incubator resource depends on those APIs.

## Alternatives considered

### Permissions boundary on the apply role

A permissions boundary can express the same ceiling by adding `Allow` for `*` and the explicit-deny statements above. This is semantically attractive, but a boundary on only `incubator-tf-apply` does not constrain roles or services that the apply role creates. It also needs the same anti-tamper protection. It adds deployment complexity without closing the principal remaining bypass, so it is not the recommended first control.

### Replace `AdministratorAccess` with a least-privilege allow policy

This is the stronger long-term result. Generate a fresh Terraform plan, render it to sensitive plan JSON, use deterministic analysis to produce a baseline policy, and then refine it with observed CloudTrail activity and IAM Access Analyzer. Repeat this against representative create, update, replace, and delete plans; a single no-change plan cannot reveal the permissions needed for future applies.

The plan files can contain secrets and must not be committed or printed. A reproducible starting flow is:

```bash
terraform -chdir=terraform plan -out=plan.tfplan
terraform -chdir=terraform show -json plan.tfplan > plan.json
uvx iam-policy-autopilot@latest generate-policies "$(pwd)/terraform/plan.json" --region us-west-2 --account 035866691871 --pretty
rm -f terraform/plan.tfplan terraform/plan.json
```

Replacing `AdministratorAccess` requires a separate implementation issue because the repository manages a broad and changing set of AWS resources and the generated baseline needs validation against real plans.

### Account-level service control policy

An AWS Organizations service control policy is the strongest way to make the denied actions unavailable even to roles or services created by the apply job. It is not a drop-in solution here: the same AWS account hosts `devops-security`, which legitimately manages IAM users, and an SCP would need carefully reviewed exceptions for that control plane. Organization availability and management-account placement also need confirmation.

## Security limit

This proposal reduces accidental and direct misuse; it is not a complete containment boundary for malicious Terraform merged to `main`. The apply role still needs to create workload roles, attach policies, pass roles to AWS services, and create compute. Those capabilities can be combined to delegate privileges to a service that is not subject to the apply role's attached policy.

Closing that path requires either the least-privilege replacement, an enforced permissions boundary on every role the apply role can create or pass, or an account/organization control that applies to delegated principals too. Reviewers should not describe the short-term policy as preventing all privilege escalation.

## Implementation and validation

The implementation belongs in `hackforla/devops-security/terraform/aws-gha-oidc-providers.tf`, because that repository owns `incubator-tf-apply`.

1. Define `IncubatorTerraformApplyGuardrail` as a customer-managed policy and attach it to `incubator-tf-apply` without removing `AdministratorAccess`.
2. Run the `devops-security` Terraform plan and confirm that only the new policy and attachment are proposed.
3. After apply, simulate representative calls against the role. `iam:CreateUser`, `iam:CreateAccessKey`, and `billing:UpdateBillingPreferences` should be explicitly denied; `ec2:DescribeInstances` should remain allowed.
4. Open a no-op Incubator Terraform pull request and confirm that plan can still refresh the state.
5. Merge a harmless Terraform change through the normal reviewed path and confirm apply succeeds.
6. Attempt to detach the guardrail or alter its default version while using `incubator-tf-apply`; both operations should be explicitly denied.

Example simulation:

```bash
aws iam simulate-principal-policy \
  --policy-source-arn arn:aws:iam::035866691871:role/incubator-tf-apply \
  --action-names iam:CreateUser iam:CreateAccessKey billing:UpdateBillingPreferences ec2:DescribeInstances
```

## AWS references

- [Policy evaluation logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)
- [Permissions boundaries for IAM entities](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies_boundaries.html)
- [Secure deployments with IAM permissions boundaries](https://aws.amazon.com/blogs/devops/secure-cdk-deployments-with-iam-permission-boundaries/)
- [Actions, resources, and condition keys for IAM](https://docs.aws.amazon.com/service-authorization/latest/reference/list_iam.html)
- [Migrating access control for AWS Billing](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/migrate-granularaccess-whatis.html)
- [Actions, resources, and condition keys for AWS Billing](https://docs.aws.amazon.com/service-authorization/latest/reference/list_billing.html)
- [IAM policy simulation](https://docs.aws.amazon.com/cli/latest/reference/iam/simulate-principal-policy.html)

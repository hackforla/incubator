# Installation Instructions
Deploying with the Incubator requires:

## 1. Installing AWS CLI version 2
Find your corresponding platform here
https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html and make sure to install CLI Version 2. 

Confirm aws installation with `which aws`. 

```sh
which aws
/usr/local/bin
```


## 2. Setting up the AWS CLI with Hack for LA credentials 
Access keys should be given to you by administrators in order to use with `aws configure`. This command will setup a default  profile, but best practices would to configure a named profile. 

Named profiles will setup different profiles for AWS to distinguish credentials. One's AWS account may already have other aws credentials from previous AWS projects and works, so a default profile won't suffice. With `--profile`, make sure to switch to the right named profile by adding `--profile <profile name>` at the end of aws commands. 

```sh
aws configure --profile hfla-example

AWS Access Key ID [None]: <insert access key id>
AWS Secret Access Key [None]: <insert secret accesskey>
Default Region Name [None]: us-west-2
Default output format [None]: None
```

Afterwards, verify with `aws sts --profile hfla-example get-caller-identity`

```sh
aws sts --profile hfla-example get-caller-identity
{
    "UserId": "ABCDEFGH12345",
    "Account": "1234567891011",
    "Arn": "arn:aws:iam::1234568791011:user/user@email.com"
}
```

https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html
## 3. Installing Terraform
The latest Terraform won't apply for incubator applications, instead Terraform version `0.15.1` needs to be installed. This assumes a package manager like [Homebrew](https://brew.sh/) is installed. 

### Homebrew (OSX/Linux)
```
brew update
brew install terraform@0.15.1
``` 

### Apt-get (Linux)
```
sudo apt-get update
sudo apt-get install terraform=0.15.1
```

Confirm installation with `terraform --version`. 

```sh
terraform --version
Terraform v0.15.1
on linux_amd64
```

## 4. Installing Terragrunt 

### Homebrew (OSX/Linux)
https://terragrunt.gruntwork.io/docs/getting-started/install/

```
brew update
brew install terragrunt
``` 

Confirm installation with `terragrunt --version`
```sh
terragrunt --version
terragrunt version v0.32.1
```


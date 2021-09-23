# Setting up Incubator environment
For the incubator environment, one should have their aws credentials, terraform, and terragrunt setup. 

## 1.) Clone the repo
Clone the incubator repo from here https://github.com/hackforla/incubator using your preferred method. 
```sh
git clone https://github.com/hackforla/incubator
```

## 2.) Obtain the `rds.hcl` file from administrators
This is a file with sensitive database information. Do **NOT** commit this file to git for the public to view. 

```
echo 'incubator/rds.hcl` >> .gitignore
```

One will obtain a `rds.hcl` file from administrators, and it will be placed in the `/incubator` directory. 

## 3.) Set AWS_PROFILE variable

```sh
export AWS_PROFILE=<named-profile-used-for-hfla>
```

After this one should be able to deploy to the incubator with Terragrunt. 
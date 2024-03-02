# **How to Contribute to Incubator**
> ℹ️ **This page is under development**

Below are guidelines for contributing to the incubator repository hosted on GitHub. These guidelines are primarily recommendations rather than strict rules. Use your discretion and feel free to suggest changes to this document by submitting a pull request.

**This guide assumes that you have finished the onboarding process, which involves joining the Hack for LA Slack, GitHub, and Google Drive. If you haven't completed onboarding yet, please visit the [Getting Started Page](https://www.hackforla.org/getting-started).**

**The team recommends using [VS Code](https://code.visualstudio.com/download) as the preferred text editor for working on code, but feel free to utilize a text editor of your preference.**

**If you have any additional questions about your contribution process, please feel free to reach out to the team in the #incubator Slack channel.**
<br><br>

## **Table of Contents**
- [**How to Contribute to Incubator**](#how-to-contribute-to-incubator)
- [**Table of Contents**](#table-of-contents)
- [**Setting up the local development environment**](#setting-up-the-local-development-environment)
    - [**Creating a personal AWS account**](#creating-a-personal-aws-account)
    - [**Fork the repository**](#fork-the-repository)
    - [**Clone (Create) a copy on your computer**](#clone-create-a-copy-on-your-computer)
        - [**Verify `origin` remote url**](#verify-origin-remote-url)
        - [**What if you accidentally cloned using the repository URL from the HackForLA Github (instead of the fork on your Github)?**](#what-if-you-accidentally-cloned-using-the-repository-url-from-the-hackforla-github-instead-of-the-fork-on-your-github)
            - [**i. Reset `origin` remote url**](#i-reset-origin-remote-url)
            - [**ii. Add an `upstream` remote**](#ii-add-an-upstream-remote)

## **Setting up the local development environment**

### **Creating a personal AWS account**

- Go to [amazon.com](https://aws.amazon.com/) and click `"Sign In to the Console" > "Create a new AWS account."` 
- Enter your email, create a password, and input your basic details. Then provide your contact information and complete the identity verification process.
- Enter your credit/debit card information for billing purposes, opt for the free basic support.
- Agree to the AWS Customer Agreement and Service Terms, complete the registration by clicking `"Create Account and Continue"`, verify your phone number via text or call, confirm your email address following the instructions in the confirmation email, and finally sign in to access your new AWS account using your email and password.
- Follow this [video guide](https://youtu.be/CjKhQoYeR4Q?si=78GhlDLV5zZu8qwh) for deeper explanations.

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

***

## **Fork the repository**

Fork the hackforla/incubator repository by clicking <a href="https://github.com/hackforla/incubator/fork"> <button> <img src="https://user-images.githubusercontent.com/17777237/54873012-40fa5b00-4dd6-11e9-98e0-cc436426c720.png" width="8px"> Fork</button></a>
. A fork is a copy of the repository that will be placed on your GitHub account.

**Note:** It should create a URL that looks like the following -> `https://github.com/<your_GitHub_user_name>/incubator`.

**For example** -> `https://github.com/octocat/incubator`.

**Be Aware:** What you have created is a forked copy in a remote version on GitHub. It is not yet on your local machine.

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

## **Clone (Create) a copy on your computer**

Create a new folder in your computer that will contain `hackforla` projects.

In your command line interface (Terminal, Git Bash, Powershell), move to where you want your new folder to be placed and create a new folder in your computer that will contain `hackforla` projects. After that, navigate into the folder(directory) you just created.

For example:
```bash
mkdir hackforla
cd hackforla
```

and run the following commands:

```bash
git clone https://github.com/<your_GitHub_user_name>incubator.git
```

For example if your GitHub username was `octocat`:
```bash
git clone https://github.com/octocat/incubator.git
```

You should now have a new folder in your `hackforla` folder called `incubator`. Verify this by changing into the new directory:

```bash
cd incubator
```

#### **Verify `origin` remote url**

Verify that your local cloned repository is pointing to the correct `origin` URL (that is, the forked repo on your own Github account):
```bash
git remote -v
```
You should see `fetch` and `push` URLs with links to your forked repository under your account (i.e. `https://github.com/<your_GitHub_user_name>/incubator.git`). You are all set to make working changes to the devops-security on your local machine.

However, we still need a way to keep our local repo up to date with the deployed incubator. To do so, you must add an upstream remote to incorporate changes made while you are working on your local repo. Run the following to add an upstream remote URL & update your local repo with recent changes to the `hackforla` version:

```bash
git remote add upstream https://github.com/hackforla/incubator.git
git fetch upstream
```

After adding the upstream remote, you should now see it if you again run `git remote -v` :
```bash
origin  https://github.com/<your_GitHub_user_name>/incubator.git (fetch)
origin  https://github.com/<your_GitHub_user_name>/incubator.git (push)
upstream        https://github.com/hackforla/incubator.git (fetch)
upstream        https://github.com/hackforla/incubator.git (push)
```
#### **What if you accidentally cloned using the repository URL from the HackForLA Github (instead of the fork on your Github)?**

##### **i. Reset `origin` remote url**

Set your forked repo on your Github as an `origin` remote:
```bash
git remote set-url origin https://github.com/<your_GitHub_user_name>/incubator.git
```

For example if your GitHub username was `octocat`:
```bash
git remote set-url origin https://github.com/octocat/incubator.git
```

##### **ii. Add an `upstream` remote**

Add another remote called `upstream` that points to the `hackforla` version of the repository. This will allow you to incorporate changes later:
```bash
git remote add upstream https://github.com/hackforla/incubator.git
```

<sub>[Back to Table of Contents](#table-of-contents)</sub>
***

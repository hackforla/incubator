# How to Contribute to Incubator (Draft)

This guide contains instructions for how to download the Incubator repository, edit it, and make a PR to the Incubator repo.

### 1. Fork the repo to your own github account.
- On GitHub.com, navigate to the hackforla/incubator repository.
- In the top-right corner of the page, click **Fork**.

![image](https://github.com/hackforla/incubator/assets/62266977/a179728b-3880-4caa-b49a-64cb71fd7773)

- On the next page, keep the default settings and click **Create fork**.

### 2. Clone your forked repository
Before creating a copy to your local machine, you must have Git installed. You can find instructions for installing Git for your operating system [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).

The following steps will clone (create) a local copy of the forked repository on your computer.
- On GitHub.com, navigate to **your fork** of the Incubator repository.
- Above the list of files, click **<> Code**
    ![image](https://github.com/hackforla/incubator/assets/62266977/9c4e6a70-bc09-4231-a4ed-2e34d7128249)

 
- Copy the URL for the repository.
 
    ![image](https://github.com/hackforla/incubator/assets/62266977/f828bd39-0d5f-4add-8398-2ae6f6a74320)

- Create a new folder on your machine that will contain the incubator project
- In your preferred code editor, open a command line interface and cd into the folder you just created where your cloned directory will be located.
- Type ```git clone```, and then paste the URL you copied earlier. It will look like this, with your Github username instead of ```[YOUR-USERNAME]```:

``` git clone https://github.com/[YOUR-USERNAME]/incubator.git ```
  
You should now have a new folder in your hackforla folder called incubator. Verify this by changing into the new directory:

```cd incubator```

### 3. Create a branch and change to the branch

To create a branch and switch to that branch in one step, enter the following:
   ```
   git checkout -b [CREATE A BRANCH NAME]

   ```

### 4. Add or edit files. (If setting up a new project on incubator, see those instructions here).

### 5. Commit files to your repo

### 6. Make a PR to incubator repo

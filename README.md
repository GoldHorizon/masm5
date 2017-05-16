# masm4
CS3B masm4 Assignment

---

## Using `git`

  With git, each project has a repository.  For example, this project's repository is called `masm4`, hence the local folder and online URL names.  When working with git on this project, you want to be using your command prompt (In our case, git bash is probably what we'll use) and make sure your working directory is in the masm4 folder.

  i.e. `cd Documents\workspace\CS3B\masm4\`

### Creating a new branch

```bash
git checkout master
git checkout -b nameOfBranch
git push origin nameOfBranch
```

When working on a project, you want to make sure you're working on a separate branch from anyone else working on the same project.  This way, you can avoid any problems that arise when two people change the same file.  Perhaps one person creates a procedure/function in a file called `AllocateMemory()`, and saves it to their local branch, only to realize later when they try to share their code that someone else already implemented the same method in a completely different way.  This is what you want to avoid.  If you're going to work on a different part of the project, you'll want a branch that specifies exactly what you're working on.

The first step is to make sure you are starting in your master branch: `git checkout master` in our case.  The guarantees your new branch is branching off of the main branch that is already in a working and stable state.  You can then easily make a new branch with the following line in bash: `git checkout -b nameOfBranch`

This will create a new branch called "nameOfBranch". So if you were working on a procedure called "AllocateMemory", you might want to use the following command:
`git checkout -b allocateMemory`

The name of the branch should be short, but specific enough to accurately describe what you're working on.

After you've created your branch, it's only on your local system.  The `checkout -b` command does NOT create a version of your branch online on github; it simply creates new settings for your branch on your system, which allows it to keep track of changes made to files only on your branch, not on any others.

So, when you make a new branch, you should always push it to the github repository, syncing it online.  This way, people know you're working on this portion of the project and that's where they can find any code you'll be writing.  You can push it online using the following command: `git push origin nameOfBranch`.  Tab completion will allow you to complete most if not all of these keywords, including the name of the branch you just created.

Now you can begin to work on your branch!

### Working on your branch and pushing to github

```bash
git add -A
git commit -m "Message for what you are committing"
git push origin nameOfBranch
```

### Syncing a branch with a new version on github

```bash
git checkout nameOfBranch
git pull origin nameOfBranch
```

### Merging changes from a parent branch (e.g. master) with your branch (Advanced)

```bash
git checkout nameOfBranch
git pull origin master
```
NOTE: If changes in master overlap with changes in your branch, there will be merge conflicts.  Often times this can be infuriating and rough to go through.  If this happens you can try to abort with `git reset --hard HEAD`, then I can try to do the merge conflict.

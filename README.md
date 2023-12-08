# digitalproducts

Repository-specific notes
====================
The usual structure of repositories is adjusted to accommodate the potentially lengthy piloting process. Therefore, the main folder is split into `piloting` and `draft`. The code-work prior to the draft will be tracked in `piloting`; whereas the main experiments and final results will be  collected in `draft`.

Using the repository
====================

### Working with Git
- **Installing [Git](https://git-scm.com/downloads):**
  - Work either in the command line or [GitHub Desktop](https://desktop.github.com/):
 	- Click [here](http://swcarpentry.github.io/git-novice/) or for a git tutorial, [here](https://docs.gitlab.com/ee/gitlab-basics/start-using-git.html) for a for tutorial for working with git via the command line and [here](https://docs.github.com/en/desktop/installing-and-configuring-github-desktop/overview/getting-started-with-github-desktop) for a Github Desktop tutorial. 

- **Cloning the repository:**
 	- `git clone https://<your git username>@github.com/gulmezoglubeyza/welfare.git`, or manually via GitHub Desktop.
 	- Make sure to clone the repository to the right path (`/Applications/Github/repository-name/` for Mac)

- **Using Git with Dropbox:**
    - Download Dropbox from [here](https://www.dropbox.com/install). Ensure that the Dropbox `welfare` folder is shared with your account.
    - Symlink the folders you don't want to transfer to Git from Dropbox to a folder in Github. This way allows access to Dropbox files from the GitHub folder.
    - In this repository `data` and `output/figures` are not pushed to the repository and instead kept on the Dropbox folder. 
      - Click [here](https://www.howtogeek.com/297721/how-to-create-and-use-symbolic-links-aka-symlinks-on-a-mac/) for instructions.
      - `mklink /J PATH-TO-REPOSITORY-GITHUB\drive\PATH-TO-REPOSITORY-DROPBOX` in the Windows command prompt. 
      - `ln -s PATH-TO-REPOSITORY-DROPBOX PATH-TO-REPOSITORY-GITHUB/drive` in the Mac terminal.

### Good practices
- If you're using a Mac, do not sync your GitHub folder with iCloud. Go to "System Preferences/iCloud/iCloud drive/options" to see which folders are linked with iCloud. When cloning the repository, specify a path which is not in one of these folders.
- Make sure to save folders/files with names **without** blanks. This is crucial for their import to programs such as `Latex`.
- Commit and push your work regularly so everyone can use your results.
- If you want a specific person to see your comment, make sure to tag them by adding a @ sign in front of their username.
- When referring to a certain files, comments, or lines of code, it's very helpful to link them for the person reading your comments.
- Do not merge a branch to the master branch without a pull request.
- Always tag the issue or pull request to your commit when pushing changes, this way one can track the progress from clicking on the commits within the issues.

Click [here](https://github.com/gulmezoglubeyza/Instagram/issues/1#issuecomment-1208633613) for a general overview of Git and Github.

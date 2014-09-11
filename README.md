expandr
=======

a cool shell script for git keyword expansion.

it helps keep your AWS credentials (or whatever) safe

...

Here I describe my method for using keyword expansion filters to substitute sensitive values and directory paths, etc. into code configuration files in a code project.

##**What is git?**

"git" is a popular version control system designed by Linus Torvalds. A "git repository" is a collection of files inside a special ".git" folder. Together all those files represent sets of changes to a project, called "commits". The ".git" directory lives inside your "working directory", which is the place where all the files in your code project live at any given time. All of the files in the working directory (except any that are "ignored") are considered to be "tracked" by git. If you want to commit any new changes to files or newly added files, you "add" these changes to your "staged" changes. Once the changes are staged, then you commit, and all those staged changes go into your repository, where together with all previous changes in that branch, they represent the state of all the tracked files that have been staged and committed from that point back through time all the way to the beginning.

In other words, a new commit forever saves the state of all the staged files along with any tracked but unchanged files that were in the working directory at the time of the commit. (Any new files or changes that were not staged, AKA "unstaged", but were inside the working directory will not be represented by that commit.) Later, when you "check out" a commit, it means that you're restoring the state of all the files in the working directory to a particular state represented by that commit, and (at least by default) you're also eliminating anything that was not part of that commit.

When you "pull" changes from a remote repository (say on github.com), git is downloading data just from inside the remote repository to inside your local repository. Then it does a checkout on the default branch of the project (usually "master", though you can call it anything you want).

You can visualize this process as such:

**checkout:**
> commit stored in repository
> --> restored working directory to state of commit

**add:**
> changes to things in working directory
> --> staged changes

**commit:**
> state of tracked files including only staged changes + all unchanged tracked files
> --> repository

##**What are git filters?**

Git filters are special steps that you may set up called "clean" and "smudge". These steps automatically happen whenever you add changes or checkout files.

To create a filter for a specific repository, you can edit the file at `.git/config`, and add text to describe what the filter does like this:

```
[filter "name_of_filter"]
    clean  = unix_command_to_run --argument1 myArgument --argument2 myOtherArgument
    smudge = unix_command_to_run --argument myArgument`
```

Note: git refers to the unix_command_to_run and all its arguments as the "filter driver". Each filter has up to two drivers: one for clean and one for smudge.

Also note: the rule is that running the file through clean and then back through smudge should result in the same file as when you started, and vice versa. As well, running it through multiple cleans or multiple smudges in a row should have the same effect as just one in a row. Bear that in mind when you set up your filters. (I recommend using unit tests to make sure.)

Just adding the filter to your **config** file won't do anything. Next you need to tell git which files you want to "pipe" through that filter. To designate which files to use, make a file (or files, each) called .gitattributes, which can live anywhere in your working directory. In them you can designate certain files that should be run through a particular filter. The way you designate a filter and files to be filtered is like this:

*line of text inside a **.gitattributes** file*:
`path/to/file filter=name_of_filter`

Note: the `path/to/file.php` is relative to where the .gitattributes file is that it is inside of. Wow that was grammatically awkward. But you know what I mean, right?

To check what filters are currently in effect for a given file in your working directory, on the command line you can type:

`git check-attr -a path/to/file.php`

If everything is setup right you should see:

`file.php: filter: name_of_filter`

OK, so, below, you can visualize our previous workflow visualization, now with git filters in action:

**checkout:**
> commit stored in repository
> --> file designated by .gitattributes
> --> filter named by .gitattributes for that file
> --> run file through **smudge** filter driver designated in .git/config
> --> restored working directory to state of commit

**add:**
> changes to things in working directory
> --> file designated by .gitattributes
> --> filter named by .gitattributes for that file
> --> run file through **clean** filter driver
> --> staged changes

Rule of thumb: don't designate more than one filter per file in your working directory (git will only run one, and the rules for which one overrides which one are confusing). **Critically: If you need to run multiple unix commands on each file, then you need to make your filter driver be a *script that runs multiple unix commands*.** And guess what? That's what **expandr.sh** is~~!!1 But wait, there's more.

##**What is keyword expansion? Especially in relation to git filters?**

Keyword expansion is when a program replaces a @DUMMY_STRING@ with an actual value like "foobar" or similar. What git filters let you do is use scripts like **expander.sh** that employ unix commands like `sed` to do keyword expansion (and contraction, for that matter). (Expansion is "smudge" and contraction is "clean".)

**Why would you want to use git keyword expansion?

- protect sensitive passwords from ending up in your repository
- swap out different include paths depending on the server environment
- change a hard-coded admin e-mail address depending on the code branch

Lets say that you've been handed a code project where AWS credentials are hard-coded into code files in the project itself. For security reasons, you don't want them there. They'll end up in github and they'll be stored all throughout your commit history. You can use keyword expansion filters to replace them with dummy values *inside* the repository, without affecting the files in your working directory. That way you can push your project to github and no sensitive information will go with it.

There are other approaches to this, of course, and you might already be thinking that your preferred way is *obviously better*. Well, I'm not here to sell you on using git keyword expanion filters; if your way is better then you know where the "back" button is :D But there are some really cool advantages to using git keyword expansion filters, like being able to have git track changes to all the files that contain your passwords, without it storing any of them. Anyway, I'm not here to think for you, so I'll stop now.

But let me just point out that you can have a different .gitattributes files on each branch, thus letting you keyword-swap differing sets of credentials and include paths, etc., on each branch.

##**How to use expandr.sh**

First edit the script and put the sensitive values in at the [1] slot in the various appropriate arrays. Customize the variables and functions in the script to best fit your needs.

As expandr is currently scripted, the order of arguments does not matter. It is highly recommended that you use all available options each time, and that you customize the script to fit the needs of your particular code scenario. The actual code structure of this script was set up purely for my own project and it's intended by publishing this as open source that people would take this and adapt the code of this script to their own purposes.

Required arguments:

	Either:
	**--action clean**
		Designates that the dummy values should replace the actual values.
	Or:
	**--action smudge**
		Designates that the actual values should replace the dummy values.

Options:

	**--branch ~ARGUMENT~**
		Designates that the value of a variable named FRAMEWORK_DIR_~ARGUMENT~ will be swapped for the value of the variable named FRAMEWORK_DIR.

**smudge**-only options (may only be used if **--action smudge** is specified):

	**--db ~ARGUMENT~**
	    Designates that the value of a variable named ~ARGUMENT~_DB_NAME will be swapped for the value of the variables named MAIN_DB_NAME and TESTS_DB_NAME

**clean**-only options (may only be used if **--action clean** is specified):

	**--db-domain ~ARGUMENT~
		Designates that *the value of* a variable named ~ARGUMENT~_DB_DUMMY_NAME will be used as the dummy value that gets swapped in as the replacement
		for the value of any occurrences of the variables LIVE_DB_NAME, TEST_DB_NAME, or STAGING_DB_NAME during the **clean** action.

##**Example setup files:**

Firstly my **.git/config** file I have:
```
[filter "main_config_live"]
    clean  = ~/.gitfilters/expandr.sh --action clean  --db-domain main
    smudge = ~/.gitfilters/expandr.sh --action smudge --accounts live    --db live    --branch live
[filter "tests_config_live"]
    clean  = ~/.gitfilters/expandr.sh --action clean  --db-domain tests
    smudge = ~/.gitfilters/expandr.sh --action smudge --accounts sandbox --db test    --branch live
[filter "main_config_staging"]
    clean  = ~/.gitfilters/expandr.sh --action clean  --db-domain main
    smudge = ~/.gitfilters/expandr.sh --action smudge --accounts sandbox --db staging --branch staging
[filter "tests_config_staging"]
    clean  = ~/.gitfilters/expandr.sh --action clean  --db-domain tests
    smudge = ~/.gitfilters/expandr.sh --action smudge --accounts sandbox --db staging --branch staging
[filter "main_config_test"]
    clean  = ~/.gitfilters/expandr.sh --action clean  --db-domain main
    smudge = ~/.gitfilters/expandr.sh --action smudge --accounts sandbox --db test    --branch test
[filter "tests_config_test"]
    clean  = ~/.gitfilters/expandr.sh --action clean  --db-domain tests
    smudge = ~/.gitfilters/expandr.sh --action smudge --accounts sandbox --db test    --branch test
[filter "all_tests"]
    clean  = ~/.gitfilters/expandr.sh --action clean  --db-domain tests
    smudge = ~/.gitfilters/expandr.sh --action smudge --accounts both    --db test    --branch staging
[merge "ours"]
	driver = true
[merge]
    renormalize = true
```

For example I maintain three branches, each with its own set of git filters.

Firstly in each branch I have a .gitattributes file like this:

**Live branch:**
```
config/app.php filter=main_config_live
config/framework.php filter=main_config_live
tests/config/app.php filter=tests_config_live
tests/config/framework.php filter=tests_config_live
.gitattributes merge=ours
```
**Staging branch:**
```
config/app.php filter=main_config_staging
config/framework.php filter=main_config_staging
tests/config/app.php filter=tests_config_staging
tests/config/framework.php filter=tests_config_staging
.gitattributes merge=ours
```
**Test branch:**
```
config/app.php filter=main_config_test
config/framework.php filter=main_config_test
tests/config/app.php filter=tests_config_test
.gitattributes merge=ours
```


```

(The merge commands are there to reduce headaches. Trust me. ;D) Also of course there are other things in my git config file than just the above, but the above are the only parts relevant to keyword expansion.

Lastly the shell script itself is **expandr.sh**.

I've also put the above example config file into a file named, well, "config". And the example gitattributes file is in "gitattributes_sample".

##**How to add expandr to your project**

To add this simply add the expandr.sh to a directory (default location ~/.gitfilters) and populate the values of the variable with your credenitals. Next, customize your .git/config file as described above. Lastly, create a .gitattribtues file appropriate to each branch and commit it into each branch. After committing in the .gitattributes file, you'll then need to execute this command on the command line while in the root of your project's working directory to make the filter do its magic (you won't lose any unstaged or uncommitted changes):

```
git stash save
git checkout HEAD -- "$(git rev-parse --show-toplevel)"
git stash pop
```

Lastly you can use the awesome Java utility, [bfg repo-cleaner](http://rtyley.github.io/bfg-repo-cleaner/), to cleanse your repository's *history* of any of the sensitive values (this won't affect your most recent *current* commits, but back-up your working directory first just in case). **bfg** will replace sensitive values with ***REMOVED***. Just make a text file list of all the values to cleanse and run bfg like this:

`java -jar ~/bfg-1.11.7.jar --protect-blobs-from live,test,staging,master --replace-text /path/to/values_list.txt`

... where "live,test,staging,master" are the branches whose most recent commits you want to protect from cleansing. Remember, if you followed the above steps, your **clean** filters will already have removed any of these sensitive values, assuming the ones in your values_list.txt are also all in expandr.sh. When you run bfg it will tell you if any of your protected commits are "dirty". If they are, something went wrong, but you'll have to troubleshoot that yourself. Just backup your repo before each step so you can start from a fresh repo if something gets corrupted (I only ran into corruption issues when I was bugtesting the script and once or twice I had to kill the git process in the middle of a checkout).

##**Parting shot**

There is a lot more that could be done with this, but I figured I'd just leave this here, since it took me a lot of googling and stackoverflowing to finally come upon a working solution, and it would have been nice had someone put something like this out there previously, since a lot of this was non-obvious.

I make no claims that this is the best way to do this. If there are portability issues with this code between platforms, then I'd like to get submissions on fixes. Thanks.
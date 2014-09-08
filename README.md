expandr
=======

a cool shell script for git keyword expansion.

it helps keep your AWS credentials (or whatever) safe

...

Here I describe my method for using keyword expansion filters to substitute sensitive values and directory paths, etc. into code configuration files in a code project.

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

Then for example in my **.git/config** file I have:
```
[filter "main_config_live"]
    clean  = ../filters/_main_config.sh --action clean  --db-domain main
    smudge = ../filters/_main_config.sh --action smudge --accounts live    --db live    --branch live
[filter "tests_config_live"]
    clean  = ../filters/_main_config.sh --action clean  --db-domain tests
    smudge = ../filters/_main_config.sh --action smudge --accounts sandbox --db test    --branch live
[filter "main_config_staging"]
    clean  = ../filters/_main_config.sh --action clean  --db-domain main
    smudge = ../filters/_main_config.sh --action smudge --accounts sandbox --db staging --branch staging
[filter "tests_config_staging"]
    clean  = ../filters/_main_config.sh --action clean  --db-domain tests
    smudge = ../filters/_main_config.sh --action smudge --accounts sandbox --db staging --branch staging
[filter "main_config_test"]
    clean  = ../filters/_main_config.sh --action clean  --db-domain main
    smudge = ../filters/_main_config.sh --action smudge --accounts sandbox --db test    --branch test
[filter "tests_config_test"]
    clean  = ../filters/_main_config.sh --action clean  --db-domain tests
    smudge = ../filters/_main_config.sh --action smudge --accounts sandbox --db test    --branch test
[merge "ours"]
	driver = true
[merge]
    renormalize = true
```

(The merge commands are there to reduce headaches. Trust me. ;D) Also of course there are other things in my git config file than just the above, but the above are the only parts relevant to keyword expansion.

Lastly the shell script itself is **expandr.sh**.

I've also put the above example config file into a file named, well, "config". And the example gitattributes file is in "gitattributes_sample".

There is a lot more that could be done with this, but I figured I'd just leave this here, since it took me a lot of googling and stackoverflowing to finally come upon a working solution, and it would have been nice had someone put something like this out there previously, since a lot of this was non-obvious.

I make no claims that this is the best way to do this. If there are portability issues with this code between platforms, then I'd like to get submissions on fixes. Thanks.
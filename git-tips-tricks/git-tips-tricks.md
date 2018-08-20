# Git Tips & Tricks

Git is often not very intuitive, it can be complicated, and it's easy to shoot
yourself in the foot.

If you are trying to use git just as a replacement for Subversion or CVS,
for example, you won't have much fun with it, maybe even less.

If you learn to use it you can get very effective.

This article covers some common problems and tricks.

## Did you ever commit something to the wrong branch?

Yes, I did. You will see later how to fix it, but first let's find out how
to avoid this.

To make sure you're on the correct branch you can always do:

    git branch

But why type a command if you can have that information always present in your
commandline prompt?

Let's say this is your current prompt:

    user@host:~/git-tips-tricks-repos%

After you add this very simple function ([vc_prompt.sh](vc_prompt.sh)) it will look like this:

    user@host:~/git-tips-tricks-repos[master]%

Another command you are probably using often (at least you should!) is

    git status

(This will also show the current branch, by the way.)

To see if you have any uncommited changes you can also use your prompt.
Here's how it will look like if you modify any file that is already tracked by
git:

    user@host:~/git-tips-tricks-repos[master*]%

If you checkout a remote branch or a specific commit, you will see something
like this:

    user@host:~/git-tips-tricks-repos[(HEAD detached at 6eab83f)]%

This way you'll always know what branch you're on and if you have any uncommited
changes without even typing a command!

This status function will not show any new, untracked files. There are other
git prompts out there. One comes with git itself:

    /usr/lib/git-core/git-sh-prompt

Just search for git prompt to get even more sophisticated ones.

Some of these will add colors to your prompt. I know this can lead to problems
if you are using bash. If you are seeing these problems, don't give up on
the git prompt, but find one without colors, like the one that's included here.

## A tiny status

Although with a git prompt you always know your status, you often should
check the details of the status before comitting something. However, `git status`
can be quite verbose:

```
% git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

    modified:   README

Untracked files:
  (use "git add <file>..." to include in what will be committed)

    newfile

no changes added to commit (use "git add" and/or "git commit -a")
```

These hints can be helpful when you're unsure what to do, but in most cases
you probably only need a very compact info:

```
% git status -sb
# or git status --short --branch
## master
 M README
?? newfile
```

That's usually the only information you need, and it will not fill half of your
terminal.

But that's a lot to type! Make it an alias.

## Aliases

It's easy to create aliases in git, and I can't live without them anymore.
To make `git st` an alias for `git status -sb`, put this in your `~/.gitconfig`:

    [alias]
      st = status -sb

Let's add some very basic aliases you'll probably want to use:

    [alias]
      st = status --short --branch # -sb
      # sometimes you want to see ignored files as well
      sti = status --short --branch --ignored
      ci = commit
      co = checkout
      di = diff
      br = branch
      rv = remote -v

I will use those aliases throughout this article

You might also want to create shell aliases for very common commands:

    alias gst="git st"
    alias gd="git di"

Another advantage of aliases is that you can always look them up, for example
on a different machine where you don't have your gitconfig, you can look
at your local gitconfig to remember a command and its switches.
Throughout this article I will introduce some more aliases.

## Switching between branches

Sometimes you have to switch between two branches and switch back. You probably
know that

    % cd -

gets you back to the previous directory. Did you know you can also get back
to the previously checked out branch with that trick?

    % git co -

## Check before you commit

So, you made some changes, you used `git add` to stage your changes, and now
you want to commit and think about a good commit message.

If you use

    % git ci

Your editor will show you the modified files, so you can do a last check:

```

# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# On branch master
# Changes to be committed:
#▸  modified:   README
#
# Untracked files:
#▸  newfile
#
```

If you use

    % git ci -v

instead, you will additionally see the diff in the editor. So while typing
your commit message, you have the full diff available in case you need to
check something.

I made this an alias because I became tired of adding `-v`:

    civ = commit -v

## A more informative stash list

If you have added something to the stash, you will see something like this:

    % git stash list
    stash@{0}: WIP on master: ea25383 Initial commit

The commit it shows you is the commit from where you put your changes onto
the stash. Not very informative.

You can use

    % git stash save "some informative message"
    Saved working directory and index state On master: some informative message
    % git stash list
    stash@{0}: On master: some informative message

But you can get also get information on the date of this stash. Create this
alias:

    stashed = "stash list --pretty=format:'%gd: %Cred%h%Creset %Cgreen[%ar]%Creset %s'"

Then you will see:

    % git stashed
    stash@{0}: 4439cfa [2 minutes ago] On master: some informative message

## git --word-diff

Sometimes a word diff will be more helpful. Here's a default diff:

    % git di
    -Sometimes you have two switch between two branches
    +Sometimes you have to switch between two branches

Create an alias to show a word diff:

    diffw = "diff --word-diff=color"

    % git diffw
    Sometimes you have [-two-]{+to+} switch between two branches

## Tab Completion

git has wonderful tab completion. The one for zsh is a bit more advanced,
but the one for bash is also very helpful.

    % show all commands
    % git <TAB>

Let's say Benny wants to checkout Joon's `feature1` branch. Since there
is only one branch starting with `fe` that's easy:

    % git co fe<TAB>
    % git co feature1

How do you configure color?

    % git config col<TAB>
    % git config color.<TAB>
    % git config color.u<TAB>
    % git config color.ui <TAB>
      always   auto     never
    % git config color.ui al<TAB>
    % git config color.ui always

You have made changes in several files and want to add some? git completion
will only offer you the changed files:

    % git add <TAB>

## Partial commits

Commit early, commit often, make small commits.

Let's say two developers Benny and Joon are working on a little tool that
calculates factorials. Benny wrote a module and a command line script that
takes one number as a command line argument:

    % perl bin/factorial.pl 5
    factorial(5) = 120

Now Joon wants to make this interactive and let the user enter numbers until
they enter `q` for quit. She creates a feature branch `feature1`.

When playing around, she finds out, that there is no check for negative
numbers, so it will result in an endless loop (or actually recursion).

She fixes it, and now the diff includes her feature changes and the fix.
Her feature is not finished yet, but the fix should be put into master as
soon as possible. For that, she plans to create two commits.

Luckily, git has a feature that let's you add partial patches to staging. It
will split the whole diff into several chunks and ask you if you want to add
this chunk (`y`) or not (`n`).  Sometimes the chunk is too big, and you can ask
git to split it even further (`s`). If this is still too big, you can choose to
edit it manually. We're not covering that here, but if you choose to do that,
git will open an editor with instructions how to edit the diff.

Let's see what Joon does:

```
% git add --patch lib/Module/Name.pm
diff --git a/lib/Module/Name.pm b/lib/Module/Name.pm
index 3d335ae..f8f1b4b 100644
--- a/lib/Module/Name.pm
+++ b/lib/Module/Name.pm
@@ -1,12 +1,16 @@
 package Module::Name;
 use strict;
 use warnings;
+use 5.010;

 use base 'Exporter';
-our @EXPORT_OK = qw/ factorial /;
+our @EXPORT_OK = qw/ factorial interactive /;

 sub factorial {
     my ($n) = @_;
+    if ($n < 0) {
+        die "Only positive numbers";
+    }
     if ($n == 0) {
         return 1;
     }
Stage this hunk [y,n,q,a,d,j,J,g,/,s,e,?]?
```
This chunk is too big, we only want the check for `< 0`, so we type `s`:
```
Stage this hunk [y,n,q,a,d,j,J,g,/,s,e,?]? s
Split into 3 hunks.
@@ -1,5 +1,6 @@
 package Module::Name;
 use strict;
 use warnings;
+use 5.010;
 
 use base 'Exporter';
Stage this hunk [y,n,q,a,d,j,J,g,/,e,?]?
```
No, we don't want that one.
```
Stage this hunk [y,n,q,a,d,j,J,g,/,e,?]? n
@@ -4,6 +5,6 @@
 
 use base 'Exporter';
-our @EXPORT_OK = qw/ factorial /;
+our @EXPORT_OK = qw/ factorial interactive /;
 
 sub factorial {
     my ($n) = @_;
Stage this hunk [y,n,q,a,d,K,j,J,g,/,e,?]?
```
Also not this one.
```
Stage this hunk [y,n,q,a,d,K,j,J,g,/,e,?]? n
@@ -7,6 +8,9 @@
 
 sub factorial {
     my ($n) = @_;
+    if ($n < 0) {
+        die "Only positive numbers";
+    }
     if ($n == 0) {
         return 1;
     }
Stage this hunk [y,n,q,a,d,K,j,J,g,/,e,?]?
```
Yes, this is the one we need.
```
Stage this hunk [y,n,q,a,d,K,j,J,g,/,e,?]? y
@@ -16,4 +20,29 @@ sub factorial {
     return $n * factorial( $n -1 );
 }
 
+sub interactive {
+    while(_prompt_number()) {
+    }
+
+}
+
+sub _prompt_number {
+    print "Enter number: ";
+    chomp(my $number = <STDIN>);
+    if ($number eq 'q') {
+        return 0;
+    }
+    if ($number != int($number)) {
+        say "Only numbers allowed";
+        return 1;
+    }
+    if ($number < 0) {
+        say "Only positive numbers allowed";
+        return 1;
+    }
+    my $fact = factorial($number);
+    say sprintf "factorial(%d) = %d", $number, $fact;
+    return 1;
+}
+
 1;
Stage this hunk [y,n,q,a,d,K,g,/,e,?]?
```
We don't want this one so we type `n` once more and we're done:
```
Stage this hunk [y,n,q,a,d,K,g,/,e,?]? n
%
```

Now Joon checks the status. She'll see that the module has two 'M'. One is for
staged changes, one for unstaged. The left 'M' will be shown in green.

```
% git st
## feature1
 M bin/factorial.pl
MM lib/Module/Name.pm

```

For a final check, she shows the diff for only staged changes:

```
% git di --staged
diff --git a/lib/Module/Name.pm b/lib/Module/Name.pm
index 3d335ae..0895c5a 100644
--- a/lib/Module/Name.pm
+++ b/lib/Module/Name.pm
@@ -7,6 +7,9 @@ our @EXPORT_OK = qw/ factorial /;

 sub factorial {
     my ($n) = @_;
+    if ($n < 0) {
+        die "Only positive numbers";
+    }
     if ($n == 0) {
         return 1;
     }
```

Now it's ready for commit. For brevity, we use `-m` (or `--message`):

```
% git commit -m "Fix endless recursion in factorial()"
[feature1 223d361] Fix endless recursion in factorial()
 1 file changed, 3 insertions(+)
```

If you do this for the first time, it will seem complicated. Play with it. You
probably won't need it often, but when, it comes in handy.

Joon pushes her feature branch and tells Benny about the bugfix. Benny could
now cherry-pick this commit (into a hotfix branch, or into master), or,
since it is the first commit in Joon's branch, he can actually just merge
the commit.


## The History

When people ask me for git help and I look over their shoulder, I ask them to
look at the log. But the default `git log` is rarely what I need. I'm more
interested in showing as many commits as possible, and typically more than
one branch.

Here's an alias that will show you each commit on one line, along with its
branch names, tags, date and author, for the current branch:

    lg = log --pretty=format:"%C(yellow)%h\\ %C(cyan)%ad%Cred%d\\ %Creset%s%Cgreen\\ [%an]" --decorate --date=short --graph

To see what you currently have checkout out watch for `HEAD` in the log output.

When Benny is on his hotfix branch this is what he sees:

```
% git lg
* c7f95b8 2018-07-29 (HEAD -> hotfix1, origin/hotfix1) Fix endless recursion in factorial() [Joon]
* 74acd84 2018-07-29 (origin/master, master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]
```

Joon sees this:
```
% git lg
* f248bf0 2018-07-29 (HEAD -> feature1, origin/feature1) Add interactive mode [Joon]
* 223d361 2018-07-29 Fix endless recursion in factorial() [Joon]
* 74acd84 2018-07-29 (origin/master, origin/HEAD, master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]
```

You can add branch names after the commands to show more branches than the
current one.

I have another alias to show me all branches, and it's limited to 20 commits.
I find this very useful to get a quick overview of the structure of the repo
history:

    l = log --pretty=format:"%C(yellow)%h\\ %C(cyan)%ad%Cred%d\\ %Creset%s%Cgreen\\ [%an]" --decorate --date=short --graph --branches=* --remotes=* -20

This is what Joon sees:

```
% git l
* c7f95b8 2018-07-29 (origin/hotfix1) Fix endless recursion in factorial() [Joon]
| * f248bf0 2018-07-29 (HEAD -> feature1, origin/feature1) Add interactive mode [Joon]
| * 223d361 2018-07-29 Fix endless recursion in factorial() [Joon]
|/
* 74acd84 2018-07-29 (origin/master, origin/HEAD, master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]
```

Another useful information can be the list of branches. The default `git branch`
is very short. I have this alias:

    brv = "branch -avv"

If Joon calls this, she sees:

```
% git brv
* feature1                f248bf0 [origin/feature1] Add interactive mode
  master                  74acd84 [origin/master] Add FindBin
  remotes/origin/HEAD     -> origin/master
  remotes/origin/feature1 f248bf0 Add interactive mode
  remotes/origin/hotfix1  c7f95b8 Fix endless recursion in factorial()
  remotes/origin/master   74acd84 Add FindBin
```
You see all branches including the remotes, along with the information
which local branches track which remote branches.

### Tools

There are also tools for viewing the log and browsing through them.

#### tig - A text based tool

  ![tig](/git-tips-tricks/img/tig.png)

#### gitk - Graphical viewer with several options and a search function

  ![gitk](/git-tips-tricks/img/gitk.png)

#### gitg - Graphical tool which looks a bit nicer than gitk, but with less tools

  ![gitg](/git-tips-tricks/img/gitg.png)


## History of merges vs. rebase

merge (gitk) | merge (gitg) | rebase (gitk) | rebase (gitg)
------------ | ------------- | --- | ---
![merge (gitk)](/git-tips-tricks/img/merge-hell-gitk.png) | ![merge (gitg)](/git-tips-tricks/img/merge-hell-gitg.png) | ![rebase (gitk)](/git-tips-tricks/img/merge-heaven-gitk.png) | ![rebase (gitg)](/git-tips-tricks/img/merge-heaven-gitg.png)


## Removing a commit from the wrong branch

Benny wants to add tests for the `factorial` function. He adds
`t/10.factorial.t` and commits. Then he realizes that he had still checked out
Joon's `feature1` branch. (Probably because he didn't use a git prompt!)

```
% git lg
* c49e436 2018-07-29 (HEAD -> feature1) Add t/10.factorial.t [Benny]
* f248bf0 2018-07-29 (origin/feature1) Add interactive mode [Joon]
* 223d361 2018-07-29 Fix endless recursion in factorial() [Joon]
* 74acd84 2018-07-29 (origin/master, master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]
```

No problem. Check out a new branch from master, cherry-pick the commit,
and reset the `feature1` branch to where it was before.

Benny creates a new branch `test` from master and picks the commit:

```
% git co master
Switched to branch 'master'
Your branch is up to date with 'origin/master'.

% git co -b test
Switched to a new branch 'test'

% git cherry-pick c49e436
[test 22ac3d0] Add t/10.factorial.t
 Date: Sun Jul 29 21:55:43 2018 +0200
 1 file changed, 13 insertions(+)
 create mode 100644 t/10.factorial.t

% git lg test feature1
* 22ac3d0 2018-07-29 (HEAD -> test) Add t/10.factorial.t [Benny]
| * c49e436 2018-07-29 (feature1) Add t/10.factorial.t [Benny]
| * f248bf0 2018-07-29 (origin/feature1) Add interactive mode [Joon]
| * 223d361 2018-07-29 Fix endless recursion in factorial() [Joon]
|/
* 74acd84 2018-07-29 (origin/master, master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]

% git push -u origin test
Counting objects: 4, done.
 [...]
 * [new branch]      test -> test
Branch 'test' set up to track remote branch 'test' from 'origin'.
```

Now he removes the commit from the `feature1` branch:
```
% git co feature1
Switched to branch 'feature1'
Your branch is ahead of 'origin/feature1' by 1 commit.
  (use "git push" to publish your local commits)

% git lg
* c49e436 2018-07-29 (HEAD -> feature1) Add t/10.factorial.t [Benny]
* f248bf0 2018-07-29 (origin/feature1) Add interactive mode [Joon]
* 223d361 2018-07-29 Fix endless recursion in factorial() [Joon]
* 74acd84 2018-07-29 (origin/master, master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]

% git reset --hard origin/feature1
HEAD is now at f248bf0 Add interactive mode

% git lg
* f248bf0 2018-07-29 (HEAD -> feature1, origin/feature1) Add interactive mode [Joon]
* 223d361 2018-07-29 Fix endless recursion in factorial() [Joon]
* 74acd84 2018-07-29 (origin/master, master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]
```

That's it!

If you ever make a mistake when doing `git reset`, checkout `git reflog` where
you can find previous commits.

## Merge Commits

There are situations when you might want to create a merge commit explicitly,
because otherwise git would automatically do a "fast forward merge".

This happens if the branch you want to merge is based on the current master
(or the branch tou want to merge into).

Benny wants to merge his hotfix branch.

He first calls `git l` to get an overview what his status is:
```
% git l
* 4e17021 2018-08-02 (origin/feature1) Improve error message (natural numbers) [Joon]
* f248bf0 2018-07-29 (feature1) Add interactive mode [Joon]
* 223d361 2018-07-29 Fix endless recursion in factorial() [Joon]
| * 22ac3d0 2018-07-29 (origin/test, test) Add t/10.factorial.t [Benny]
|/
| * c7f95b8 2018-07-29 (origin/hotfix1, hotfix1) Fix endless recursion in factorial() [Joon]
|/
* 74acd84 2018-07-29 (HEAD -> master, origin/master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]
```

Ok, several branches. Let's get a smaller view, showing only the current branch
and the one it is based on (master):

```
% git lg hotfix
* c7f95b8 2018-07-29 (origin/hotfix1, hotfix1) Fix endless recursion in factorial() [Joon]
* 74acd84 2018-07-29 (HEAD -> master, origin/master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]
```

If Benny would merge `hotfix1` into `master` now, he'd get a fast forward merge:

```
% git merge hotfix1
Updating 74acd84..c7f95b8
Fast-forward
 lib/Module/Name.pm | 3 +++
 1 file changed, 3 insertions(+)

% git lg hotfix1
* c7f95b8 2018-07-29 (HEAD -> master, origin/hotfix1, hotfix1) Fix endless recursion in factorial() [Joon]
* 74acd84 2018-07-29 (origin/master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]
```

It can be a nice habit to always merge with merge commits. Then you will have
the branch name in your history, which often contains the issue number.

So Benny wants to undo his merge, simply by resetting HEAD to origin/master:
```
% git reset --hard origin/master
HEAD is now at 74acd84 Add FindBin

% git lg hotfix1
* c7f95b8 2018-07-29 (origin/hotfix1, hotfix1) Fix endless recursion in factorial() [Joon]
* 74acd84 2018-07-29 (HEAD -> master, origin/master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]
```

Now he merges with `--no-ff` which will always create a merge commit:
```
git merge --no-ff hotfix1
# Will prompt you to edit the default commit message: Merge branch 'hotfix1'
Merge made by the 'recursive' strategy.
 lib/Module/Name.pm | 3 +++
 1 file changed, 3 insertions(+)

% git lg
*   7d412d4 2018-08-02 (HEAD -> master) Merge branch 'hotfix1' [Benny]
|\
| * c7f95b8 2018-07-29 (origin/hotfix1, hotfix1) Fix endless recursion in factorial() [Joon]
|/
* 74acd84 2018-07-29 (origin/master) Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]
```

That looks good. Push and cleanup:
```
% git push
Counting objects: 1, done.
[...]
   74acd84..7d412d4  master -> master

% git lg
*   7d412d4 2018-08-02 (HEAD -> master, origin/master) Merge branch 'hotfix1' [Benny]
|\  
| * c7f95b8 2018-07-29 (origin/hotfix1, hotfix1) Fix endless recursion in factorial() [Joon]
|/  
* 74acd84 2018-07-29 Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]

% git br -d hotfix1
Deleted branch hotfix1 (was c7f95b8).

% git push origin :hotfix1 # delete remote branch
[...]
 - [deleted]         hotfix1

```

Remember you can complete git options and branch names with tabs! You will make
less typos.


## We can rewrite history! With `rebase`

What's a rebase, actually?

```
A - B - E - F  (master)
      \
       C - D   (feature1)
```

Commit B is the base of the `feature1` branch. We want to rebase it onto master
(commit F).

It's nothing magical. It's practically the same as if you created a new
branch `feature1-rebase` based on `master` and then cherry-pick all commits
from `feature1`.

```
A - B - E - F (master)
             \
              C1 - D1 (feature1)
```

That way you pretend that you started your branch when commit F was already
done.

If you merge this with a merge commit, you will end up with this:

```
A - B - E - F         G (master)
             \       /
              C1 - D1
```

If you do this for every branch, you will get a clean, almost flat history:
```
A   C       F               K
 \ / \     / \             /
  B   D - E   G - H - I - J
```

So, Joon wants to rebase her `feature1` branch onto master before merging:

```
% git lg master feature1
* 0226221 2018-08-02 (HEAD -> feature1, origin/feature1) Improve error message (natural numbers) [Joon]
* 993c857 2018-07-29 Add interactive mode [Joon]
* dbaa92a 2018-07-29 Fix endless recursion in factorial() [Joon]
| *   7d412d4 2018-08-02 (origin/master, origin/HEAD, master) Merge branch 'hotfix1' [Benny]
| |\
|/ /
| * c7f95b8 2018-07-29 Fix endless recursion in factorial() [Joon]
|/
* 74acd84 2018-07-29 Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]

% git rebase master
First, rewinding head to replay your work on top of it...
Applying: Add interactive mode
Applying: Improve error message (natural numbers)

% git lg master feature1
* 5193eb8 2018-08-02 (HEAD -> feature1) Improve error message (natural numbers) [Joon]
* 13a2e21 2018-07-29 Add interactive mode [Joon]
*   7d412d4 2018-08-02 (origin/master, origin/HEAD, master) Merge branch 'hotfix1' [Benny]
|\
| * c7f95b8 2018-07-29 Fix endless recursion in factorial() [Joon]
|/
* 74acd84 2018-07-29 Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]

```

You can see (hopefully), that the endless recursion fix, which was present in
both branches, was just skipped because git saw that it was the same commit.

If something goes wrong during a rebase, you can always do

    git rebase --abort

If you get a conflict, solve it, then add the files with `git add` and do

    git rebase --continue

until it tells you that it's finished.

If you look at the complete history you will see that `origin/feature1` and
`feature1` hav diverged, which git will also tell you when looking at the
status:

```
% git l
* 5193eb8 2018-08-02 (HEAD -> feature1) Improve error message (natural numbers) [Joon]
* 13a2e21 2018-07-29 Add interactive mode [Joon]
*   7d412d4 2018-08-02 (origin/master, origin/HEAD, master) Merge branch 'hotfix1' [Benny]
|\  
| * c7f95b8 2018-07-29 Fix endless recursion in factorial() [Joon]
|/  
| * 0226221 2018-08-02 (origin/feature1) Improve error message (natural numbers) [Joon]
| * 993c857 2018-07-29 Add interactive mode [Joon]
| * dbaa92a 2018-07-29 Fix endless recursion in factorial() [Joon]
|/  
| * 22ac3d0 2018-07-29 (origin/test) Add t/10.factorial.t [Benny]
|/  
* 74acd84 2018-07-29 Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]

% git st
## feature1...origin/feature1 [ahead 4, behind 3]

% git status
On branch feature1
Your branch and 'origin/feature1' have diverged,
and have 4 and 3 different commits each, respectively.
  (use "git pull" to merge the remote branch into yours)

nothing to commit, working tree clean
```

It might be a good idea, depending on your workflow, to push that rebased branch
to trigger a Jenkins build, for example, to make sure all tests are still
passing. Since your branch has diverged from origin, you have to force push,
normally done with `--force`, but there's a cleaner option `--force-with-lease`.
It will prevent overwriting something that has been pushed in between.
If you have finished a feature and are about to merge to master, there shouldn't
be anyone pushing to this branch anyway, but just always use `--force-with-lease`
to be safe. Make it an alias:

    pushfl = "push --force-with-lease"

```
% git pushfl
Counting objects: 12, done.
 [...]
 + 0226221...5193eb8 feature1 -> feature1 (forced update)

% git l
* 5193eb8 2018-08-02 (HEAD -> feature1, origin/feature1) Improve error message (natural numbers) [Joon]
* 13a2e21 2018-07-29 Add interactive mode [Joon]
*   7d412d4 2018-08-02 (origin/master, origin/HEAD, master) Merge branch 'hotfix1' [Benny]
|\
| * c7f95b8 2018-07-29 Fix endless recursion in factorial() [Joon]
|/
| * 22ac3d0 2018-07-29 (origin/test) Add t/10.factorial.t [Benny]
|/
* 74acd84 2018-07-29 Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]
```

Now you can merge it to master:

```
% git co master
Switched to branch 'master'
Your branch is up to date with 'origin/master'.

% git merge --no-ff feature1
# Merge branch 'feature1'
Merge made by the 'recursive' strategy.
 bin/factorial.pl   |  6 +++---
 lib/Module/Name.pm | 30 ++++++++++++++++++++++++++++--
 2 files changed, 31 insertions(+), 5 deletions(-)

% git l
*   2984f70 2018-08-08 (HEAD -> master) Merge branch 'feature1' [Joon]
|\
| * 5193eb8 2018-08-02 (origin/feature1, feature1) Improve error message (natural numbers) [Joon]
| * 13a2e21 2018-07-29 Add interactive mode [Joon]
|/
*   7d412d4 2018-08-02 (origin/master, origin/HEAD) Merge branch 'hotfix1' [Benny]
|\
| * c7f95b8 2018-07-29 Fix endless recursion in factorial() [Joon]
|/
| * 22ac3d0 2018-07-29 (origin/test) Add t/10.factorial.t [Benny]
|/
* 74acd84 2018-07-29 Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]

% git push
   [...]
   7d412d4..2984f70  master -> master

% git br -d feature1
Deleted branch feature1 (was 5193eb8).

% git push origin :feature1
[...]
 - [deleted]         feature1

% git l
*   2984f70 2018-08-08 (HEAD -> master, origin/master, origin/HEAD) Merge branch 'feature1' [Joon]
|\
| * 5193eb8 2018-08-02 Improve error message (natural numbers) [Joon]
| * 13a2e21 2018-07-29 Add interactive mode [Joon]
|/
*   7d412d4 2018-08-02 Merge branch 'hotfix1' [Benny]
|\
| * c7f95b8 2018-07-29 Fix endless recursion in factorial() [Joon]
|/
| * 22ac3d0 2018-07-29 (origin/test) Add t/10.factorial.t [Benny]
|/
* 74acd84 2018-07-29 Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]

```

Benny now does the same with the test branch:

```
% git pull
   [...]
   7d412d4..2984f70  master     -> origin/master
Updating 7d412d4..2984f70
Fast-forward
 bin/factorial.pl   |  6 +++---
 lib/Module/Name.pm | 30 ++++++++++++++++++++++++++++--
 2 files changed, 31 insertions(+), 5 deletions(-)

% git co test
Switched to branch 'test'
Your branch is up to date with 'origin/test'.

% git l
*   2984f70 2018-08-08 (origin/master, master) Merge branch 'feature1' [Joon]
|\
| * 5193eb8 2018-08-02 Improve error message (natural numbers) [Joon]
| * 13a2e21 2018-07-29 Add interactive mode [Joon]
|/
*   7d412d4 2018-08-02 Merge branch 'hotfix1' [Benny]
|\
| * c7f95b8 2018-07-29 Fix endless recursion in factorial() [Joon]
|/
| * 22ac3d0 2018-07-29 (HEAD -> test, origin/test) Add t/10.factorial.t [Benny]
|/
* 74acd84 2018-07-29 Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]

% git rebase master
First, rewinding head to replay your work on top of it...
Applying: Add t/10.factorial.t

% git pushfl
Counting objects: 4, done.
Delta compression using up to 4 threads.
Compressing objects: 100% (3/3), done.
Writing objects: 100% (4/4), 472 bytes | 472.00 KiB/s, done.
Total 4 (delta 1), reused 0 (delta 0)
To /path/to/project.git/
 + 22ac3d0...518a44d test -> test (forced update)

% git l
* 518a44d 2018-07-29 (HEAD -> test, origin/test) Add t/10.factorial.t [Benny]
*   2984f70 2018-08-08 (origin/master, master) Merge branch 'feature1' [Joon]
|\
| * 5193eb8 2018-08-02 Improve error message (natural numbers) [Joon]
| * 13a2e21 2018-07-29 Add interactive mode [Joon]
|/
*   7d412d4 2018-08-02 Merge branch 'hotfix1' [Benny]
|\
| * c7f95b8 2018-07-29 Fix endless recursion in factorial() [Joon]
|/
* 74acd84 2018-07-29 Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]

% git co master
Switched to branch 'master'
Your branch is up to date with 'origin/master'.

% git merge --no-ff test
# Merge branch 'test
Merge made by the 'recursive' strategy.
 t/10.factorial.t | 13 +++++++++++++
 1 file changed, 13 insertions(+)
 create mode 100644 t/10.factorial.t

% git push
   [...]
   2984f70..5bb1a8d  master -> master

% git br -d test
Deleted branch test (was 518a44d).

% git push origin :test
[...]
 - [deleted]         test

% git l
*   5bb1a8d 2018-08-08 (HEAD -> master, origin/master) Merge branch 'test' [Benny]
|\
| * 518a44d 2018-07-29 Add t/10.factorial.t [Benny]
|/
*   2984f70 2018-08-08 Merge branch 'feature1' [Joon]
|\
| * 5193eb8 2018-08-02 Improve error message (natural numbers) [Joon]
| * 13a2e21 2018-07-29 Add interactive mode [Joon]
|/
*   7d412d4 2018-08-02 Merge branch 'hotfix1' [Benny]
|\
| * c7f95b8 2018-07-29 Fix endless recursion in factorial() [Joon]
|/
* 74acd84 2018-07-29 Add FindBin [Benny]
* f4a34bf 2018-07-29 Add Module::Name; factorial() [Benny]
* 25b49d0 2018-07-29 Initial commit [Benny]

```

Now that's a pretty clean history.


## Interactive rebase

Joon adds a calculator script to the project. She's done some commits and
hasn't pushed anything yet.

The first commit adds the basic calculator:

```
commit 9bbaa8cbc1813031ec8be71788404fed5a91ff6f
Author: Joon <joon@example.org>
Date:   Fri Aug 10 14:24:15 2018 +0200

    Add calculator script

diff --git a/bin/calc.pl b/bin/calc.pl
new file mode 100644
index 0000000..fce6d5f
--- /dev/null
+++ b/bin/calc.pl
@@ -0,0 +1,11 @@
+#!/usr/bin/env perl
+use strict;
+use warnings;
+use 5.010;
+
+use FindBin '$Bin';
+use lib "$Bin/../lib";
+
+use Module::Name qw/ calculator /;
+
+calculator();
diff --git a/lib/Module/Name.pm b/lib/Module/Name.pm
index 0b657eb..481e945 100644
--- a/lib/Module/Name.pm
+++ b/lib/Module/Name.pm
@@ -3,8 +3,12 @@ use strict;
 use warnings;
 use 5.010;

+use Regexp::Common;
+
 use base 'Exporter';
-our @EXPORT_OK = qw/ factorial interactive /;
+our @EXPORT_OK = qw/ factorial interactive calculator /;
+
+my $RE_EXPR = qr{[+-/*]};

 sub factorial {
     my ($n) = @_;
@@ -45,4 +49,39 @@ sub _prompt_number {
     return 1;
 }

+sub calculator {
+    while (_prompt_expression()) {
+    }
+}
+
+sub _prompt_expression {
+    print "Enter expression: ";
+    chomp(my $expr = <STDIN>);
+    if ($expr eq 'q') {
+        return 0;
+    }
+    if ($expr =~ m#^($RE{num}{real}) +($RE_EXPR) +($RE{num}{real})\z#) {
+        my $result = _calculate($1, $2, $3);
+        say "$expr = $result";
+    }
+    else {
+        say "Invalid expression";
+    }
+    return 1;
+
+}
+
+my %operations = (
+    "+" => sub { $_[0] + $_[1] },
+    "-" => sub { $_[0] - $_[1] },
+    "*" => sub { $_[0] * $_[1] },
+    "/" => sub { $_[0] / $_[1] },
+);
+
+sub _calculate {
+    my ($x, $op, $y) = @_;
+    my $code = $operations{ $op } or die "Invalid operation: $op";
+    return $code->($x, $y);
+}
+
 1;

```

Then she adds a little help operation:

```
commit ea992fb214655d9932c375100be2a705b32f203a
Author: Joon <joon@example.org>
Date:   Fri Aug 10 14:39:30 2018 +0200

    Add help

diff --git a/lib/Module/Name.pm b/lib/Module/Name.pm
index 481e945..5532f2a 100644
--- a/lib/Module/Name.pm
+++ b/lib/Module/Name.pm
@@ -50,16 +50,27 @@ sub _prompt_number {
 }

 sub calculator {
+    help_calculator();
     while (_prompt_expression()) {
     }
 }

+sub help_calculator {
+    say "Entr h or ? for help, q for quit";
+    say "<number> <operator> <number>";
+    say "operator = + - / *";
+}
+
 sub _prompt_expression {
     print "Enter expression: ";
     chomp(my $expr = <STDIN>);
     if ($expr eq 'q') {
         return 0;
     }
+    if ($expr eq '?' or $expr eq 'h') {
+        help_calculator();
+        return 1;
+    }
     if ($expr =~ m#^($RE{num}{real}) +($RE_EXPR) +($RE{num}{real})\z#) {
         my $result = _calculate($1, $2, $3);
         say "$expr = $result";

```

Then she fixes a typo in the help text:

```
commit 22c8f2d50410767039e12517ceb4450852fdfcf2
Author: Joon <joon@example.org>
Date:   Sat Aug 11 21:03:23 2018 +0200

    Fix typo

diff --git a/lib/Module/Name.pm b/lib/Module/Name.pm
index 5532f2a..d704259 100644
--- a/lib/Module/Name.pm
+++ b/lib/Module/Name.pm
@@ -56,7 +56,7 @@ sub calculator {
 }
 
 sub help_calculator {
-    say "Entr h or ? for help, q for quit";
+    say "Enter h or ? for help, q for quit";
     say "<number> <operator> <number>";
     say "operator = + - / *";
 }

```

Then she finds a bug in the regex character class. A `-` must  be the first
or last thing in a character class:

```
commit f7f01612ca071d64699b81c97de80573eede7254
Author: Joon <joon@example.org>
Date:   Sat Aug 11 21:04:41 2018 +0200

    Fix regex character class

diff --git a/lib/Module/Name.pm b/lib/Module/Name.pm
index d704259..bb04265 100644
--- a/lib/Module/Name.pm
+++ b/lib/Module/Name.pm
@@ -8,7 +8,8 @@ use Regexp::Common;
 use base 'Exporter';
 our @EXPORT_OK = qw/ factorial interactive calculator /;
 
-my $RE_EXPR = qr{[+-/*]};
+# '-' must be first or last in character classes
+my $RE_EXPR = qr{[-+/*]};
 
 sub factorial {
     my ($n) = @_;

```

Her last recent change is adding a modulo operation:
```
commit c22e668aa572892e08242ccd4cd0f0366f575811 (HEAD -> calculator)
Author: Joon <joon@example.org>
Date:   Fri Aug 10 21:33:23 2018 +0200

    Add modulo operation

diff --git a/lib/Module/Name.pm b/lib/Module/Name.pm
index bb04265..1b4bcec 100644
--- a/lib/Module/Name.pm
+++ b/lib/Module/Name.pm
@@ -9,7 +9,7 @@ use base 'Exporter';
 our @EXPORT_OK = qw/ factorial interactive calculator /;
 
 # '-' must be first or last in character classes
-my $RE_EXPR = qr{[-+/*]};
+my $RE_EXPR = qr{[-+/*%]};
 
 sub factorial {
     my ($n) = @_;
@@ -59,7 +59,7 @@ sub calculator {
 sub help_calculator {
     say "Enter h or ? for help, q for quit";
     say "<number> <operator> <number>";
-    say "operator = + - / *";
+    say "operator = + - / * %";
 }
 
 sub _prompt_expression {
@@ -88,6 +88,7 @@ my %operations = (
     "-" => sub { $_[0] - $_[1] },
     "*" => sub { $_[0] * $_[1] },
     "/" => sub { $_[0] / $_[1] },
+    "%" => sub { $_[0] % $_[1] },
 );
 
 sub _calculate {

```

The short log looks like this:

```
% git lg master calculator -7
* c22e668 2018-08-10 (HEAD -> calculator) Add modulo operation [Joon]
* f7f0161 2018-08-11 Fix regex character class [Joon]
* 22c8f2d 2018-08-11 Fix typo [Joon]
* ea992fb 2018-08-10 Add help [Joon]
* 9bbaa8c 2018-08-10 Add calculator script [Joon]
*   5bb1a8d 2018-08-08 (origin/master, origin/HEAD, master) Merge branch 'test' [Benny]
|\  
| * 518a44d 2018-07-29 Add t/10.factorial.t [Benny]
|/  
```

Now she wants to squash several commits. The `Add help` and `Fix typo`
should be squashed to one single commit.

She does this step by step for demonstration reasons, although she could do
all her history changes in one step.

Her branch is based on master, so she types the following:

    % git rebase -i master # -i == --interactive

Now an editor opens with the list of commits (oldest to newest) and
instructions:

```
  1 pick 9bbaa8c Add calculator script
  2 pick ea992fb Add help
  3 pick 22c8f2d Fix typo
  4 pick f7f0161 Fix regex character class
  5 pick c22e668 Add modulo operation
  6
  7 # Rebase 5bb1a8d..c22e668 onto 5bb1a8d (5 commands)
  8 #
  9 # Commands:
 10 # p, pick = use commit
 11 # r, reword = use commit, but edit the commit message
 12 # e, edit = use commit, but stop for amending
 13 # s, squash = use commit, but meld into previous commit
 14 # f, fixup = like "squash", but discard this commit's log message
 15 # x, exec = run command (the rest of the line) using shell
 16 # d, drop = remove commit
 17 #
 18 # These lines can be re-ordered; they are executed from top to bottom.
 19 #
 20 # If you remove a line here THAT COMMIT WILL BE LOST.
 21 #
 22 # However, if you remove everything, the rebase will be aborted.
 23 #
 24 # Note that empty commits are commented out
```

She wants to squash `ea992fb` (line 2) and `22c8f2d` (line 3) together:

```
  1 pick 9bbaa8c Add calculator script
  2 pick ea992fb Add help
  3 squash 22c8f2d Fix typo
  4 pick f7f0161 Fix regex character class
  5 pick c22e668 Add modulo operation
```

She saves and closes the file, and another editor opens:

```
  1 # This is a combination of 2 commits.
  2 # This is the 1st commit message:
  3
  4 Add help
  5
  6 # This is the commit message #2:
  7
  8 Fix typo
...
```

She deletes line 8 and saves:

```
[detached HEAD b133977] Add help
 Date: Fri Aug 10 14:39:30 2018 +0200
 1 file changed, 11 insertions(+)
Successfully rebased and updated refs/heads/calculator.
```

Now lets look at the log:
```
% git lg master calculator -6
* 05845b3 2018-08-10 (HEAD -> calculator) Add modulo operation [Joon]
* 507aa5b 2018-08-11 Fix regex character class [Joon]
* b133977 2018-08-10 Add help [Joon]
* 9bbaa8c 2018-08-10 Add calculator script [Joon]
*   5bb1a8d 2018-08-08 (origin/master, origin/HEAD, master) Merge branch 'test' [Benny]
|\
| * 518a44d 2018-07-29 Add t/10.factorial.t [Benny]
|/
```

The `Fix typo` commit is gone.

Now she wants to squash commit `507aa5b Fix regex character class` to
`9bbaa8c Add calculator script`.

Some might argue that fixing a bug should stay in its own commit, with
the appropriate commit message, for future reference. However, your git
history is not your documentation. If you think it's worth mentioning
that `-` is special in character classes, how about a comment in the code?
That's what Joon did already.


```
% git rebase -i master
  1 pick 9bbaa8c Add calculator script
  2 pick b133977 Add help
  3 pick 507aa5b Fix regex character class <- move up
  4 pick 05845b3 Add modulo operation

# edit:
  1 pick 9bbaa8c Add calculator script
  2 squash 507aa5b Fix regex character class
  3 pick b133977 Add help
  4 pick 05845b3 Add modulo operation
# save

  1 # This is a combination of 2 commits.
  2 # This is the 1st commit message:
  3
  4 Add calculator script
  5
  6 # This is the commit message #2:
  7
  8 Fix regex character class
  9
 10 '-' has to be first or last
```
She deletes line 8-10 and saves:
```
[detached HEAD 21b9fad] Add calculator script
 Date: Fri Aug 10 14:24:15 2018 +0200
 2 files changed, 52 insertions(+), 1 deletion(-)
 create mode 100644 bin/calc.pl
Successfully rebased and updated refs/heads/calculator.

% git lg master calculator -5
* de71817 2018-08-10 (HEAD -> calculator) Add modulo operation [Joon]
* b520f0f 2018-08-10 Add help [Joon]
* 21b9fad 2018-08-10 Add calculator script [Joon]
*   5bb1a8d 2018-08-08 (origin/master, origin/HEAD, master) Merge branch 'test' [Benny]
|\  
| * 518a44d 2018-07-29 Add t/10.factorial.t [Benny]
|/  
```

She could further squash the commits or leave it like that. Now that history is
already easier to review than a history with fixing typos and bugs.

Note that instead of `squash` you can use `fixup`. In that case git will
throw away the commit message. I tend to use `squash` to make sure I don't
lose any important messages.

I'm rebasing so frequently I have an alias for it:

    rbi = rebase -i

So that I can type:

    % git rbi master

Joon pushed her branch:

```
% git push -u origin calculator
 [...]
 * [new branch]      calculator -> calculator
Branch 'calculator' set up to track remote branch 'calculator' from 'origin'.

% git lg master calculator -5
* de71817 2018-08-10 (HEAD -> calculator, origin/calculator) Add modulo operation [Joon]
* b520f0f 2018-08-10 Add help [Joon]
* 21b9fad 2018-08-10 Add calculator script [Joon]
*   5bb1a8d 2018-08-08 (origin/master, origin/HEAD, master) Merge branch 'test' [Benny]
|\
| * 518a44d 2018-07-29 Add t/10.factorial.t [Benny]
|/
```

## Avoiding automatic merge commits for `git pull`

The `pull` commmand is actually a combination of two commands:

    git fetch
    git merge

If Benny and Joon are working on the same branch it can happen that Joon wants
to push a commit while Benny pushed a commit in the meantime. If Joon pulls,
git will by default perform a merge.

Joon adds a power operation to the calcuator:

```
% gd
diff --git a/lib/Module/Name.pm b/lib/Module/Name.pm
index 1b4bcec..9a57be6 100644
--- a/lib/Module/Name.pm
+++ b/lib/Module/Name.pm
@@ -9,7 +9,7 @@ use base 'Exporter';
 our @EXPORT_OK = qw/ factorial interactive calculator /;
 
 # '-' must be first or last in character classes
-my $RE_EXPR = qr{[-+/*%]};
+my $RE_EXPR = qr{(?:[-+/*%]|\*\*)};
 
 sub factorial {
     my ($n) = @_;
@@ -59,7 +59,7 @@ sub calculator {
 sub help_calculator {
     say "Enter h or ? for help, q for quit";
     say "<number> <operator> <number>";
-    say "operator = + - / * %";
+    say "operator = + - / * % **";
 }
 
 sub _prompt_expression {
@@ -89,6 +89,7 @@ my %operations = (
     "*" => sub { $_[0] * $_[1] },
     "/" => sub { $_[0] / $_[1] },
     "%" => sub { $_[0] % $_[1] },
+    "**" => sub { $_[0] ** $_[1] },
 );
 
 sub _calculate {

% git add lib/Module/Name.pm

% git civ

% git lg master calculator -5
* 4e03142 2018-08-12 (HEAD -> calculator) Add power operation [Joon]
* de71817 2018-08-10 (origin/calculator) Add modulo operation [Joon]
* b520f0f 2018-08-10 Add help [Joon]
* 21b9fad 2018-08-10 Add calculator script [Joon]
*   5bb1a8d 2018-08-08 (origin/master, origin/HEAD, master) Merge branch 'test' [Benny]
|\
```


Benny adds a little example function to the calculator:
```
% gd
diff --git a/lib/Module/Name.pm b/lib/Module/Name.pm
index 1b4bcec..130c834 100644
--- a/lib/Module/Name.pm
+++ b/lib/Module/Name.pm
@@ -57,11 +57,19 @@ sub calculator {
 }

 sub help_calculator {
-    say "Enter h or ? for help, q for quit";
+    say "Enter h or ? for help, e for example, q for quit";
     say "<number> <operator> <number>";
     say "operator = + - / * %";
 }

+sub example_calculator {
+    say "Examples:";
+    say "23 ** 3";
+    say "9 ** 0.5";
+    say "43 - 1";
+    say "1 / 0.318309881481454";
+}
+
 sub _prompt_expression {
     print "Enter expression: ";
     chomp(my $expr = <STDIN>);
@@ -72,6 +80,10 @@ sub _prompt_expression {
         help_calculator();
         return 1;
     }
+    if ($expr eq 'e') {
+        example_calculator();
+        return 1;
+    }
     if ($expr =~ m#^($RE{num}{real}) +($RE_EXPR) +($RE{num}{real})\z#) {
         my $result = _calculate($1, $2, $3);
         say "$expr = $result";

% git add lib/Module/Name.pm

% git civ
[calculator d5fcbdf] Add examples to calculator
 1 file changed, 13 insertions(+), 1 deletion(-)

% git l -3
* d5fcbdf 2018-08-12 (HEAD -> calculator) Add examples to calculator [Benny]
* de71817 2018-08-10 (origin/calculator) Add modulo operation [Joon]
* b520f0f 2018-08-10 Add help [Joon]

% git push
   [...]
   de71817..d5fcbdf  calculator -> calculator

```

Now Joon wants to push her commit with the power operator:
```
% git push
To /path/to/project.git/
 ! [rejected]        calculator -> calculator (fetch first)
error: failed to push some refs to '/path/to/project.git/'
hint: Updates were rejected because the remote contains work that you do
hint: not have locally. This is usually caused by another repository pushing
hint: to the same ref. You may want to first integrate the remote changes
hint: (e.g., 'git pull ...') before pushing again.
hint: See the 'Note about fast-forwards' in 'git push --help' for details.
```

She can't because Benny pushed in the meantime.
If she does a pull now, git will merge:

```
% git pull
# editor opens:
Merge branch 'calculator' of /path/to/project into calculator
# save
remote: Counting objects: 5, done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 5 (delta 1), reused 0 (delta 0)
Unpacking objects: 100% (5/5), done.
From /path/to/project
   de71817..d5fcbdf  calculator -> origin/calculator
Auto-merging lib/Module/Name.pm
Merge made by the 'recursive' strategy.
 lib/Module/Name.pm | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

% git lg calculator -5
*   7208fa6 2018-08-12 (HEAD -> calculator) Merge branch 'calculator' of /path/to/project into calculator [Joon]
|\  
| * d5fcbdf 2018-08-12 (origin/calculator) Add examples to calculator [Benny]
* | 4e03142 2018-08-12 Add power operation [Joon]
|/  
* de71817 2018-08-10 Add modulo operation [Joon]
* b520f0f 2018-08-10 Add help [Joon]
```

So the remote branch was merged into the local `calculator` branch.

If she pushes this and Benny does a simple fetch, he will see this:
```
% git fetch
remote: Counting objects: 10, done.
remote: Compressing objects: 100% (6/6), done.
remote: Total 10 (delta 2), reused 0 (delta 0)
Unpacking objects: 100% (10/10), done.
From /path/to/project/project
   d5fcbdf..7208fa6  calculator -> origin/calculator

% git l -5
*   7208fa6 2018-08-12 (origin/calculator) Merge branch 'calculator' of /path/to/project into calculator [Joon]
|\
| * d5fcbdf 2018-08-12 (HEAD -> calculator) Add examples to calculator [Benny]
* | 4e03142 2018-08-12 Add power operation [Joon]
|/
* de71817 2018-08-10 Add modulo operation [Joon]
* b520f0f 2018-08-10 Add help [Joon]
```

So Joon's commit was automatically put before his.

Every merge commit makes the history a bit more complicated, and such commits
as shown here can easily be avoided.

Instead of doing a normal pull, you can do:

    % git pull --ff-only

I have an alias for that:

    pullff = pull --ff-only

Then git will fetch and only merge if it can be done with a fast forward merge.

Alternatively you can set this as the default behaviour:

    % git config pull.ff true # accept fast-forwards only

Another possibility is to let git rebase automatically:

    % git config pull.rebase true
    # or
    % git pull --rebase

Personally I'm not a fan of letting git decide this automatically for
me, though.

Joon does a `pullff`:

```
% git pullff
From /path/to/project
 * [new branch]      calculator -> origin/calculator
fatal: Not possible to fast-forward, aborting.

% git l -5
* d5fcbdf 2018-08-12 (origin/calculator) Add examples to calculator [Benny]
| * 4e03142 2018-08-12 (HEAD -> calculator) Add power operation [Joon]
|/
* de71817 2018-08-10 Add modulo operation [Joon]
* b520f0f 2018-08-10 Add help [Joon]
* 21b9fad 2018-08-10 Add calculator script [Joon]

```

So the `fetch` was executed, but not the merge, because it wouldn't be a fast
forward merge.

Now Joon can look at the commit and decide what to do.

She does a rebase:
```
% git rebase origin/calculator
First, rewinding head to replay your work on top of it...
Applying: Add power operation
Using index info to reconstruct a base tree...
M	lib/Module/Name.pm
Falling back to patching base and 3-way merge...
Auto-merging lib/Module/Name.pm

% git l -5
* df3ed95 2018-08-12 (HEAD -> calculator) Add power operation [Joon]
* d5fcbdf 2018-08-12 (origin/calculator) Add examples to calculator [Benny]
* de71817 2018-08-10 Add modulo operation [Joon]
* b520f0f 2018-08-10 Add help [Joon]
* 21b9fad 2018-08-10 Add calculator script [Joon]

% git push
   [...]
   d5fcbdf..df3ed95  calculator -> calculator

```

With both methods you can of course run into conflicts. Remember you can always
abort a rebase. If you want to undo a successful rebase check the `reflog`
and `git reset --hard id`.




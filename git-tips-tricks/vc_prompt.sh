# bash/zsh:
# source vc_prompt.sh
# PS1='... `vc_prompt` \$'

# thanks to ANDK
_vc_prompt () {
    local GITDIRTY
    local GITPROMPT
    local GITSTATUS
    if [ -e .git -o -e ../.git -o -e ../../.git -o -e ../../../.git ] ; then
        if GITBRANCH="$(git branch -a | grep '^\*' | sed 's,\*[ ]*,,')" ; then
            GITSTATUS="$(git status --porcelain --untracked-files=no)"
            if [ -z $GITSTATUS ] ; then
                GITDIRTY=""
            else
                GITDIRTY="*"
            fi
            GITPROMPT="[$GITBRANCH$GITDIRTY]"
        else
            GITPROMPT="[]"
        fi
    else
        GITPROMPT=""
    fi
    echo $GITPROMPT
}

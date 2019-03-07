# bash/zsh:
# source vc_prompt.sh
# PS1='... `vc-prompt` \$'

vc-prompt () {
    local GITPROMPT
    local GITSTATUS
    GITSTATUS="$(git 2>/dev/null status --porcelain --untracked-files=no)"
    if [ $? != 128 ] ; then
        if GITBRANCH="$(git 2>/dev/null branch -a | grep '^\*' | sed 's,\*[ ]*,,')" ; then
            GITPROMPT="[$GITBRANCH${GITSTATUS:+*}]"
        else
            GITPROMPT="[]"
        fi
    else
        GITPROMPT=""
    fi
    echo "$GITPROMPT"
}

#!/bin/bash

cd ~/tpcig2018/joon/project
git config --local user.email "joon@example.org"
git config --local user.name "Joon"
RPROMPT=""
PS1=$'JOON %{$fg_bold[cyan]%}'%n@%m:%~'`_vc_prompt`'%#$'%{\e[0m%} '

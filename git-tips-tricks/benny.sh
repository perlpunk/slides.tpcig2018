#!/bin/bash

cd ~/tpcig2018/benny/project
git config --local user.email "benny@example.org"
git config --local user.name "Benny"
RPROMPT=""
PS1=$'BENNY %{$fg_bold[red]%}'%n@%m:%~'`_vc_prompt`'%#$'%{\e[0m%} '

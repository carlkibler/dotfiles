# At this point, pip.conf has been copied into the
# home folder (~/.pip/pip.conf) but it needs to be
# modified with the actual home folder of our user, 
# so do a replacement on the word HOMEDIR and replace
# with value of $HOME, using 'ex' editor.
echo "%s/HOMEDIR/$HOME
w
q
" | ex $HOME/.pip/pip.conf



source ~/.dotfiles/source/50_devel.sh


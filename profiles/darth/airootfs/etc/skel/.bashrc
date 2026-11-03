# Darth Linux interactive shell identity
case $- in
  *i*) ;;
  *) return ;;
esac
PS1='\[\e[1;31m\]DARTH\[\e[0m\] \[\e[1;90m\]\w\[\e[0m\] \$ '

apm install --packages-file Atomfile
apm upgrade --confirm=false
apm list -bi > Atomfile

##
## Set Atom as default text editor
##
defaults write com.apple.LaunchServices LSHandlers -array-add '{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=com.github.atom;}'



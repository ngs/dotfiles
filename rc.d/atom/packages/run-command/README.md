# "Run Command" for Atom

Execute any arbitrary command in [Atom](http://atom.io). Originally derived from Phil Nash's [Ruby Quick Test](https://github.com/philnash/ruby-quick-test).

# Usage
`ctrl-r` to open up this:

!['Run Command' dialog](https://raw.githubusercontent.com/kylewlacy/run-command/master/screenshots/run-command.gif)

Enter a command, `enter` to run it:

![Running `rspec spec`](https://raw.githubusercontent.com/kylewlacy/run-command/master/screenshots/run.gif)

`ctrl-r`, `enter`, and run it again:

![Re-running `rspec spec`](https://raw.githubusercontent.com/kylewlacy/run-command/master/screenshots/re-run.gif)

Put it all together, and you can do this:

![I'm available for freelance work!](https://raw.githubusercontent.com/kylewlacy/run-command/master/screenshots/tdd.gif)

(You can also toggle the command output with `cmd-ctrl-x`, or kill the last command with `cmd-ctrl-alt-x`)

# TODO
- [ ] Show/edit the working directory
- [x] ~~ANSI color codes~~
- [ ] Resizable output
- [ ] Editor variables (`$ATOM_PROJECT` for the current project directory, etc.)

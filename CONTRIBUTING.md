# Contributing

Issues and pull requests are welcome at https://github.com/danielwav1/CindraOS.

Before sending a change:

1. Run `bash tests/run.sh`. Everything that can run on your machine must pass.
2. If you touched `scripts/cindra`, add or adjust a test in `tests/test_cli.sh`.
3. If you added a package, put it in `live/config/package-lists/cindra.list.chroot`
   and run `scripts/check-packages.sh` on a Debian 13 machine.
4. If you changed the build, run `./build.sh --check` and say in the pull request
   whether you did a full build.

Ground rules for the CLI: no fake output, no swallowed errors, destructive actions
ask first, nothing is sent over the network unless the user asked for it.

Please report what you actually tested. "Untested" is a perfectly fine answer.

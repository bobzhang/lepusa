# MoonDesk

MoonDesk is a more involved Lepusa example: a native-backed sprint board with
task creation, priority filters, Backlog/In progress/Done transitions, task
details, progress metrics, activity history, compact mode, deletion, completed
task cleanup, and undo.

The domain model, reducer, generated HTML, derived JSON message codec, command
registry, and macOS launcher are written in MoonBit. The WebView only renders
the HTML and forwards interactions; board state lives in the native MoonBit
process.

From the Lepusa repository root:

```bash
moon -C examples/moondesk check --warn-list +73
moon -C examples/moondesk test . --target native
moon -C examples/moondesk test cmd/main --target native
moon -C examples/moondesk run cmd/main
```

Create an ad-hoc signed macOS app and DMG:

```bash
examples/moondesk/package-macos.sh _build/moondesk-release
```

The standalone `moon.work` includes this module and the local Lepusa checkout.
Remove it to test against the published `vectie/lepusa@0.1.4` dependency.

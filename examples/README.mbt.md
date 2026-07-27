# Lepusa Examples

These examples exercise the three foundation app shapes Lepusa should support:

- `rabbita`: MoonBit-authored UI lowered from `rootHtml` into the default root cell.
- `static`: prebuilt frontend assets served through `Source::packaged`.
- `gateway`: localhost WebView source with sidecar command and readiness metadata.

The `counter` demo builds on the packaged-assets shape with an interactive UI,
capability-scoped `window.lepusa` calls, and the official `store` and `log`
plugins. It can also be opened in a regular browser for a frontend-only preview.

The standalone `calculator` module is the fully MoonBit-authored example. Its
model, update function, view, IPC codec, tests, and macOS launcher live under
`examples/calculator`, with `moon.work` pointing back to this Lepusa checkout.

`moondesk` expands the same architecture into a native-backed sprint board with
dynamic task creation, filters, workflow transitions, metrics, activity, task
details, compact mode, and undo. Its messages use derived `ToJson`/`FromJson`
codecs instead of handwritten wire formats.

```bash
moon run cmd/main --target native -- dev --project examples/rabbita/lepusa.json
moon -C examples/calculator run cmd/main
moon -C examples/moondesk run cmd/main
moon run cmd/main --target native -- verify macos --project examples/counter/lepusa.json
moon run cmd/main --target native -- run macos --launch --project examples/counter/lepusa.json
moon run cmd/main --target native -- bundle-write linux _build/examples/static --project examples/static/lepusa.json
moon run cmd/main --target native -- bundle-write linux _build/examples/gateway --project examples/gateway/lepusa.json
```

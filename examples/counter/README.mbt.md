# Lepusa Counter Demo

This interactive counter demonstrates a packaged frontend, capability-scoped
IPC, and the built-in `store` and `log` plugins. In a Lepusa window, the status
pill reads `Native bridge`; in a regular browser it falls back to
`localStorage` for easy visual preview.

Validate the project without opening a window:

```bash
moon run cmd/main --target native -- verify macos --project examples/counter/lepusa.json
```

Launch it on the current platform (replace `macos` with `linux` or `windows`):

```bash
moon run cmd/main --target native -- run macos --launch --project examples/counter/lepusa.json
```

Probe the same native command path from the CLI:

```bash
moon run cmd/main --target native -- invoke main store.set '{"key":"counter.value","value":"7"}' --project examples/counter/lepusa.json
```

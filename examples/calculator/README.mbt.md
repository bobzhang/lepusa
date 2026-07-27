# MoonBit Calculator

This is a standalone MoonBit module that uses the local Lepusa checkout through
`moon.work`. The calculator state machine, model/update/view UI, IPC message
codec, and native macOS launcher are all written in MoonBit; it does not use a
`lepusa.json` manifest or application JavaScript.

From the Lepusa repository root:

```bash
moon -C examples/calculator check --warn-list +73
moon -C examples/calculator test . --target native
moon -C examples/calculator test cmd/main --target native
moon -C examples/calculator run cmd/main
```

Create an ad-hoc signed macOS app and DMG:

```bash
examples/calculator/package-macos.sh _build/calculator-release
```

The packaging script refuses to overwrite an existing output directory. Remove
or choose a different output path when creating another build.

Or enter the standalone module first:

```bash
cd examples/calculator
moon test . --target native
moon test cmd/main --target native
moon run cmd/main
```

The workspace contains two modules:

- `.` — this calculator (`local/lepusa_calculator`)
- `../..` — the local `vectie/lepusa` checkout

To use a published Lepusa release instead, remove `moon.work`; the dependency in
`moon.mod` is already pinned to `vectie/lepusa@0.1.4`.

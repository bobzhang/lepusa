#!/bin/zsh

set -euo pipefail

demo_root="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
repo_root="$(CDPATH= cd -- "$demo_root/../.." && pwd)"
output_root="${1:-$repo_root/_build/calculator-release}"

if [[ "$output_root" != /* ]]; then
  output_root="$repo_root/$output_root"
fi

if [[ -e "$output_root" ]]; then
  print -u2 "Refusing to overwrite existing output: $output_root"
  exit 2
fi

moon -C "$demo_root" run cmd/main --release --build-only

binary="$demo_root/_build/native/release/build/local/lepusa_calculator/cmd/main/main.exe"
app_dir="$output_root/MoonBit Calculator.app"
contents_dir="$app_dir/Contents"
executable="$contents_dir/MacOS/MoonBitCalculator"
dmg_path="$output_root/MoonBit-Calculator-0.1.0.dmg"
staging="$output_root/.dmg-root"

mkdir -p "$contents_dir/MacOS" "$contents_dir/Resources" "$staging"
install -m 755 "$binary" "$executable"
install -m 644 "$demo_root/packaging/Info.plist" "$contents_dir/Info.plist"
plutil -lint "$contents_dir/Info.plist"
codesign --force --deep --sign - --timestamp=none "$app_dir"
codesign --verify --deep --strict "$app_dir"

ditto "$app_dir" "$staging/MoonBit Calculator.app"
ln -s /Applications "$staging/Applications"
hdiutil create \
  -quiet \
  -volname "MoonBit Calculator" \
  -srcfolder "$staging" \
  -format UDZO \
  "$dmg_path"
hdiutil verify -quiet "$dmg_path"

rm -rf -- "$staging"

print "app: $app_dir"
print "dmg: $dmg_path"

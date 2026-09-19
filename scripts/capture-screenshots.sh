#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
: "${DEVELOPER_DIR:=/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR
SIMULATOR_ID="${1:?Pass the UDID of an iPhone 11 Pro Max simulator (1242 x 2688)}"
OUTPUT=docs/screenshots/iphone-6.5
mkdir -p "$OUTPUT"
xcodebuild -project ios-native/CourtTally.xcodeproj -scheme CourtTally \
  -configuration Debug -sdk iphonesimulator -derivedDataPath build/native \
  CODE_SIGNING_ALLOWED=NO build > /tmp/court-tally-screenshot-build.log 2>&1
if ! xcrun simctl list devices booted | grep -q "$SIMULATOR_ID"; then
  xcrun simctl boot "$SIMULATOR_ID"
fi
xcrun simctl bootstatus "$SIMULATOR_ID" -b
xcrun simctl install "$SIMULATOR_ID" build/native/Build/Products/Debug-iphonesimulator/CourtTally.app
xcrun simctl status_bar "$SIMULATOR_ID" override --time '9:41' --dataNetwork wifi --wifiMode active --wifiBars 3 --batteryState charged --batteryLevel 100
xcrun simctl ui "$SIMULATOR_ID" appearance light
SCENES=(setup pickleball tennis badminton tableTennis history data)
INDEX=1
for SCENE in "${SCENES[@]}"; do
  xcrun simctl terminate "$SIMULATOR_ID" com.infinityball.courttally >/dev/null 2>&1 || true
  xcrun simctl launch "$SIMULATOR_ID" com.infinityball.courttally --screenshot "$SCENE"
  sleep 3
  printf -v NAME '%02d-%s.png' "$INDEX" "$SCENE"
  xcrun simctl io "$SIMULATOR_ID" screenshot "$OUTPUT/$NAME"
  INDEX=$((INDEX + 1))
done
python3 - <<'PY'
import hashlib, pathlib, struct
checksums = []
for path in sorted(pathlib.Path('docs/screenshots/iphone-6.5').glob('*.png')):
    data = path.read_bytes()
    width, height = struct.unpack('>II', data[16:24])
    assert (width, height) == (1242, 2688), f'{path}: wrong dimensions {width} x {height}'
    print(f'{path}: {width} x {height}')
    checksums.append(hashlib.sha256(data).hexdigest() + '  ' + path.name)
pathlib.Path('docs/screenshots/iphone-6.5/SHA256SUMS').write_text('\n'.join(checksums) + '\n')
PY
xcrun simctl status_bar "$SIMULATOR_ID" clear

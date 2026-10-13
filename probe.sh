#!/usr/bin/env bash
set -euo pipefail
ROOT="$PWD"
export HOME="$ROOT/temp/home" TMPDIR="$ROOT/temp/tmp"
export NONINTERACTIVE=true VEGA_SDK_VERSION=0.24.12112 SKIP_VVD_INSTALL=false
export DISPLAY=:99
OUT="$ROOT/temp/evidence"
mkdir -p "$HOME" "$TMPDIR" "$OUT"
exec > >(tee "$OUT/probe.log") 2>&1
trap 'jobs -pr | xargs -r kill' EXIT

date -Is
curl -fsSL --max-time 90 https://sdk-installer.vega.labcollab.net/get_vvm.sh -o "$TMPDIR/get_vvm.sh"
bash "$TMPDIR/get_vvm.sh"
source "$HOME/vega/env"
vega --version
vega project list-templates
vega project generate --template helloWorld --name VegaRuntime --packageId io.github.blucca.vegart --outputDir "$ROOT/temp/app"
cd "$ROOT/temp/app"
cat package.json
vega project update-manifest --os-min 1.2 --os-version 1.2
npm install --no-audit --no-fund
npm run build:app
find build -name '*.vpkg' -print
APP="$(find build -path '*x86_64-release*' -name '*.vpkg' -print -quit)"
test -n "$APP"

Xvfb "$DISPLAY" -screen 0 1600x1000x24 -ac > "$OUT/xvfb.log" 2>&1 &
sleep 2
vega virtual-device start --no-gl-accel --display-res=1280,720 --timeout 300 > "$OUT/device.log" 2>&1
vega device list || true
vega run-app "$APP" io.github.blucca.vegart.main -d VirtualDevice
sleep 5
xdotool search --onlyvisible --name '.*' getwindowname > "$OUT/windows.txt" || true
ffmpeg -y -f x11grab -video_size 1600x1000 -i "$DISPLAY" -frames:v 1 "$OUT/before.png"
ffmpeg -y -f x11grab -video_size 1600x1000 -framerate 15 -i "$DISPLAY" -t 20 -c:v libx264 -preset ultrafast -crf 26 -pix_fmt yuv420p "$OUT/remote.mp4" > "$OUT/recording.log" 2>&1 &
RECORDER=$!
sleep 3
xdotool key Right
sleep 2
xdotool key Down
sleep 2
xdotool key Return
sleep 2
xdotool key Escape
sleep 2
ffmpeg -y -f x11grab -video_size 1600x1000 -i "$DISPLAY" -frames:v 1 "$OUT/after.png"
wait "$RECORDER"
vega virtual-device stop
printf 'Build, launch, keyboard input and recording commands completed.\n'

#!/usr/bin/env bash
# Based on https://github.com/nikitabobko/AeroSpace/issues/510#issuecomment-2439585933

# set -eu -o pipefail
IFS=$'\n\t'
PS4='+\t '

error_handler() { echo "Error: Line ${1} exited with status ${2}"; }
trap 'error_handler ${LINENO} $?' ERR

[[ "${TRACE:-0}" == "1" ]] && set -x


APP_NAME="net.kovidgoyal.kitty"
CURRENT_WORKSPACE=$(aerospace list-workspaces --focused)

get_window_id() {
    aerospace list-windows --all --format "%{window-id}%{right-padding} | %{app-name}/%{window-title}" |
    grep " kitty/scratchpad$" |
    cut -d' ' -f1 |
    head -n1
}

focus_app() {
    local app_window_id
    app_window_id=$(get_window_id)
    aerospace move-node-to-workspace --focus-follows-window --window-id "$app_window_id" "$CURRENT_WORKSPACE"
    # aerospace focus --window-id "$app_window_id"
    # aerospace layout floating
}

move_app_to_scratchpad() {
    local app_window_id
    app_window_id=$(aerospace list-windows --workspace "$CURRENT_WORKSPACE" --format "%{window-id}%{right-padding} | %{app-name}/%{window-title}" |
                    grep " kitty/scratchpad$" |
                    cut -d' ' -f1 |
                    head -n1)
    aerospace move-node-to-workspace NSP --window-id "$app_window_id"
}

main() {
    if ! aerospace list-windows --all --format '%{app-name}/%{window-title}' | grep "^kitty/scratchpad$"; then
        /Applications/kitty.app/Contents/MacOS/kitty -T scratchpad -d ~ &
        # open -n -a "$APP_NAME" --args -T scratchpad -d ~
        sleep 0.5
    elif aerospace list-windows --workspace "$CURRENT_WORKSPACE" --format "%{app-name}/%{window-title}" | grep -q "^kitty/scratchpad$"; then
        move_app_to_scratchpad
    else
        focus_app
    fi
}
main

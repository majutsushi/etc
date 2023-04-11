#!/usr/bin/env bash
# ranger supports enhanced previews.  If the option "use_preview_script"
# is set to True and this file exists, this script will be called and its
# output is displayed in ranger.  ANSI color codes are supported.

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

## If the option `use_preview_script` is set to `true`,
## then this script will be called and its output will be displayed in ranger.
## ANSI color codes are supported.
## STDIN is disabled, so interactive scripts won't work properly

## This script is considered a configuration file and must be updated manually.
## It will be left untouched if you upgrade ranger.

## Because of some automated testing we do on the script #'s for comments need
## to be doubled up. Code that is commented out, because it's an alternative for
## example, gets only one #.

## Meanings of exit codes:
## code | meaning    | action of ranger
## -----+------------+-------------------------------------------
## 0    | success    | Display stdout as preview
## 1    | no preview | Display no preview at all
## 2    | plain text | Display the plain content of the file
## 3    | fix width  | Don't reload when width changes
## 4    | fix height | Don't reload when height changes
## 5    | fix both   | Don't ever reload
## 6    | image      | Display the image `$IMAGE_CACHE_PATH` points to as an image preview
## 7    | image      | Display the file directly as an image

 ## Script arguments
FILE_PATH="${1}"         # Full path of the highlighted file
PV_WIDTH="${2}"          # Width of the preview pane (number of fitting characters)
## shellcheck disable=SC2034 # PV_HEIGHT is provided for convenience and unused
PV_HEIGHT="${3}"         # Height of the preview pane (number of fitting characters)
IMAGE_CACHE_PATH="${4}"  # Full path that should be used to cache image preview
PV_IMAGE_ENABLED="${5}"  # 'True' if image previews are enabled, 'False' otherwise.

FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER="$(printf "%s" "${FILE_EXTENSION}" | tr '[:upper:]' '[:lower:]')"
MIMETYPE="$(file --dereference --brief --mime-type -- "${FILE_PATH}")"

# Image previews, if enabled in ranger.
if [ "$PV_IMAGE_ENABLED" = "True" ]; then
    case "$MIMETYPE" in
        # Image previews for SVG files, disabled by default.
        ###image/svg+xml)
        ###   convert "$FILE_PATH" "$IMAGE_CACHE_PATH" && exit 6 || exit 1;;
        # Image previews for image files. w3mimgdisplay will be called for all
        # image files (unless overriden as above), but might fail for
        # unsupported types.
        image/*)
            if command -v ueberzug >/dev/null && [[ -n "$DISPLAY" ]]; then
                exit 7
            else
                chafa --colors 240 --size "${PV_WIDTH}x${PV_HEIGHT}" "$FILE_PATH"
                exit 4
            fi
            ;;
        application/pdf)
            # pdftocairo adds the extension itself, so we have to remove it
            pdftocairo -jpeg -singlefile "$FILE_PATH" "$IMAGE_CACHE_PATH" \
                && mv "${IMAGE_CACHE_PATH}.jpg" "$IMAGE_CACHE_PATH" \
                && exit 6
            ;;
        # Image preview for video, disabled by default.:
        ###video/*)
        ###    ffmpegthumbnailer -i "$FILE_PATH" -o "$IMAGE_CACHE_PATH" -s 0 && exit 6 || exit 1;;
    esac
fi

# Necessary until ranger supports 24-bit colour
export BAT_THEME=ansi

"$DOTFILES/less/lessfilter" "$FILE_PATH" | head -n 200
EXIT_CODE=$?
# Ignore potential SIGPIPE from trimming the output
if (( EXIT_CODE == 0 )) || (( EXIT_CODE == 141 )); then
    exit 5
fi

exit 1

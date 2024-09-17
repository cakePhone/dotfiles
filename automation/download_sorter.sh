#!/bin/bash

DOWNLOAD_DIR=~/Downloads
PICTURES_DIR=~/Pictures
DOCUMENTS_DIR=~/Documents

PICTURE_EXTENSIONS=(
    "jpg" "jpeg" "png" "gif" "bmp" "tiff" "tif" "webp"
    "svg" "eps" "raw" "cr2" "nef" "orf" "sr2"
    "heic" "heif" "avif"
    "psd" "ai" "indd"
    "ico" "icns"
    "avi" "mp4" "mov" "wmv" "flv" "webm" "mkv" "m4v"
)

DOCUMENT_EXTENSIONS=(
    "txt" "rtf" "doc" "docx" "odt" "pages"
    "pdf" "xps" "oxps"
    "xls" "xlsx" "ods" "numbers"
    "ppt" "pptx" "odp" "key"
    "csv" "tsv"
    "md" "markdown"
    "tex" "bib"
    "epub" "mobi" "azw" "azw3"
    "html" "htm" "xml" "json" "yaml" "yml"
    "log" "ini" "cfg" "conf"

inotifywait -m -e create "$DOWNLOAD_DIR" | while read -r directory action file; do
    file_extension="${file##*.}"
    file_extension=$(echo "$file_extension" | tr '[:upper:]' '[:lower:]')

    if [[ " ${PICTURE_EXTENSIONS[*]} " =~ " $file_extension " ]]; then
        echo "It's a Picture: $file"
        mv "$DOWNLOAD_DIR/$file" "$PICTURES_DIR/"
    elif [[ " ${DOCUMENT_EXTENSIONS[*]} " =~ " $file_extension " ]]; then
        echo "It's a Document: $file"
        mv "$DOWNLOAD_DIR/$file" "$DOCUMENTS_DIR/"
    else
        echo "Unknown file type: $file"
    fi
done

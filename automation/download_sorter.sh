!/bin/bash

DOWNLOAD_DIR=~/Downloads
PICTURES_DIR=~/Pictures
DOCUMENTS_DIR=~/Documents

PICTURE_EXTENSIONS=("png", "jpg", "jpeg", "svg", "avi")
DOCUMENT_EXTENSIONS=("txt", "docx", "md", "xls")

inotifywait -m -e create "$DOWNLOAD_DIR" | while read -r path action file; do
    file_extension=$(basename "$filename" | cut -d. -f2-)
    echo "$extension"

    for extension in "${PICTURE_EXTENSIONS[@]}"; do
        if [["$extension" == "$file_extension"]]; then
            echo "It's a Picture"
        fi
    done

    for extension in "${DOCUMENT_EXTENSIONS[@]}"; do
        if [["$extension" == "$file_extension"]]; then
            echo "It's a Documents"
        fi
    done
done

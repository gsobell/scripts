#!/bin/bash

TARGET_DIR=$HOME/Notes
DOWNLOADS_DIR="$HOME/Downloads"


echo "Please select a .tex file to append to:"
select file in "$TARGET_DIR"/*.tex; do
    if [ -n "$file" ]; then
        echo "You selected: $(basename $file)"
        TARGET_FILE="$file"
        break
    else
        echo "Invalid selection. Please try again."
    fi
done

MOST_RECENT_ZIP=$(find "$DOWNLOADS_DIR" -type f -name '*.zip' -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" ")

if [ -z "$MOST_RECENT_ZIP" ]; then
    echo "No .zip files found in the downloads directory."
    exit 1
fi

TEX_FILES=$(unzip -l "$MOST_RECENT_ZIP" | grep -E '\.tex$' | awk '{print $4}')

if [ -z "$TEX_FILES" ]; then
    echo "No .tex files found in the most recent .zip file."
    exit 1
fi

TEX_FILE=$(echo "$TEX_FILES" | head -n 1)

# Extract the content between \begin{document} and \end{document> from the .tex file, excluding these lines
CONTENT=$(unzip -p "$MOST_RECENT_ZIP" "$TEX_FILE" | sed -n '/\\begin{document}/, /\\end{document}/ { /\\begin{document}/!{/\\end{document}/!{/\\includegraphics/!p}}}')

read -p "Append $(basename "$MOST_RECENT_ZIP"), created on $(date -d @$(stat -c %W "$MOST_RECENT_ZIP")), to $(basename "$TARGET_FILE")? (Y/n) " choice
case "$choice" in
  ""|y|Y )
    sed -i '0,/^\\end{document}$/s///' "$TARGET_FILE"
    echo "% Date added: $(date)" >> "$TARGET_FILE"
    echo "$CONTENT" >> "$TARGET_FILE"
    echo "Content appended to $TARGET_FILE."
    echo "\end{document}" >> $TARGET_FILE
    ;;
  n|N )
    echo "Canceled"
    ;;
  * )
    echo "Invalid choice. Operation canceled."
    ;;
esac

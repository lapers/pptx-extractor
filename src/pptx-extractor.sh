#!/bin/bash

# Check if a PPTX file is provided
if [ -z "$1" ]; then
    echo "No PowerPoint file provided."
    exit 1
fi

PPTX_FILE="$1"

TMP_DIR="/data/.tmp"
SLIDES_DIR="$TMP_DIR/ppt/slides"
MEDIA_DIR="$TMP_DIR/ppt/media"

RESULT_DIR="/data/result"

# Create result and temporary directories
mkdir -p "$TMP_DIR"
mkdir -p "$RESULT_DIR"

# Unzip the PowerPoint file
unzip -o "$PPTX_FILE" -d "$TMP_DIR" | awk 'BEGIN {ORS=" "} {print "."}'; echo

# Extract the media files
for xml_file in "$SLIDES_DIR"/slide*.xml; do
    # Extract the slide number from the file name using sed (e.g., slide15.xml -> 15)
    slide_number=$(basename "$xml_file" | sed -e 's/slide\([0-9]*\)\.xml/\1/')

    # Check if slide_number is a number
    if ! [[ "$slide_number" =~ ^[0-9]+$ ]]; then
        echo "Warning: Slide number not found for $xml_file"
        continue
    fi

    echo "Processing slide: $(basename "$xml_file")"

    # Define the output text file path
    output_txt_file="$RESULT_DIR/slide${slide_number}_content.txt"

    # Extract text from the XML file
    xmlstarlet sel -T -t -m "//a:t" -v . -n "$xml_file" > "$output_txt_file"

    rels_file="$SLIDES_DIR/_rels/slide${slide_number}.xml.rels"

    # Check if the relationships file exists
    if [ ! -f "$rels_file" ]; then
        echo "Relationship file not found: $rels_file"
        continue
    fi

    echo "Reading $rels_file..."

    while IFS= read -r line; do
        # Maintain a list of processed targets to avoid duplication
        declare -A processed_targets

        start=0
        while [[ "${line:start}" =~ Target=\"([^\"]+)\" ]]; do
            internal_name="${BASH_REMATCH[1]}"

            if [[ "${internal_name##*.}" != "xml" ]]; then
                # Check if the file has already been processed
                if [[ -z "${processed_targets["$internal_name"]}" ]]; then
                    processed_targets["$internal_name"]=1
                    actual_file="$SLIDES_DIR/${internal_name}"

                    if [ -f "$actual_file" ]; then
                        counter=1
                        while [ -n "$(ls $RESULT_DIR/slide${slide_number}_media${counter}.* 2>/dev/null)" ]; do
                            counter=$((counter + 1))
                        done

                        target_file="slide${slide_number}_media${counter}.${actual_file##*.}"
                        echo "Copying $actual_file to $target_file"
                        cp "$actual_file" "$RESULT_DIR/$target_file"
                    else
                        echo "Warning: Media file not found, expected file: $actual_file"
                    fi
                fi
            else
                # Skip XML files
                echo "Skipping XML file: $internal_name"
            fi

            # Update the start position for the next iteration
            let start+=${#BASH_REMATCH[0]}
        done
    done <<< $(xmlstarlet sel -N r="http://schemas.openxmlformats.org/package/2006/relationships" -t -m "//r:Relationship" -c "." "$rels_file")
done

echo "Done."

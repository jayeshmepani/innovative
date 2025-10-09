#!/bin/bash

# A script to parse the provided text file and create 29 separate HTML demo files.

# --- Configuration ---
SOURCE_FILE="source.txt"
OUTPUT_DIR="transformers-js-demos"

# --- Pre-flight Checks ---
# Check if the source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: Source file '$SOURCE_FILE' not found."
    echo "Please save the provided content into a file with that name."
    exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"
echo "Output directory '$OUTPUT_DIR' is ready."
echo "---"

# --- Main Logic (using awk) ---
# awk is a powerful tool for processing text files line-by-line.
# We use it here as a state machine to identify headers and code blocks.
awk -v out_dir="$OUTPUT_DIR" '
    # This block runs when a line matches the pattern /^#### [0-9]+\./
    # e.g., "#### 1. Fill-Mask Demo"
    /^#### [0-9]+\./ {
        # Get the task name by processing the current line ($0)
        task_name = $0

        # 1. Remove the prefix "#### [number]. "
        sub(/^#### [0-9]+\. /, "", task_name)

        # 2. Remove the " Demo" suffix
        sub(/ Demo$/, "", task_name)
        
        # 3. Convert to lowercase
        task_name = tolower(task_name)
        
        # 4. Replace special characters and spaces with hyphens for a clean filename
        gsub(/ \/ /, "-", task_name)       # Handle "tasks / pipelines"
        gsub(/ \(.*\)/, "", task_name)      # Remove parenthetical parts like "(includes Sentiment Analysis)"
        gsub(/,/, "", task_name)           # Remove commas
        gsub(/ /, "-", task_name)           # Replace spaces with hyphens

        # Construct the final filename
        filename = out_dir "/demo-" task_name ".html"
        
        # Inform the user
        print "Creating " filename "..."
        
        # Reset the code block flag
        in_code_block = 0
        
        # Skip to the next line of input so we dont process this header further
        next
    }

    # This block runs when a line is exactly "```html"
    /^```html$/ {
        # If we have a valid filename from a preceding header, set the flag to start capturing
        if (filename) {
            in_code_block = 1
        }
        # Skip to the next line (so we dont write ```html to the file)
        next
    }

    # This block runs when a line is exactly "```"
    /^```$/ {
        # Unset the flag to stop capturing
        in_code_block = 0
        # Skip to the next line
        next
    }

    # This block runs for any line IF the in_code_block flag is set to 1
    in_code_block == 1 {
        # Append the current line to the current file.
        print >> filename
    }
' "$SOURCE_FILE"

# --- Final Message ---
echo "---"
echo "All 29 demo files have been created successfully in the '$OUTPUT_DIR' directory!"
echo "You can now open them in your browser (e.g., open $OUTPUT_DIR/demo-fill-mask.html)."
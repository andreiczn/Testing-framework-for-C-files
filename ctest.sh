#!/bin/bash


echo "----------------------------------------"

# Checking if the number of arguments is correct
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 SOURCE_FOLDER CHECKS_FOLDER"
    echo "Example: ./ctest.sh /path/to/SOURCE_FOLDER /path/to/CHECKS_FOLDER"
    exit 1
fi

# Setting the source folder, output folder, and checks folder
SOURCE_FOLDER="$1"
OUTPUT_FOLDER="$SOURCE_FOLDER/Output"
CHECKS_FOLDER="$2"

# Checking if the source folder exists
if [ ! -d "$SOURCE_FOLDER" ]; then
    echo "Error: The source folder you provided as an argument does not exist." 
    exit 1
fi

# Checking if the 'checks' folder exists
if [ ! -d "$CHECKS_FOLDER" ]; then
    echo "Error: The checks folder you provided as an argument does not exist."
    exit 1
fi

# Finding all files with ".c" extension in the source folder (all C source files)
c_files=$(find $SOURCE_FOLDER -type f -name "*.c")

# Checking if there is at least one C source file
if [ -z "$c_files" ]; then
	echo "Error: No C source files were found in the source folder you provided as argument"
	exit 1
fi

# Finding all C source files in the source folder
c_files=$(find "$SOURCE_FOLDER" -type f -name "*.c")




# Creating Output folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"




# Compiling and running each C source file
for file in $c_files; do
    # Extract the filename without extension
    filename=$(basename -- "$file")
    filename_noext="${filename%.*}"
    filename_noext_output="${filename_noext}_output"

    # Compiling the C source file
    if gcc "$file" -o "$OUTPUT_FOLDER/$filename_noext"; then
        # Running the compiled executable
        "$OUTPUT_FOLDER/$filename_noext" > "$OUTPUT_FOLDER/$filename_noext_output.txt"
	echo "Output: " 
        cat "$OUTPUT_FOLDER/$filename_noext_output.txt"
	
	echo "Checking if the output was successfully redirected..."
	exit_code=$?	

	# Checking the exit code
	if [ $exit_code -eq 0 ]; then
    		echo "Test for $filename_noext passed (Exit code: 0)"
	else
    		echo "Test for $filename_noext failed (Exit code: $exit_code)"
	fi

        # Checking against the check files
        check_file="$CHECKS_FOLDER/$filename_noext.txt"
	# cat "$check_file"
	# cmp "$OUTPUT_FOLDER/$filename_noext_output.txt" "$check_file"
        if [ -e "$check_file" ]; then
            # Comparing the output with the check file
	    echo "Comparing output for $filename_noext_output with $check_file..."
	    # diff "$OUTPUT_FOLDER/$filename_noext_output.txt" "$check_file"
            if diff -q -Z "$OUTPUT_FOLDER/$filename_noext_output.txt" "$check_file" > /dev/null; then
                echo "Output for $filename_noext matches the check file; the output is identical to the expected one"
            else
                echo "Output for $filename_noext does not match the check file"
            fi
        else
            echo "No check file found for $filename_noext"
        fi
    else
        echo "Error: Compilation failed for $filename_noext"
    fi

    echo "----------------------------------------"
done

   

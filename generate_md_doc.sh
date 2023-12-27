#!/bin/bash

#* This script generate the documentation for the scripts based on script comments.
#* It's better than maintaining the documentation by hand, isn't it ?
#*
#*
#* Example : 
#* ```sh
#* ./generate_md_doc.sh
#* ```

source _generic_methods.sh

OUTPUT_FILE="README.md"

echo -e "${PURPLE}******************************${NC}"
echo -e "${PURPLE}* GENERATE THE DOCUMENTATION *${NC}"
echo -e "${PURPLE}******************************${NC}"

if [ -z "$1" ]; then
	SOURCE_PATH='./'
else
	SOURCE_PATH=$1
fi

OUTPUT_FILE=${SOURCE_PATH}$OUTPUT_FILE

echo Output file: $OUTPUT_FILE
echo "# Bash scripts" > $OUTPUT_FILE
echo "This folder contain scripts to ease life while developing on Android." >> $OUTPUT_FILE
echo "" >> $OUTPUT_FILE

# Source of the trick to use list of extensions :
# https://stackoverflow.com/a/1447974
for filename in ${SOURCE_PATH}*.{sh,ps1}; do
	echo -e "${CYAN}Handle $filename${NC}"
	echo "## $filename" >> $OUTPUT_FILE
	# echo `$filename -v` >> $OUTPUT_FILE

	grep "^#\*.*" $filename | cut -c 4-  >> $OUTPUT_FILE
	echo "" >> $OUTPUT_FILE

	#echo `$filename -h` >> $OUTPUT_FILE
done

echo -e "${GREEN}Done, please read the file: $OUTPUT_FILE${NC}"
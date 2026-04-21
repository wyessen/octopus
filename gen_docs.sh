#!/bin/bash

INPUT_FILE="lua/keymaps.lua"
OUTPUT_FILE="doc/octopus.txt"

mkdir -p doc

# 1. Overwrite with Header
cat << EOF > "$OUTPUT_FILE"
*octopus.txt* Keybindings and Configuration

==============================================================================
OCTOPUS MODULES                                              *octopus-modules*

The following Lua modules are loaded for keymap utilities:
EOF

# Extract 'require' lines for the module section
grep "local .* = require" "$INPUT_FILE" | sed -E "s/local (.*) = require\(.*\)/  - \1/" >> "$OUTPUT_FILE"

cat << EOF >> "$OUTPUT_FILE"

==============================================================================
KEYMAPS BY SECTION                                           *octopus-sections*
EOF

# 2. Parse the file line-by-line to preserve order and detect comments
while IFS= read -r line; do
    # Detect Section Comments (e.g., -- File operations)
    if [[ "$line" =~ ^--[[:space:]]+([A-Za-z].*) ]]; then
        SECTION_NAME="${BASH_REMATCH[1]}"
        # Create a Vim tag for the section (lowercase, no spaces)
        SECTION_TAG=$(echo "$SECTION_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
        
        printf "\n%s\n%s *%s*\n\n" "------------------------------------------------------------------------------" "$(echo "$SECTION_NAME" | tr '[:lower:]' '[:upper:]')" "octopus-$SECTION_TAG" >> "$OUTPUT_FILE"
        printf "%-4s | %-15s | %s\n" "Mode" "Key" "Description" >> "$OUTPUT_FILE"
        printf "%-4s | %-15s | %s\n" "----" "---------------" "-------------------------------------------------------" >> "$OUTPUT_FILE"
    
    # Detect Keymaps
    elif [[ "$line" =~ vim\.keymap\.set && "$line" =~ desc ]]; then
        # Extract Mode
        MODE=$(echo "$line" | sed -E "s/^.*set\(['\"]([^'\"]+)['\"].*/\1/")
        # Extract Keys (The logic now handles functions vs strings as the 3rd arg)
        KEYS=$(echo "$line" | sed -E "s/^.*set\(['\"][^'\"]+['\"],[[:space:]]*['\"]([^'\"]+)['\"].*/\1/")
        # Extract Description
        DESC=$(echo "$line" | sed -E "s/.*desc[[:space:]]*=[[:space:]]*['\"]([^'\"]+)['\"].*/\1/")

        if [[ -n "$KEYS" && -n "$DESC" ]]; then
            printf "%-4s | %-15s | %s\n" "$MODE" "$KEYS" "$DESC" >> "$OUTPUT_FILE"
        fi
    fi
done < "$INPUT_FILE"

# 3. Footer
cat << EOF >> "$OUTPUT_FILE"

==============================================================================
 vim:tw=78:ts=8:ft=help:norl:
EOF

echo "Generated sectioned documentation in $OUTPUT_FILE"


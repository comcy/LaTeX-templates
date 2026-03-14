#!/bin/bash

# Configuration
CONFIG_DIR="$HOME/.latex-cli"
CONFIG_FILE="$CONFIG_DIR/config.yaml"
TEMPLATES_DIR="$(dirname "$(realpath "$0")")/../templates"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Ensure config directory exists
mkdir -p "$CONFIG_DIR"

function usage() {
    echo -e "${BLUE}Usage: latex-cli [command]${NC}"
    echo ""
    echo "Commands:"
    echo "  init           Initialize local configuration"
    echo "  new [type]     Create a new document (e.g., letter)"
    echo "  templates      List available templates"
    echo "  config         Show current configuration"
    exit 1
}

function get_config_value() {
    local key=$1
    if [[ -f "$CONFIG_FILE" ]]; then
        # Simple extraction for YAML-like format (e.g., name: "Max")
        grep "$key:" "$CONFIG_FILE" | sed -E 's/.*: "?([^"]*)"?/\1/'
    fi
}

function cmd_init() {
    echo "Initializing LaTeX CLI configuration..."
    read -p "Name: " name
    read -p "Street: " street
    read -p "City (ZIP + City): " city
    read -p "Phone: " phone
    read -p "Email: " email
    read -p "Editor (e.g., nano, vim): " editor
    read -p "LaTeX Engine (e.g., pdflatex, xelatex): " engine

    cat <<EOF > "$CONFIG_FILE"
person:
  name: "$name"
  street: "$street"
  city: "$city"
  phone: "$phone"
  email: "$email"

defaults:
  editor: "${editor:-nano}"
  engine: "${engine:-pdflatex}"
  build: true
EOF
    echo -e "${GREEN}Config saved to $CONFIG_FILE${NC}"
}

function cmd_templates() {
    echo -e "${BLUE}Available Templates:${NC}"
    ls -1 "$TEMPLATES_DIR"
}

function cmd_new() {
    local type=$1
    if [[ -z "$type" ]]; then
        echo "Error: Please specify a template type (e.g., letter)"
        exit 1
    fi

    local template_path="$TEMPLATES_DIR/$type/$type.tex"
    if [[ ! -f "$template_path" ]]; then
        echo -e "${RED}Error: Template '$type' not found in $TEMPLATES_DIR${NC}"
        exit 1
    fi

    # Read config
    local name=$(get_config_value "name")
    local street=$(get_config_value "street")
    local city=$(get_config_value "city")
    local phone=$(get_config_value "phone")
    local email=$(get_config_value "email")
    local engine=$(get_config_value "engine")

    if [[ -z "$name" ]]; then
        echo -e "${RED}Error: Config missing. Run 'latex-cli init' first.${NC}"
        exit 1
    fi

    # Prompt for recipient
    echo "Enter recipient (empty line to finish):"
    local recipient=""
    while IFS= read -r line && [[ -n "$line" ]]; do
        recipient+="${line}\\\\\\ \n"
    done
    recipient=$(echo -e "$recipient" | sed 's/\\\\\ $//')

    read -p "Subject: " subject

    # Create target directory
    local date_str=$(date +%Y-%m-%d_%H-%M)
    local target_dir="document_${type}_${date_str}"
    mkdir -p "$target_dir"
    local target_file="$target_dir/${type}.tex"
    local target_makefile="$target_dir/Makefile"

    # Copy files
    cp "$template_path" "$target_file"
    if [[ -f "$TEMPLATES_DIR/$type/Makefile" ]]; then
        cp "$TEMPLATES_DIR/$type/Makefile" "$target_makefile"
    fi

    # Replace placeholders in .tex
    sed -i "s/<<NAME>>/$name/g" "$target_file"
    sed -i "s/<<STREET>>/$street/g" "$target_file"
    sed -i "s/<<CITY>>/$city/g" "$target_file"
    sed -i "s/<<PHONE>>/$phone/g" "$target_file"
    sed -i "s/<<EMAIL>>/$email/g" "$target_file"
    sed -i "s/<<BETREFF>>/$subject/g" "$target_file"
    
    # Recipient and Text placeholder
    python3 -c "
import sys
content = open('$target_file').read()
content = content.replace('<<EMPFAENGER>>', \"\"\"$recipient\"\"\")
content = content.replace('<<TEXT>>', '[WRITE CONTENT HERE]')
with open('$target_file', 'w') as f:
    f.write(content)
"

    # Replace placeholders in Makefile
    if [[ -f "$target_makefile" ]]; then
        sed -i "s/<<ENGINE>>/${engine:-pdflatex}/g" "$target_makefile"
        sed -i "s/<<TYPE>>/$type/g" "$target_makefile"
    fi

    echo -e "${GREEN}Created new $type in $target_dir${NC}"
    
    # Open editor
    local editor=$(get_config_value "editor")
    ${editor:-nano} "$target_file"
}

# Main routing
case "$1" in
    init) cmd_init ;;
    templates) cmd_templates ;;
    new) cmd_new "$2" ;;
    config) cat "$CONFIG_FILE" ;;
    *) usage ;;
esac

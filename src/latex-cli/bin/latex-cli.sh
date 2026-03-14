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
    echo "  new [type] [name] Create a new document (e.g., letter [my_folder])"
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
    read -p "PDF Viewer (e.g., xdg-open, open): " viewer

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
  viewer: "${viewer:-xdg-open}"
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
    local name_arg=$2
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
    local viewer=$(get_config_value "viewer")

    if [[ -z "$name" ]]; then
        echo -e "${RED}Error: Config missing. Run 'latex-cli init' first.${NC}"
        exit 1
    fi

    # Recipient prompts
    echo -e "${BLUE}Recipient Details:${NC}"
    read -p "Prefix (Optional, e.g. Company): " rec_prefix
    read -p "Name: " rec_name
    read -p "Street: " rec_street
    read -p "City: " rec_city
    read -p "Subject: " subject

    # Handle optional prefix (adding LaTeX newline)
    if [[ -n "$rec_prefix" ]]; then
        rec_prefix="${rec_prefix}\\\\"
    fi

    # Create target directory
    local target_dir=""
    if [[ -n "$name_arg" ]]; then
        target_dir="$name_arg"
    else
        local date_str=$(date +%Y-%m-%d_%H-%M)
        target_dir="document_${type}_${date_str}"
    fi
    
    if [[ -d "$target_dir" ]]; then
        echo -e "${RED}Error: Directory '$target_dir' already exists.${NC}"
        exit 1
    fi
    mkdir -p "$target_dir"
    
    local target_file="$target_dir/${type}.tex"
    local target_makefile="$target_dir/Makefile"

    # Copy files
    cp "$template_path" "$target_file"
    if [[ -f "$TEMPLATES_DIR/$type/Makefile" ]]; then
        cp "$TEMPLATES_DIR/$type/Makefile" "$target_makefile"
    fi

    # Replace placeholders in .tex using Python for safety
    export REC_PREFIX="$rec_prefix"
    export REC_NAME="$rec_name"
    export REC_STREET="$rec_street"
    export REC_CITY="$rec_city"
    export MY_NAME="$name"
    export MY_STREET="$street"
    export MY_CITY="$city"
    export MY_PHONE="$phone"
    export MY_EMAIL="$email"
    export MY_SUBJECT="$subject"

    python3 -c "
import os
content = open('$target_file').read()
replacements = {
    '<<NAME>>': os.environ.get('MY_NAME', ''),
    '<<STREET>>': os.environ.get('MY_STREET', ''),
    '<<CITY>>': os.environ.get('MY_CITY', ''),
    '<<PHONE>>': os.environ.get('MY_PHONE', ''),
    '<<EMAIL>>': os.environ.get('MY_EMAIL', ''),
    '<<BETREFF>>': os.environ.get('MY_SUBJECT', ''),
    '<<RECEIVER_PREFIX>>': os.environ.get('REC_PREFIX', ''),
    '<<RECEIVER_NAME>>': os.environ.get('REC_NAME', ''),
    '<<RECEIVER_STREET>>': os.environ.get('REC_STREET', ''),
    '<<RECEIVER_CITY>>': os.environ.get('REC_CITY', ''),
    '<<TEXT>>': '[WRITE CONTENT HERE]'
}
for key, value in replacements.items():
    content = content.replace(key, value)
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

    # Post-Editor: Ask to build and open
    echo ""
    read -p "Build PDF and open with $viewer? (y/n): " do_build
    if [[ "$do_build" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "${BLUE}Building PDF...${NC}"
        (cd "$target_dir" && make)
        if [[ -f "$target_dir/${type}.pdf" ]]; then
            echo -e "${GREEN}Opening PDF...${NC}"
            ${viewer:-xdg-open} "$target_dir/${type}.pdf" &
        else
            echo -e "${RED}Error: PDF build failed.${NC}"
        fi
    fi
}

# Main routing
case "$1" in
    init) cmd_init ;;
    templates) cmd_templates ;;
    new) cmd_new "$2" "$3" ;;
    config) cat "$CONFIG_FILE" ;;
    *) usage ;;
esac

#!/bin/bash

# Configuration
CONFIG_DIR="$HOME/.latex-cli"
LETTER_CONFIG="$CONFIG_DIR/letter.yaml"
ARTICLE_CONFIG="$CONFIG_DIR/article.yaml"
TEMPLATES_DIR="$(dirname "$(realpath "$0")")/../templates"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

mkdir -p "$CONFIG_DIR"

function usage() {
    echo -e "${BLUE}Usage: latex-cli [command]${NC}"
    echo ""
    echo "Commands:"
    echo "  init letter    Initialize personal data for letters"
    echo "  init article   Add authors to the article author pool"
    echo "  new [type] [name] Create a new document"
    echo "  templates      List available templates"
    echo "  config         Show current configuration"
    exit 1
}

# Simple helper to get value from our specific YAML format (key: value)
function get_yaml_val() {
    local file=$1
    local key=$2
    if [[ -f "$file" ]]; then
        grep "^$key:" "$file" | head -n 1 | sed -E "s/^$key:[[:space:]]*\"?(.*)\"?[[:space:]]*$/\1/" | sed 's/"$//'
    fi
}

function cmd_init_letter() {
    local add_mode=false
    if [[ "$1" == "--add-person" || "$1" == "--add" ]]; then
        add_mode=true
    fi

    if [[ "$add_mode" == "false" && -f "$LETTER_CONFIG" ]]; then
        read -p "Letter config already exists. Update it? (y/n): " confirm
        [[ ! "$confirm" =~ ^([yY][eE][sS]|[yY])$ ]] && return
    fi

    echo -e "${BLUE}Initializing Letter Data...${NC}"
    read -p "Name [$(get_yaml_val "$LETTER_CONFIG" "name")]: " name
    read -p "Street [$(get_yaml_val "$LETTER_CONFIG" "street")]: " street
    read -p "City (ZIP + City) [$(get_yaml_val "$LETTER_CONFIG" "city")]: " city
    read -p "Phone [$(get_yaml_val "$LETTER_CONFIG" "phone")]: " phone
    read -p "Email [$(get_yaml_val "$LETTER_CONFIG" "email")]: " email
    read -p "Business Email [$(get_yaml_val "$LETTER_CONFIG" "business_email")]: " b_email
    read -p "Editor (e.g. code, nano) [$(get_yaml_val "$LETTER_CONFIG" "editor")]: " editor
    read -p "LaTeX Engine [$(get_yaml_val "$LETTER_CONFIG" "engine")]: " engine
    read -p "PDF Viewer [$(get_yaml_val "$LETTER_CONFIG" "viewer")]: " viewer

    cat <<EOF > "$LETTER_CONFIG"
name: "${name:-$(get_yaml_val "$LETTER_CONFIG" "name")}"
street: "${street:-$(get_yaml_val "$LETTER_CONFIG" "street")}"
city: "${city:-$(get_yaml_val "$LETTER_CONFIG" "city")}"
phone: "${phone:-$(get_yaml_val "$LETTER_CONFIG" "phone")}"
email: "${email:-$(get_yaml_val "$LETTER_CONFIG" "email")}"
business_email: "${b_email:-$(get_yaml_val "$LETTER_CONFIG" "business_email")}"
editor: "${editor:-${editor:-$(get_yaml_val "$LETTER_CONFIG" "editor"):-nano}}"
engine: "${engine:-${engine:-$(get_yaml_val "$LETTER_CONFIG" "engine"):-pdflatex}}"
viewer: "${viewer:-${viewer:-$(get_yaml_val "$LETTER_CONFIG" "viewer"):-xdg-open}}"
EOF
    echo -e "${GREEN}Saved to $LETTER_CONFIG${NC}"
}

function cmd_init_article() {
    local add_mode=false
    if [[ "$1" == "--add-author" || "$1" == "--add" ]]; then
        add_mode=true
    fi

    if [[ "$add_mode" == "false" && -f "$ARTICLE_CONFIG" ]]; then
        read -p "Article config already exists. Add another author? (y/n): " confirm
        [[ ! "$confirm" =~ ^([yY][eE][sS]|[yY])$ ]] && return
    fi

    echo -e "${BLUE}Adding Author to Pool...${NC}"
    read -p "Name: " a_name
    read -p "Email: " a_email
    read -p "Department: " a_dept

    # Prevent duplicates by checking name and email
    if [[ -f "$ARTICLE_CONFIG" ]]; then
        if grep -q "name: \"$a_name\"" "$ARTICLE_CONFIG" && grep -q "email: \"$a_email\"" "$ARTICLE_CONFIG"; then
            echo -e "${YELLOW}Author $a_name already exists in pool.${NC}"
            return
        fi
    fi

    # We store authors in a simple dash-prefixed format
    cat <<EOF >> "$ARTICLE_CONFIG"
- name: "$a_name"
  email: "$a_email"
  dept: "$a_dept"
EOF
    echo -e "${GREEN}Author added to $ARTICLE_CONFIG${NC}"
}

function cmd_init() {
    case "$1" in
        letter) 
            shift
            cmd_init_letter "$@" 
            ;;
        article) 
            shift
            cmd_init_article "$@" 
            ;;
        *) echo "Usage: latex-cli init [letter|article] [--add-author|--add-person]"; exit 1 ;;
    esac
}

function cmd_new() {
    local type=$1
    local name_arg=$2
    if [[ -z "$type" ]]; then usage; fi

    local template_dir="$TEMPLATES_DIR/$type"
    if [[ ! -d "$template_dir" ]]; then
        echo -e "${RED}Error: Template '$type' not found.${NC}"
        exit 1
    fi

    # 1. Target Directory Setup
    local target_dir="${name_arg:-document_${type}_$(date +%Y-%m-%d_%H-%M)}"
    mkdir -p "$target_dir"
    cp -r "$template_dir/." "$target_dir/"
    local target_file="$target_dir/${type}.tex"

    # 2. Logic based on type
    if [[ "$type" == "letter" ]]; then
        # Load letter config
        local my_name=$(get_yaml_val "$LETTER_CONFIG" "name")
        local engine=$(get_yaml_val "$LETTER_CONFIG" "engine")
        local viewer=$(get_yaml_val "$LETTER_CONFIG" "viewer")
        local editor=$(get_yaml_val "$LETTER_CONFIG" "editor")

        echo -e "${BLUE}Recipient Details:${NC}"
        read -p "Prefix: " rec_prefix
        read -p "Name: " rec_name
        read -p "Street: " rec_street
        read -p "City: " rec_city
        read -p "Subject: " subject

        [[ -n "$rec_prefix" ]] && rec_prefix="${rec_prefix}\\\\\\"

        # Replace placeholders (Simple sed for letters)
        sed -i "s/<<NAME>>/$(get_yaml_val "$LETTER_CONFIG" "name")/g" "$target_file"
        sed -i "s/<<STREET>>/$(get_yaml_val "$LETTER_CONFIG" "street")/g" "$target_file"
        sed -i "s/<<CITY>>/$(get_yaml_val "$LETTER_CONFIG" "city")/g" "$target_file"
        sed -i "s/<<PHONE>>/$(get_yaml_val "$LETTER_CONFIG" "phone")/g" "$target_file"
        sed -i "s/<<EMAIL>>/$(get_yaml_val "$LETTER_CONFIG" "email")/g" "$target_file"
        sed -i "s/<<BUSINESS_EMAIL>>/$(get_yaml_val "$LETTER_CONFIG" "business_email")/g" "$target_file"
        sed -i "s/<<BETREFF>>/$subject/g" "$target_file"
        sed -i "s/<<RECEIVER_PREFIX>>/$rec_prefix/g" "$target_file"
        sed -i "s/<<RECEIVER_NAME>>/$rec_name/g" "$target_file"
        sed -i "s/<<RECEIVER_STREET>>/$rec_street/g" "$target_file"
        sed -i "s/<<RECEIVER_CITY>>/$rec_city/g" "$target_file"
        sed -i "s/<<TEXT>>/[WRITE CONTENT HERE]/g" "$target_file"

    elif [[ "$type" == "article" ]]; then
        # Load common defaults from letter_config if available
        local engine=$(get_yaml_val "$LETTER_CONFIG" "engine")
        local viewer=$(get_yaml_val "$LETTER_CONFIG" "viewer")
        local editor=$(get_yaml_val "$LETTER_CONFIG" "editor")

        read -p "Article Title: " subject

        # Selection of Authors
        if [[ ! -f "$ARTICLE_CONFIG" ]]; then
            echo -e "${RED}No author pool found. Run 'latex-cli init article' first.${NC}"
            exit 1
        fi

        echo -e "\n${BLUE}Select Authors from Pool (comma separated, e.g. 1,3):${NC}"
        
        # Robust parsing of authors from YAML
        local authors_names=()
        local authors_emails=()
        local authors_depts=()
        
        local current_name=""
        local current_email=""
        local current_dept=""

        while IFS= read -r line; do
            if [[ "$line" =~ ^-[[:space:]]name:[[:space:]]\"?([^\"]*)\"? ]]; then
                if [[ -n "$current_name" ]]; then
                    authors_names+=("$current_name")
                    authors_emails+=("$current_email")
                    authors_depts+=("$current_dept")
                fi
                current_name="${BASH_REMATCH[1]}"
                current_email=""
                current_dept=""
            elif [[ "$line" =~ ^[[:space:]]+email:[[:space:]]\"?([^\"]*)\"? ]]; then
                current_email="${BASH_REMATCH[1]}"
            elif [[ "$line" =~ ^[[:space:]]+dept:[[:space:]]\"?([^\"]*)\"? ]]; then
                current_dept="${BASH_REMATCH[1]}"
            fi
        done < "$ARTICLE_CONFIG"
        
        if [[ -n "$current_name" ]]; then
            authors_names+=("$current_name")
            authors_emails+=("$current_email")
            authors_depts+=("$current_dept")
        fi

        for i in "${!authors_names[@]}"; do
            echo "$((i+1))) ${authors_names[$i]} (${authors_emails[$i]})"
        done
        read -p "Selection: " selection

        local author_block=""
        local affiliation_block=""
        local count=1

        IFS=',' read -ra ADDS <<< "$selection"
        for idx in "${ADDS[@]}"; do
            # Trim whitespace
            idx=$(echo "$idx" | xargs)
            local real_idx=$((idx-1))
            
            if [[ $real_idx -lt 0 || $real_idx -ge ${#authors_names[@]} ]]; then
                echo -e "${YELLOW}Warning: Invalid selection $idx. Skipping.${NC}"
                continue
            fi

            local name="${authors_names[$real_idx]}"
            local email="${authors_emails[$real_idx]}"
            local dept="${authors_depts[$real_idx]}"

            [[ $count -gt 1 ]] && author_block+=" \\\\and "
            author_block+="${name}\\\\textsuperscript{${count}}\\\\\\\\{\\\\small \\\\href{mailto:${email}}{(${email})}}"
            [[ -n "$dept" ]] && affiliation_block+="\\\\textsuperscript{${count}}${dept}\\\\\\\\"
            ((count++))
        done

        # Replace in .tex (using | as delimiter because of backslashes)
        sed -i "s|<<BETREFF>>|$subject|g" "$target_file"
        sed -i "s|<<AUTHORS>>|$author_block|g" "$target_file"
        sed -i "s|<<AFFILIATIONS>>|$affiliation_block|g" "$target_file"
        sed -i "s|<<TEXT>>|[WRITE CONTENT HERE]|g" "$target_file"
    fi

    # Replace placeholders in Makefile
    sed -i "s/<<ENGINE>>/${engine:-pdflatex}/g" "$target_dir/Makefile"
    sed -i "s/<<TYPE>>/$type/g" "$target_dir/Makefile"

    echo -e "${GREEN}Created new $type in $target_dir${NC}"
    ${editor:-nano} "$target_file"

    echo ""
    read -p "Build PDF and open with $viewer? (y/n): " do_build
    if [[ "$do_build" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        (cd "$target_dir" && make)
        [[ -f "$target_dir/${type}.pdf" ]] && ${viewer:-xdg-open} "$target_dir/${type}.pdf" &
    fi
}

case "$1" in
    init) cmd_init "$2" ;;
    templates) ls -1 "$TEMPLATES_DIR" ;;
    new) cmd_new "$2" "$3" ;;
    config) cat "$LETTER_CONFIG" "$ARTICLE_CONFIG" 2>/dev/null ;;
    *) usage ;;
esac

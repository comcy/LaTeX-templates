#!/bin/bash

set -e

# --- Configuration ---
REPO_URL="https://github.com/comcy/LaTeX-templates.git"
SUB_DIR="src/latex-cli"
CONFIG_DIR="$HOME/.latex-cli"
REPO_DEST="$CONFIG_DIR/src-repo"
BIN_DIR="$HOME/.local/bin"
BIN_DEST="$BIN_DIR/latex-cli"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}--- LaTeX CLI Installer ---${NC}"

# 1. Detect environment and Repo Source
if [ -d "$(dirname "${BASH_SOURCE[0]}")/templates" ]; then
    # Running from a local clone
    REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    echo -e "Installing from local directory: ${YELLOW}$REPO_DIR${NC}"
else
    # Running via curl | bash
    echo -e "${YELLOW}Remote execution detected. Cloning repository...${NC}"
    mkdir -p "$CONFIG_DIR"
    if [ -d "$REPO_DEST" ]; then
        echo "Updating existing repository in $REPO_DEST..."
        cd "$REPO_DEST" && git pull --quiet
    else
        git clone "$REPO_URL" "$REPO_DEST" --quiet
    fi
    # In a monorepo, the actual tool is in a subfolder
    REPO_DIR="$REPO_DEST/$SUB_DIR"
fi

# 2. Ensure directories exist
mkdir -p "$CONFIG_DIR"
mkdir -p "$BIN_DIR"

# 3. Link templates
echo "Linking templates..."
# Remove existing symlink or directory to prevent nested "templates/templates"
rm -rf "$CONFIG_DIR/templates"
ln -sf "$REPO_DIR/templates" "$CONFIG_DIR/templates"

# 4. Ask user for version preference
echo -e "\nWhich version would you like to install?"
echo -e "1) ${BLUE}TypeScript (Node.js)${NC} - Feature-rich, interactive prompts"
echo -e "2) ${BLUE}Bash${NC}            - Lightweight, zero dependencies"
# Added < /dev/tty to capture input when run via curl | bash
read -p "Selection [1-2]: " version_choice < /dev/tty

USE_NODE=false

if [ "$version_choice" == "1" ]; then
    if command -v node >/dev/null 2>&1; then
        echo -e "${GREEN}Node.js detected. Preparing TypeScript version...${NC}"
        cd "$REPO_DIR"
        
        # Using --no-audit for speed and --quiet to reduce noise
        if npm install --quiet && npm run build --quiet; then
            if [[ -f "dist/index.js" ]]; then
                USE_NODE=true
            else
                echo -e "${RED}Build output (dist/index.js) not found.${NC}"
            fi
        else
            echo -e "${RED}Build failed.${NC}"
        fi
    else
        echo -e "${RED}Error: Node.js not found. Cannot install TypeScript version.${NC}"
        echo -e "Falling back to Bash version..."
    fi
fi

# 5. Link binary to ~/.local/bin
if [ "$USE_NODE" = true ]; then
    # Create a wrapper for the Node version
    cat <<EOF > "$BIN_DEST"
#!/bin/bash
node "$REPO_DIR/dist/index.js" "\$@"
EOF
    chmod +x "$BIN_DEST"
    echo -e "${GREEN}TypeScript version installed as 'latex-cli'${NC}"
else
    ln -sf "$REPO_DIR/bin/latex-cli.sh" "$BIN_DEST"
    echo -e "${GREEN}Bash version installed as 'latex-cli'${NC}"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "1. Run ${BLUE}latex-cli init${NC} to configure your personal data."

# 6. Check PATH and ask to add
PATH_ADDED=false
if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
    echo -e "\n${YELLOW}Warning: $BIN_DIR is not in your PATH.${NC}"
    
    # Identify shell config file
    SHELL_NAME=$(basename "$SHELL")
    CONFIG_FILE=""
    if [ "$SHELL_NAME" == "zsh" ]; then
        CONFIG_FILE="$HOME/.zshrc"
    elif [ "$SHELL_NAME" == "bash" ]; then
        CONFIG_FILE="$HOME/.bashrc"
    fi

    if [ -n "$CONFIG_FILE" ]; then
        echo -e "Should I add it to your ${BLUE}$CONFIG_FILE${NC}? (y/n)"
        # Added < /dev/tty to capture input when run via curl | bash
        read -r response < /dev/tty
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo -e "\n# Added by LaTeX CLI Installer" >> "$CONFIG_FILE"
            echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$CONFIG_FILE"
            echo -e "${GREEN}Path added to $CONFIG_FILE.${NC}"
            PATH_ADDED=true
        else
            echo -e "Please add the following line to your shell config manually:"
            echo -e "${BLUE}export PATH=\"$BIN_DIR:\$PATH\"${NC}"
        fi
    else
        echo -e "Please add the following line to your shell config manually:"
        echo -e "${BLUE}export PATH=\"$BIN_DIR:\$PATH\"${NC}"
    fi
fi

if [ "$PATH_ADDED" = true ]; then
    echo -e "\n${YELLOW}IMPORTANT: Please restart your terminal or run:${NC}"
    echo -e "${BLUE}source $CONFIG_FILE${NC}"
fi

#!/bin/bash

set -e

# --- Configuration ---
# REPLACE THIS with your actual repository URL for curl installation to work!
REPO_URL="https://github.com/USERNAME/latex-cli.git"
CONFIG_DIR="$HOME/.latex-cli"
REPO_DEST="$CONFIG_DIR/src"
BIN_DEST="$HOME/.local/bin/latex-cli"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
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
    REPO_DIR="$REPO_DEST"
fi

# 2. Ensure directories exist
mkdir -p "$CONFIG_DIR"
mkdir -p "$HOME/.local/bin"

# 3. Link templates
# We link to the templates in the repo so updates to the repo affect the CLI
echo "Linking templates..."
ln -sf "$REPO_DIR/templates" "$CONFIG_DIR/templates"

# 4. Detect Node.js and Setup CLI
USE_NODE=false
if command -v node >/dev/null 2>&1; then
    echo -e "${GREEN}Node.js detected. Preparing TypeScript version...${NC}"
    cd "$REPO_DIR"
    
    # Try to install and build
    if npm install --quiet && npm run build --quiet; then
        if [[ -f "dist/index.js" ]]; then
            USE_NODE=true
        fi
    else
        echo -e "${YELLOW}Build failed. Falling back to Bash version.${NC}"
    fi
else
    echo -e "${YELLOW}Node.js not found. Using Bash version.${NC}"
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
echo -e "1. Ensure ${BLUE}$HOME/.local/bin${NC} is in your PATH."
echo -e "2. Run ${BLUE}latex-cli init${NC} to configure your personal data."

# Check PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "\n${YELLOW}Warning: $HOME/.local/bin is not in your PATH.${NC}"
    echo "Add this to your .bashrc or .zshrc:"
    echo -e "${BLUE}export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
fi

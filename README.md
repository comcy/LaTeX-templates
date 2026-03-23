![LaTeX CLI](latex-cli-logo.png)

# LaTeX CLI
A flexible CLI tool for quickly generating LaTeX documents (letters, scientific articles) based on personalized templates and a dynamic author system.

## Features

- **Lightweight Architecture:** Completely dependency-free Bash script.
- **Container-Ready:** Build PDFs in a pre-configured LaTeX environment (Podman/Docker). No local LaTeX installation required!
- **Commercial-Safe:** Optimized for Podman to avoid Docker Desktop license costs in corporate environments.
- **Separate Configurations:** Dedicated YAML files for personal letter data and a pool of authors for scientific articles.
- **Scientific Articles:** Support for multiple authors, departments, automatic bibliography (Biber), and lists of figures.
- **Automated Workflow:** Create projects, open in your editor, build PDFs, and view them—all in one go.

## 1. Installation

Use the one-line installer to set up the tool and all templates:

```bash
curl -sL https://raw.githubusercontent.com/comcy/LaTeX-templates/master/install.sh | bash
```

### Container Setup (Optional but Recommended)
To use LaTeX without installing 5GB+ of packages locally:
```bash
latex-cli setup-container
```
*This builds a local image based on the official, license-safe `texlive/texlive` distribution.*

## 2. Usage

### Prerequisites
- **Local:** `pdflatex`, `biber`, `make`
- **OR Container:** `podman` (recommended for commercial use) or `docker`

### Initialization
Configure your data (one-time setup or update):
```bash
# For letters (name, address, etc.) and to enable Container Mode
latex-cli init letter

# For articles (add authors to your pool)
latex-cli init article
```

### Create a New Document
```bash
# Create a letter
latex-cli new letter my_letter

# Create an article (allows selecting authors from the pool)
latex-cli new article my_research_paper
```

If **Container Mode** is enabled during `init`, the tool will automatically use Podman/Docker to build your PDF, ensuring a consistent environment across Linux, macOS, and Windows (WSL/Git Bash).

### Generate PDF
In any project folder, you can build manually or use the automatic prompt after editing:
```bash
# Local build
make

# Or let the CLI handle it (uses Container if configured)
latex-cli new [type] [name]
```

## 3. Development

- `bin/`: Pure Bash implementation (uses `sed`/`grep` instead of Python/Node).
- `templates/`: LaTeX templates. Simply add new templates as a folder containing a `.tex` file and a `Makefile`.

## License
This project is part of the [comcy/LaTeX-CLI](https://github.com/comcy/LaTeX-CLI) collection.

The collection is licensed under MIT License.

Copyright (c) 2026 Christian Silfang

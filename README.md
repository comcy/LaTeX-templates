![LaTeX CLI](latex-cli-logo.png)

# LaTeX CLI
A flexible CLI tool for quickly generating LaTeX documents (letters, scientific articles) based on personalized templates and a dynamic author system.

## Features

- **Lightweight Architecture:** Completely dependency-free Bash script.
- **Separate Configurations:** Dedicated YAML files for personal letter data and a pool of authors for scientific articles.
- **Scientific Articles:** Support for multiple authors, departments, automatic bibliography (Biber), and lists of figures.
- **Automated Workflow:** Create projects, open in your editor, build PDFs, and view them—all in one go.

## 1. Installation

Use the one-line installer to set up the tool and all templates:

```bash
curl -sL https://raw.githubusercontent.com/comcy/LaTeX-templates/master/install.sh | bash
```

*The installer will help you set up your PATH if necessary.*

## 2. Usage

### Initialization
Configure your data (one-time setup or update):
```bash
# For letters (name, address, etc.)
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

### Generate PDF
In any project folder, you can build manually or use the automatic prompt after editing:
```bash
make
```
*Note: Articles require `biber` for bibliography processing.*

## 3. Development

- `bin/`: Pure Bash implementation (uses `sed`/`grep` instead of Python/Node).
- `templates/`: LaTeX templates. Simply add new templates as a folder containing a `.tex` file and a `Makefile`.

## License
This project is part of the [comcy/LaTeX-CLI](https://github.com/comcy/LaTeX-CLI) collection.

The collection is licensed under MIT License.

Copyright (c) 2026 Christian Silfang
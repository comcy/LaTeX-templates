# LaTeX CLI

Ein flexibles CLI-Tool zur schnellen Erzeugung von LaTeX-Dokumenten (Briefe, wissenschaftliche Artikel) basierend auf personalisierten Templates und einem dynamischen Autoren-System.

## Features

- **Zweigleisige Architektur:** Läuft als Node.js/TypeScript-Tool oder als komplett abhängigkeitsfreies Bash-Skript.
- **Getrennte Konfigurationen:** Eigene YAML-Dateien für Briefdaten und einen Pool von Autoren für Artikel.
- **Wissenschaftliche Artikel:** Unterstützung für mehrere Autoren, Abteilungen, automatische Bibliographie (Biber) und Abbildungsverzeichnisse.
- **Automatischer Workflow:** Projekt anlegen, im Editor öffnen, PDF bauen und im Viewer anzeigen – alles in einem Rutsch.

## 1. Installation

Nutze den One-Line Installer, um das Tool und alle Templates einzurichten:

```bash
curl -sL https://raw.githubusercontent.com/comcy/LaTeX-templates/master/src/latex-cli/install.sh | bash
```

*Der Installer fragt dich, welche Version (Bash oder TypeScript) du bevorzugst und hilft dir beim Einrichten des PATHs.*

## 2. Usage

### Initialisierung
Konfiguriere deine Daten (einmalig oder zum Aktualisieren):
```bash
# Für Briefe (Name, Adresse, etc.)
latex-cli init letter

# Für Artikel (Füge Autoren zu deinem Pool hinzu)
latex-cli init article
```

### Neues Dokument erstellen
```bash
# Einen Brief erstellen
latex-cli new letter mein_brief

# Einen Artikel erstellen (lässt dich Autoren aus dem Pool wählen)
latex-cli new article mein_forschungspapier
```

### PDF erzeugen
In jedem Projektordner kannst du manuell bauen oder den automatischen Prompt nach dem Bearbeiten nutzen:
```bash
make
```
*Hinweis: Für Artikel wird `biber` zur Verarbeitung der Bibliographie benötigt.*

## 3. Development

- `bin/`: Pure Bash Implementierung (nutzt `sed`/`grep` statt Python/Node).
- `src/`: TypeScript Implementierung.
- `templates/`: LaTeX Vorlagen. Neue Vorlagen einfach als Ordner mit einer `.tex` Datei und einem `Makefile` hinzufügen.

### TypeScript Version bauen
```bash
npm install
npm run build
```

## Lizenz
Dieses Projekt ist Teil der [comcy/LaTeX-templates](https://github.com/comcy/LaTeX-templates) Sammlung.

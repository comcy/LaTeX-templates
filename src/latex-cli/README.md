# LaTeX CLI

Ein flexibles CLI-Tool zur schnellen Erzeugung von LaTeX-Dokumenten (Briefe, Artikel, Rechnungen) basierend auf personalisierten Templates.

## Features

- **Zweigleisige Architektur:** Läuft als performantes TypeScript-Tool (Node.js) oder als leichtgewichtiges Bash-Skript (Fallback).
- **Zentrale Config:** Einmal Name, Adresse und bevorzugte LaTeX-Engine in `~/.latex-cli/config.yaml` hinterlegen.
- **Einfache Templates:** Platzhalter wie `<<NAME>>` oder `<<EMPFAENGER>>` werden automatisch ersetzt.
- **Automatischer Build:** Jedes Projekt kommt mit einem vorkonfigurierten `Makefile`.

## 1. Installation

Du kannst das Tool mit einem einzigen Befehl installieren. Der Installer lädt das Repository herunter und richtet alles ein.

### One-Line Install (Empfohlen)

```bash
curl -sL https://raw.githubusercontent.com/comcy/latex-cli/main/install.sh | bash
```

*Hinweis: Ersetze `USERNAME` mit deinem tatsächlichen GitHub-Nutzernamen.*

### Manuelle Installation (Lokales Repository)

Wenn du das Repository bereits geklont hast:
```bash
./install.sh
```

**Hinweis:** Stelle sicher, dass `~/.local/bin` in deinem `$PATH` enthalten ist.

## 2. Usage

### Initialisierung
Bevor du das Tool nutzt, musst du deine persönlichen Daten hinterlegen:
```bash
latex-cli init
```

### Neues Dokument erstellen
Erstelle einen neuen Brief oder ein anderes Dokument:
```bash
latex-cli new letter
```
Das Tool fragt dich nach dem Empfänger und dem Betreff, erstellt einen neuen Ordner und öffnet deinen bevorzugten Editor.

### Templates anzeigen
```bash
latex-cli templates
```

### PDF erzeugen
In dem neu erstellten Dokumenten-Ordner kannst du einfach `make` ausführen:
```bash
cd document_letter_2026-03-14
make
```

## 3. Development

Das Projekt ist so aufgebaut, dass es leicht erweitert werden kann.

### Struktur
- `bin/`: Enthält das Bash-CLI (`latex-cli.sh`).
- `src/`: Enthält den TypeScript-Quellcode.
- `templates/`: Hier liegen die Ordner für die verschiedenen Dokumenttypen.

### Neue Templates hinzufügen
1. Erstelle einen neuen Ordner unter `templates/my-template`.
2. Füge eine `my-template.tex` Datei hinzu.
3. Nutze Platzhalter wie `<<NAME>>`, `<<STREET>>`, `<<CITY>>`, `<<PHONE>>`, `<<EMAIL>>`, `<<BETREFF>>`, `<<EMPFAENGER>>`.
4. Kopiere das `Makefile` aus dem `letter` Template und passe es ggf. an.

### TypeScript Version entwickeln
Wenn du Node.js installiert hast, kannst du Änderungen am TS-Code wie folgt testen:

```bash
# Abhängigkeiten installieren
npm install

# Build ausführen
npm run build

# Lokal testen
node dist/index.js templates
```

### Bash Version entwickeln
Änderungen direkt in `bin/latex-cli.sh` vornehmen. Da es keine Kompilierung benötigt, sind Änderungen sofort nach dem Speichern wirksam.

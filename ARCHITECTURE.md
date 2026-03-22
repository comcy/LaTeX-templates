Projektname: latex-cli
Ziele:

- CLI Tool für verschiedene Dokumentarten 
- Leichtgewichtige Bash-Architektur
- Templates im Repo, persönliche Daten lokal in getrennten Configs
- Dynamische Autorenverwaltung für wissenschaftliche Artikel
- Automatisierter Build-Prozess mit Makefile und PDF-Viewer Integration

## 1 Grundidee der Architektur

Trennung von drei Komponenten:

1. **CLI Tool**: Erzeugt Projekte aus Templates (Bash).
2. **Templates**: LaTeX Vorlagen (Briefe, Artikel etc.) inkl. Assets.
3. **Lokale Config**: Getrennte YAML-Dateien für verschiedene Anwendungsfälle.

## 2 Empfohlene Ordnerstruktur

### Repo:
```txt
LaTeX-templates/
│
├── bin/latex-cli.sh      # Pure Bash Version (Zero-Dependencies)
├── templates/
│   ├── article/          # Artikel-Template mit bib/ und Figures/
│   ├── assignments/      # Aufgaben-Template
│   ├── letter/           # Brief-Template
│   └── ...               # Weitere Templates
└── install.sh            # Universal Installer
```

### Lokale Installation (~/.latex-cli):
```txt
~/.latex-cli/
│
├── letter.yaml           # Persönliche Daten für Briefe
├── article.yaml          # Pool an Autoren für Artikel
└── templates -> git repo # Symlink zum Template-Ordner
```

## 3 Lokale Configs (YAML)

### letter.yaml
Speichert Basisdaten für Korrespondenz:
```yaml
name: Max Mustermann
street: Musterstraße 12
city: 12345 Musterstadt
phone: "+49 123 456789"
email: max@example.com
business_email: max.work@example.com
editor: code
engine: pdflatex
viewer: okular
```

### article.yaml
Ein Pool von Autoren, die bei Projekterstellung ausgewählt werden können:
```yaml
- name: "Max Mustermann"
  email: "max@example.com"
  dept: "Physics Department"
- name: "Dr. Erika Muster"
  email: "erika@example.com"
  dept: "Chemistry Department"
```

## 4 Template System & Platzhalter

### Briefe
Verwendet `<<NAME>>`, `<<STREET>>`, `<<CITY>>`, `<<RECEIVER_NAME>>` etc.

### Artikel
Verwendet dynamische Blöcke:
- `<<AUTHORS>>`: Automatisch generierter LaTeX Block mit Namen und E-Mails in Klammern.
- `<<AFFILIATIONS>>`: Verknüpfte Abteilungen via Fußnoten.
- `Figures/`: Ordner für Bilder.
- `bib/`: Ordner für `sample.bib`.

## 5 CLI Befehle

### Initialisierung
- `latex-cli init letter`: Fragt Adressdaten ab.
- `latex-cli init article`: Fügt Autoren zum Pool hinzu.

### Dokumente erstellen
- `latex-cli new letter [name]`: Erzeugt Brief-Ordner.
- `latex-cli new article [name]`: Erzeugt Artikel-Ordner und lässt Autoren aus dem Pool auswählen (z.B. Eingabe `1,3`).

## 6 Build Prozess

Jedes Template enthält ein `Makefile`. Der Build-Prozess für Artikel umfasst:
1. `pdflatex`: Sammelt Zitate.
2. `biber`: Verarbeitet die Bibliographie (**Biber wird zwingend benötigt**).
3. `pdflatex` (2x): Finalisiert Referenzen und Verzeichnisse.

Nach dem Build wird das PDF automatisch mit dem konfigurierten `viewer` geöffnet.

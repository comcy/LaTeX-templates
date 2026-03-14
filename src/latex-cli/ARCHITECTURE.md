Projektname: latex-cli
Ziele:

- CLI Tool für verschiedene Dokumentarten 
- Templates im Repo persönliche Daten lokal in Config
- neue Dokumente schnell erzeugen
- Templates einfach erweiterbar

## 1 Grundidee der Architektur

Trennung von drei Dingen:

1. CLI Tool: erzeugt Projekte aus Templates
2. Templates: LaTeX Dateien für verschiedene Dokumenttypen
3. Lokale Config: persönliche Daten (Name, Adresse etc.)

## 2 Empfohlene Ordnerstruktur

Repo:

```txt
latex-cli
│
├── bin
│   └── latex-cli
│
├── templates
│   ├── letter
│   │   ├── letter.tex
│   │   └── Makefile
│   │
│   ├── article
│   │   ├── article.tex
│   │   └── Makefile
│   │
│   └── note
│       └── note.tex
│
└── install.sh

Lokale Installation:

~/.latex-cli
│
├── config.yaml
└── templates -> git repo
```

## 3 Lokale Config (sehr wichtig)

- YAML Format

File: `~/.latex-cli/config.yaml`
Content:
```yaml
person:
  name: Max Mustermann
  street: Musterstraße 12
  city: 12345 Musterstadt
  phone: "+49 123 456789"
  email: max@example.com

defaults:
  editor: nano
  engine: pdflatex
  viewer: xdg-open
  build: true
```

## 4 Warum Config statt personal.tex

Vorteile:

- nur eine zentrale Quelle
- CLI kann Daten automatisch einsetzen
- auch für andere Dokumentarten nutzbar

Beispiel:

- Brief
- Rechnung
- Notizen
- Artikel
- Rechnungsadresse
- Briefkopf

## 5 Template Platzhalter

Templates verwenden einfache Marker:

- Name: `<<NAME>>`
- Straße: `<<STREET>>`
- PLZ und Statd: `<<CITY>>`
- Telefon: `<<PHONE>>`
- E-Mail: `<<EMAIL>>`

Das CLI ersetzt sie automatisch aus der Config.


## 6 Beispiel Template (letter)

File: `templates/letter/letter.tex`

Content:
```tex
\documentclass[11pt,a4paper]{dinbrief}

\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{ngerman}
\usepackage{marvosym}

\address{
<<NAME>>\\
<<STREET>>\\
<<CITY>>\\[6pt]
\Telefon\ <<PHONE>>\\
\Letter\ <<EMAIL>>
}

\signature{<<NAME>>}

\begin{document}

\begin{letter}{
<<EMPFAENGER>>
}

\subject{<<BETREFF>>}

\opening{Sehr geehrte Damen und Herren,}

<<TEXT>>

\closing{Mit freundlichen Grüßen}

\end{letter}

\end{document}
```

## 7 CLI Befehle

Samples:

- latex-cli init
- latex-cli new letter
- latex-cli new article
- latex-cli config
- latex-cli templates
- latex-cli init

Erstellt lokale Struktur:

`~/.latex-cli` und fragt:

```
Name:
Straße:
Ort:
Telefon:
Mail:
Editor:
```

- `latex-cli new letter [name]`

Workflow:
- Ordnername (optional über Argument oder fragen)
- Empfänger Details
- Betreff
- Template kopieren
- Platzhalter ersetzen
- Editor öffnen
- PDF bauen

## 8 Empfänger mehrzeilig

CLI fragt:

Empfänger eingeben (leer beendet):

Input:

```txt
Finanzamt Berlin
Abteilung Steuer
Straße 1
12345 Berlin
```

CLI ersetzt:

```tex
Finanzamt Berlin\\
Abteilung Steuer\\
Straße 1\\
12345 Berlin
```

## 9 Warum diese Architektur gut ist

Sehr flexibel - Du kannst später hinzufügen:

```txt
templates/
    letter
    invoice
    report
    note
    homework
```

CLI bleibt unverändert.

## 10 Erweiterungen (später möglich)

Sehr sinnvoll wären:

- Adressbuch `~/.latex-cli/addressbook.yaml`

Dann bspw. möglich:

```sh
latex-cli new letter finanzamt
Mehrere Templates
latex-cli new letter
latex-cli new invoice
latex-cli new note
```

Automatischer PDF Viewer

nach Build:

xdg-open letter.pdf
Git Archiv

Optional:

`~/Documents/letters/2026/`

## 11 Schritt-für-Schritt Plan für das Projekt

### Phase 1 – Minimal CLI (Done)
- Bash-Version (`bin/latex-cli.sh`) für maximale Kompatibilität.
- TypeScript-Version (`src/index.ts`) für bessere UX.
- `install.sh` für `curl | bash` Setup.

### Phase 2 – Config System (Done)
- `~/.latex-cli/config.yaml` für persönliche Daten.
- Unterstützung für globale Einstellungen (Editor, LaTeX-Engine).

### Phase 3 – Template System (In Progress)
- `templates/` Ordnerstruktur.
- `latex-cli templates` zur Anzeige verfügbarer Vorlagen.

### Phase 4 – PDF Build & UX (Next)
- Automatischer PDF-Build über ein `Makefile`.
- Konfigurierbare LaTeX-Engine (pdflatex, xelatex, etc.) in der Config.
- Automatisches Öffnen des Editors und (optional) des PDF-Viewers.

## 12 Makefile Template

Jedes Template erhält ein `Makefile`, das wie folgt aussieht:

```makefile
LATEX_ENGINE = <<ENGINE>>
SOURCE = <<TYPE>>.tex
OUT = <<TYPE>>.pdf

all: $(OUT)

$(OUT): $(SOURCE)
	$(LATEX_ENGINE) $(SOURCE)

clean:
	rm -f *.aux *.log *.out *.pdf
```

## 12 Ergebnis

Dann hast du später ein Tool wie:

```sh
latex-cli init
latex-cli new letter
latex-cli new invoice
latex-cli new note
```

und deine persönlichen Daten werden automatisch eingefügt.

# TeX Live Basis-Image (Vollständige Distribution, GPL/LPPL lizenziert)
# Wir nutzen docker.io explizit für maximale Kompatibilität mit Podman
FROM docker.io/texlive/texlive:latest

# Installiere zusätzliche System-Werkzeuge, die LaTeX-Pakete oft benötigen
RUN apt-get update && apt-get install -y \
    make \
    ghostscript \
    python3-pygments \
    fontconfig \
    gnuplot \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Arbeitsverzeichnis im Container
WORKDIR /workspace

# Standard-Befehl: Versuche 'make' auszuführen, falls vorhanden.
# Falls kein Makefile existiert, geben wir eine Hilfe aus.
CMD ["/bin/bash", "-c", "if [ -f Makefile ]; then make; else echo 'Kein Makefile gefunden. Nutzen Sie latex-cli zur Erstellung.'; fi"]

#!/usr/bin/env bash
# Rebuild the mock-up figures and placeholder logos from figures_src/.
# Only needed if you edit those sources; the PDFs are committed.
# In a real thesis, figures come from your own code repositories and only
# the rendered PDFs are copied into ch#/figures/ (or appendix/img/).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

build() { lualatex -interaction=nonstopmode -halt-on-error -output-directory="$TMP" "$ROOT/figures_src/$1.tex" >/dev/null; }

build mock_single;   cp "$TMP/mock_single.pdf"   "$ROOT/ch1/figures/mock_single.pdf"
build mock_panels;   cp "$TMP/mock_panels.pdf"   "$ROOT/ch2/figures/mock_panels.pdf"
build mock_appendix; cp "$TMP/mock_appendix.pdf" "$ROOT/appendix/img/mock_appendix.pdf"

# logos.tex has one page per logo; split it into separate files.
build logos
for page_name in 1:university_logo 2:institutions 3:funding; do
    page="${page_name%%:*}"; name="${page_name#*:}"
    if command -v qpdf >/dev/null; then
        qpdf "$TMP/logos.pdf" --pages . "$page" -- "$ROOT/frontmatter/img/$name.pdf"
    else
        # Fallback: pdfjam/pdfseparate are not always present; use lualatex.
        printf '\\documentclass{article}\\usepackage{pdfpages}\\begin{document}\\includepdf[pages=%s,fitpaper]{%s}\\end{document}\n' \
            "$page" "$TMP/logos.pdf" > "$TMP/split_$name.tex"
        lualatex -interaction=nonstopmode -output-directory="$TMP" "$TMP/split_$name.tex" >/dev/null
        cp "$TMP/split_$name.pdf" "$ROOT/frontmatter/img/$name.pdf"
    fi
done
echo "Mock figures and logos rebuilt."

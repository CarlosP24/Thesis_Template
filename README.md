# PhD Thesis Template

A LaTeX template for a PhD thesis, extracted from the thesis of Carlos Payá
(Universidad Autónoma de Madrid / ICMM-CSIC, 2026). It keeps that thesis's
complete format: preamble, cover pages, front and back matter, chapter and
appendix layout, and the split bibliography. The content is replaced by
`\lipsum` mock text, mock figures and a mock bibliography. Each file shows
one of the text elements the thesis uses, so you can copy the pattern you
need from it.

`main.pdf` is the compiled template, included as a preview.

## Credits

This template is a modification of two earlier ones:

- **[Fantastic PhD Thesis Template](https://github.com/maiani/fantastic_template)**
  by Andrea Maiani: the `memoir`-based structure, the modular preamble and
  the `subfiles` layout. It is licensed under
  [CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/), and so
  is this derivative (see [LICENSE](LICENSE)).
- **TU Delft dissertation template** (`dissertation.cls`): the chapter
  opening page (epigraph, then the chapter abstract at the foot), the running
  heads with the page number at the outer edge, the two-column imprint page,
  and the conclusions organized by research question.

The cover pages follow the element order of the UAM Escuela de Doctorado
template. The closing disclaimer in `main.tex` credits both templates in the
printed thesis. Keep it.

## Requirements

- A recent TeX Live distribution (developed on TeX Live 2025) with `latexmk`, **LuaLaTeX**,
  `biber` and `makeglossaries`.
- The `fourier-otf` (Erewhon/Utopia), `roboto` and GFS Artemisia fonts,
  all of which ship with TeX Live.
- Python 3, used by `scripts/prepare_publication_bibs.py` with the
  standard library only.

## Building

```bash
latexmk main.tex           # full thesis
latexmk ch2/ch2.tex        # any chapter, appendix or frontmatter file alone
latexmk -c                 # clean auxiliary files
```

`.latexmkrc` takes care of the details:

- It forces LuaLaTeX (`$pdf_mode = 4`), which `fourier-otf` needs.
- It runs `biber` and `makeglossaries` as needed.
- Before every build it runs `scripts/prepare_publication_bibs.py`, which
  regenerates `generated/*.bib` from `publications.bib` and
  `publications_not.bib`. `generated/` is gitignored, so never edit it.
- It writes the auxiliary files to `~/.cache/thesis-template-latex-aux/`,
  outside the source tree. Cloud-synced folders such as Nextcloud and
  Dropbox can break biber's atomic writes. Only the PDF is written next to
  the source. Rename that directory if you keep several theses with the
  same file names.

## Project structure

```
main.tex                  Root document: assembles everything with \subfile
preamble/                 Modular preamble (shared by every standalone build)
  packages.tex              Core packages, babel languages, glossaries setup
  colors.tex                Accent and link colours
  fonts.tex                 Fonts and cover-page faces
  math.tex                  Math packages and macros (\transm, \swave, ...)
  layout.tex                Page geometry, chapter style, running heads
  environments.tex          chquote, chabstract, disclaimer, appdisclaimer,
                            \subsectionclose, \sectionclose, \chapterclose
  bibliography.tex          biblatex setup, source maps, custom drivers
  metadata.tex              Title, author, committee... (single source of truth)
  hyperref.tex              Hyperlinks (loaded last)
  acronyms.tex              Acronym definitions
frontmatter/              Half title, dedication, title + imprint page,
                          abstract (+ translation), acknowledgments,
                          list of abbreviations, preface
  img/                      Placeholder logos (replace them)
    original/                 Logos of the original thesis (UAM, EDUAM, CSIC,
                              ICMM, funding, University of Copenhagen, QDev, ...)
ch1/ ch2/ ch3/            Chapters, each with its own figures/ folder
appendix/                 Appendices, figures in img/
backmatter/               Integrity statement, closing epigraph (colophon)
publications.bib          Your papers that are part of the thesis    -> P1, P2, ...
publications_not.bib      Your other papers during the PhD           -> N1, N2, ...
bibliography.bib          General literature                         -> 1, 2, ...
scripts/                  Bib preprocessing, mock-figure builder
figures_src/              Sources of the mock figures and logos (pgfplots)
```

## Getting started

1. Fill in `preamble/metadata.tex`: title, author, programme, institutions,
   advisors, committee, keywords and funding. The cover pages, the PDF
   metadata and the integrity statement all read from it.
2. Replace the three placeholder logos in `frontmatter/img/`
   (`university_logo.pdf`, `institutions.pdf`, `funding.pdf`). Keep the file
   names, or update `frontmatter/title_page.tex`. Tune the funding-logo
   height factor there to your logos. The logos of the original thesis
   are kept in `frontmatter/img/original/`, unused by the example. For a
   UAM / ICMM-CSIC thesis, point the title page at
   `img/original/UAM+EDUAM.pdf` (title page) and
   `img/original/UAM+EDUAM+CSIC+ICMM.pdf` plus `img/original/funding.pdf`
   (imprint page), as the commented lines in `title_page.tex` show.
3. Put your name in `\ifthesisauthorname` in `preamble/bibliography.tex`,
   with every spelling your `.bib` files use. That name is set in bold in
   every bibliography entry.
4. Set your colours in `preamble/colors.tex`. `accent_red` is the chapter
   numeral, and the `_d` variants are the link colours.
5. Replace the mock `.bib` files and the `\lipsum` text.
6. Add or remove chapters in `main.tex` (see "Adding a chapter" below).

## Where each element is shown

| Element | Example in |
| --- | --- |
| Half title, dedication | `frontmatter/half_title.tex`, `frontmatter/dedication.tex` |
| Title page and imprint page (advisors, committee, keywords, licence) | `frontmatter/title_page.tex` |
| Abstract with its translation (`otherlanguage`) | `frontmatter/abstract.tex` |
| Bilingual chapter title in the ToC | `frontmatter/acknowledgments.tex` |
| List of abbreviations (two columns) | `frontmatter/abbreviations.tex` |
| Preface: epigraph, thesis outline, publication lists, author contributions, code and data table | `frontmatter/preface.tex` |
| Chapter opening: epigraph (`chquote`), chapter abstract (`chabstract`) | `ch1/ch1.tex` |
| Sections down to `\subsubsection`, titled `\paragraph`s and `\subparagraph`s | `ch1/ch1.tex` |
| `\subsectionclose` (\*) and `\sectionclose` (\*\*) | `ch1/ch1.tex`, `ch2/ch2.tex` |
| Equations: `equation`, `split`, `align`, `physics` bra-kets | `ch1/ch1.tex` |
| Single-panel figure, footnotes | `ch1/ch1.tex` |
| (Sub)section adapted from a paper: footnote on its title | `ch1/ch1.tex` |
| Whole chapter adapted from papers: `disclaimer` | `ch2/ch2.tex` |
| Multi-panel figure, booktabs table, `siunitx` | `ch2/ch2.tex` |
| Every citation type: P, N, plain, erratum, preprint, book, chapter, proceedings, code package | `ch2/ch2.tex`, `frontmatter/preface.tex` |
| Closing "Summary: ..." section | `ch2/ch2.tex` |
| Conclusions by question and Outlook, then a translated unnumbered chapter (`\markboth`, `\markright`) | `ch3/ch3.tex` |
| Plain appendix | `appendix/appendix_A.tex` |
| Appendix adapted from a paper (`appdisclaimer`), figure in an appendix | `appendix/appendix_B.tex` |
| Integrity and AI-use statement, closing epigraph | `backmatter/` |
| Split bibliography (P / N / references / code packages) | `main.tex` |

## Conventions

These are the conventions the original thesis followed. The template shows
each of them.

### Files and compilation

- Every chapter, appendix and front-matter file starts with
  `\documentclass[../main]{subfiles}` and must keep compiling on its own.
  Never remove that header, or the closing
  `\ifSubfilesClassLoaded{...\printbibliography}{}` guard that prints a
  standalone bibliography.
- A chapter compiled alone sets its own counter, for example
  `\ifSubfilesClassLoaded{\setcounter{chapter}{1}}{}` in Chapter 2. An
  appendix uses `\ifSubfilesClassLoaded{\appendix\setcounter{chapter}{1}}{}`.
  Cross-chapter references show as `??` in a standalone build. That is
  expected.
- New macros and environments go in `preamble/`, never inside a chapter,
  because the other chapters would not see them when compiled alone.

### Writing

- **One sentence per source line.** LaTeX ignores single line breaks, so
  this costs nothing in the PDF, and `git diff` stays scoped to the sentence
  you edited. Inside `\footnote{...}`, use single newlines only. A blank
  line there breaks compilation.
- Tie references to their noun with a non-breaking space: `Fig.~\ref{fig:..}`,
  `Eq.~\eqref{eq:..}`, `Section~\ref{sec:..}`, `Chapter~\ref{ch:..}`,
  `Appendix~\ref{app:..}`, `Ref.~\cite{..}`. Labels carry the matching prefix.
- Keys inside one `\cite{}` go oldest first. `sortcites` then orders the
  printed labels as [P1, N2, 5].

### Chapter structure

- A chapter opens with `\chapter{}` and `\label{ch:...}`, then an epigraph
  in `chquote` (wrapped in `otherlanguage` when it is not in English), then
  a two- or three-sentence `chabstract`. A `disclaimer` follows if the
  chapter reuses published papers. Then `\clearpage`, and the body starts
  overleaf.
- Title `\paragraph`s only when a subsection has three or more subtopics of
  real length. Otherwise leave its paragraphs untitled.
- A paragraph that sums up a whole subsection, across its `\paragraph`s,
  follows `\subsectionclose` (one asterisk) instead of getting a heading. A
  paragraph that sums up a section, across its subsections, follows
  `\sectionclose` (two asterisks).
- Results chapters end with a section titled "Summary: ...".
- Material reused from your own papers is attributed once. A whole
  chapter gets `disclaimer`. A whole appendix gets `appdisclaimer`, right
  after its `\label`. A single (sub)section gets a footnote on its title.

### Figures and tables

- Figures are produced elsewhere (your code repositories). Only the PDF is
  copied into `chN/figures/` or `appendix/img/`, at its final size.
  `\includegraphics` takes no width. The text width is 141 mm.
- A figure goes after the heading of the first (sub)section that refers to
  it, never before it, and preferably after its first `Fig.~\ref`.
- Captions open with a **bold one-line summary**, then describe the panels
  `(a)`, `(b)`, ... in plain text. Give `\caption` a short optional title
  for the List of Figures.
- Tables use `booktabs`, with the caption above the table.

### Acronyms

- Define them in `preamble/acronyms.tex` with
  `\newacronym{key}{SHORT}{long form}`. They all appear in the List of
  Abbreviations, and every in-text acronym links to it.
- Within each chapter, body text and figure captions are expanded
  independently, since a caption is read out of order. Use `\acrfull` at
  the first occurrence in the body text and again at the first occurrence
  in a caption, and `\acrshort` everywhere else. Plurals take `...pl`.
- An acronym used only once in a context (body or captions) is
  `\acrlong`.
- In headings, `\section` and `\subsection` titles use `\acrlong`, and
  `\paragraph` titles use `\acrshort`. Headings and the `chabstract` do not
  count as occurrences.
- In a translated section, write the long form by hand in that language
  and keep the English short form: "(\acrshort{abs}, por sus siglas en
  inglés)".

### Bibliography

- `bibliography.bib` holds the general literature. It is best exported
  automatically from a reference manager (Zotero with Better BibTeX
  auto-export) and never hand-edited. Citekeys follow
  `Author:JournalAbbrevYY` (`Smith:PRL20`, `Lee:a23` for arXiv).
- `publications.bib` and `publications_not.bib` hold your own papers. They
  print in full, oldest first, with P and N labels, in the preface and at
  the head of the bibliography chapter. The thesis author is set in bold.
- Author markers go in the `keywords` field: `2=first` puts a \* after
  author 2 (first theory author), and `2=cofirst,3=cofirst` puts a † after
  authors 2 and 3. Co-first authors are never truncated into "et al.".
- An erratum is attached to its paper with a `related` source map in
  `preamble/bibliography.tex` (see `Smith:PRL20`). Cite only the paper.
- Code packages are moved into their own "Code Packages" list (C1, C2,
  ...) by citekey, with their repository address. See the
  `Doe:26a|Smith:26` maps.
- Short journal names live in two places in `preamble/bibliography.tex`:
  the source map and `\bibjournaltitle`. Keep them in sync when you add a
  journal.

### Math

- `\ket{}`, `\bra{}`, `\braket{}`, `\mel{}` from the `physics` package.
- No thin spaces `\,` in math, except next to an integral differential
  (`\int dr\,r`, `\int d\omega\, f(\omega)`).

## Adding a chapter

1. Copy `ch2/` to `ch4/`, rename `ch2.tex` to `ch4.tex`, and change its
   `\label`, its standalone `\setcounter{chapter}{3}` and its content.
2. Add `\subfile{ch4/ch4}` to `main.tex` in the right place.
3. Put its figures in `ch4/figures/`.

## Mock figures

The figures in `ch1/figures/`, `ch2/figures/` and `appendix/img/`, and the
placeholder logos, are built from `figures_src/` by

```bash
bash scripts/make_mock_figures.sh
```

You only need this if you edit those sources. Delete `figures_src/` and the
script once your own figures are in place.

## License

CC BY-NC 4.0, inherited from the Fantastic PhD Thesis Template. See
[LICENSE](LICENSE).

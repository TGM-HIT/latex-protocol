# A Latex Protocol Template

- [Usage](#usage)
	- [Make](#make)
	- [PdfLatex](#pdflatex)
	- [TexStudio](#texstudio)
- [Options](#options)
- [Variables](#variables)

## Usage
### Make
If the command is available simply run
```sh
make
```
and all `.tex` files which do not start with `glo`, `lst` or `_` will be compiled for both glossaries and bibliography.

### PdfLatex
When `make` is not available you can also run
```sh
pdflatex -interaction=nonstopmode -shell-escape protocol	# Initial compilation
makeglossaries protocol 					# Compile glossaries
pdflatex -interaction=nonstopmode -shell-escape protocol	# Progressive compilation for glossaries
bibtex protocol 						# Compile bibliography
pdflatex -interaction=nonstopmode -shell-escape protocol	# Progressive compilation for bibtex
pdflatex -interaction=nonstopmode -shell-escape protocol	# Progressive compilation for bibtex
```
to fully compile the `protocol.tex` file provided by default.

### TexStudio
If using TexStudio you might want to add a custom user command in `Options` &rarr; `Configure TexStudio` &rarr; `Build` &rarr; `User Commands`. Add the following line to completely compile a LaTeX file with glossaries, bibliography and also minted.
```sh
pdflatex -shell-escape -interaction=nonstopmode % | txs:///makeglossaries | pdflatex -shell-escape -interaction=nonstopmode % | txs:///bibtex | pdflatex -shell-escape -interaction=nonstopmode % | pdflatex -shell-escape -interaction=nonstopmode % | txs:///view-pdf-internal --embedded
```

Of course you can also add `make` as a user command but you might want to set the variable `LOG=true` so TexStudio can find your logfile after cleanup.
```sh
make LOG=true | txs:///view-pdf-internal --embedded
```

## Options
Option | Result
------ | ------
`landscape` | Change the page format to landscape orientation
`minted` | Add and configure minted package
`natbib` | Change bibtex backend to natbib
`nobib` | Disable bibliography
`nofonts` | Change font to default
`noglo` | Disable acronyms and glossary
`nologos` | Disable logos on titlepage
`notitle` | Disable titlepage
`notoc` | Disable table of contents
`notable` | Disable table on titlepage

## Variables
Variables can be set as commands like
```tex
\myvariable{value}
```

Command | Content
------- | -------
`mysubtitle` | Subtitle of group
`mysubject` | Thematic group / subject
`mycourse` | Current course / class
`myteacher` | Current teacher
`myversion` | Current version of the document
`mybegin` | Start of documentation
`myfinish` | End of documentation

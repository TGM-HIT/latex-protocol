# A latex protocol template

- [Usage](#usage)
	- [Latex](#latex)
	- [TexStudio](#texstudio)
- [Options](#options)
- [Variables](#variables)

## Usage
It is recommended to clone the `latex-protocol` repository using
```sh
git clone git@github.com:tgm-hit/latex-protocol.git [directory]
cd [directory]
```
where [directory] is the folder you want to store the protocol in.

With python and latex installed you can easilily compile your project using the `make` script which simplifies the compilation progress, handles multiple source files and removes unnecessary files.
For most use-cases you only have to run
```sh
python make
```
which compiles the `main.tex` file using `pdflatex` while looking for bibliography and glossary entries.

### Latex
If (for some reason) you do not want to depend on the `make` script you can also use `pdflatex`, `makeglossaries` and `bibtex` from the shell.
```sh
pdflatex -interaction=nonstopmode -shell-escape protocol	# Initial compilation
makeglossaries protocol 					# Compile glossaries
pdflatex -interaction=nonstopmode -shell-escape protocol	# Progressive compilation for glossaries
bibtex protocol 						# Compile bibliography
pdflatex -interaction=nonstopmode -shell-escape protocol	# Progressive compilation for bibtex
pdflatex -interaction=nonstopmode -shell-escape protocol	# Progressive compilation for bibtex
```

### TexStudio
If using TexStudio you might want to add a custom user command in `Options` &rarr; `Configure TexStudio` &rarr; `Build` &rarr; `User Commands`. Add the following line to completely compile a LaTeX file with glossaries, bibliography and also minted.
```sh
pdflatex -shell-escape -interaction=nonstopmode % | txs:///makeglossaries | pdflatex -shell-escape -interaction=nonstopmode % | txs:///bibtex | pdflatex -shell-escape -interaction=nonstopmode % | pdflatex -shell-escape -interaction=nonstopmode % | txs:///view-pdf-internal --embedded
```

Of course you can also add the `make` script as a user command but you might want to set the variable `-l` so TexStudio can find your logfile after cleanup.
```sh
python make -l | txs:///view-pdf-internal --embedded
```

### ShareLaTex
[ShareLaTex](https://www.sharelatex.com/project) is a popular online latex editor and is also fully supported by this template.

![ShareLaTex usage](https://media.giphy.com/media/DNwRWMqKcwnE92liHn/giphy.gif)

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
`parskip` | Skip line instead of indent after blank line

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

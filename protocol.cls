\ProvidesClass{protocol}

% # Options
% ## Use landscape orientation
\newif\iflandscape\landscapefalse
\DeclareOption{landscape}{\landscapetrue\PassOptionsToClass{landscape}{article}}

% ## Do not print title page
\newif\iftitle\titletrue
\DeclareOption{notitle}{\titlefalse}

% ## Do not print table of contents
\newif\iftoc\toctrue
\DeclareOption{notoc}{\tocfalse}

% ## Do not print table of contents
\newif\iftable\tabletrue
\DeclareOption{notable}{\tablefalse}

% ## Do not print logos
\newif\iflogos\logostrue
\DeclareOption{nologos}{\logosfalse}

% ## Use default latex fonts
\newif\iffonts\fontstrue
\DeclareOption{nofonts}{\fontsfalse}

% ## Do not except glossaries
\newif\ifglo\glotrue
\DeclareOption{noglo}{\glofalse}

% ## Do not except bibliography
\newif\ifbib\bibtrue
\DeclareOption{nobib}{\bibfalse}

% ## Use minted package
\newif\ifminted\mintedfalse
\DeclareOption{minted}{\mintedtrue}

% ## Use natbib package
\newif\ifnatbib\natbibfalse
\DeclareOption{natbib}{\bibtrue\natbibtrue}

% # Pass options
% \DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions \relax
% ## Load article class
\IfFileExists{crimson.sty}{
    \LoadClass[a4paper,11pt]{article}   % Crimson
}{  \LoadClass[a4paper,10pt]{article}}  % Default

% # Packages
% ## Require landscape geometry
\iflandscape\RequirePackage[landscape,margin=1in]{geometry}
\else\RequirePackage{a4wide}\fi

% ## Fonts
\iffonts
    \IfFileExists{crimson.sty}{\RequirePackage{crimson}}{}
    \IfFileExists{crimson.sty}{\RequirePackage{inconsolata}}{}
\fi

\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage[ngerman]{babel}
\RequirePackage{ccicons, amssymb, mathtools}

\RequirePackage{fancyhdr, float, multicol, multirow, titling}
\RequirePackage[marginal, norule, perpage]{footmisc}
\RequirePackage[dvipsnames]{xcolor}
\RequirePackage{hyperref, url, pageslts}
\RequirePackage{outlines, enumitem}
\RequirePackage{booktabs, tabularx}
\RequirePackage{graphicx, subcaption}
\RequirePackage[font=small]{caption}
\RequirePackage{accsupp}    % [1]

% ## Count list items for lists
\RequirePackage[figure,table,listing]{totalcount}

% ## Glossaries
\ifglo\RequirePackage[acronym, xindy, toc, nohypertypes={acronym,notation}]{glossaries}\fi

% ## Bibliography
\ifbib  \ifnatbib\RequirePackage{natbib}    % Choose backend
        \else\RequirePackage[backend=bibtex]{biblatex}\fi\fi

% ## Colors
\definecolor{MyLightGray}{RGB}{252,252,252}
\definecolor{MyBlue}{RGB}{33,74,135}
\definecolor{MyGreen}{RGB}{79,153,5}
\definecolor{MyBrown}{RGB}{143,89,3}
\definecolor{MyOrange}{RGB}{213,111,30}

% ## Require and configure minted or listings
\ifminted
    \RequirePackage[newfloat]{minted}
    \floatplacement{listing}{H} % Override default listing float
    \usemintedstyle{tango}      % autumn, rainbow_dash, tango, trac
    \setminted{ fontsize=\small,
                linenos=true,
                breakanywhere=true,
                breaklines=true,
                framesep=2mm,
                tabsize=4}

    % ## [1] Avoid copying line numbers on listings
    \renewcommand\theFancyVerbLine{
        \BeginAccSupp{method=escape,ActualText={}}
        {\rmfamily\tiny\arabic{FancyVerbLine}}
        \EndAccSupp{}
    }
    \SetupFloatingEnvironment{listing}{listname=Auflistungsverzeichnis,name=Auflistung}
\else
    \RequirePackage{listing}                % Already defined by minted itself
    \RequirePackage{listings}
    \RequirePackage{listingsutf8}           % UTF-8 Input support for listings
    \IfFileExists{.lst.tex}{\input{.lst}}{} % Load lstlistings config if exists
\fi

\RequirePackage{csquotes}	% csquotes should be loaded after fvextra, to avoid a warning from the lineno package

% # Variables
\newcommand\@mysubtitle{}   % Untertitel
\newcommand\mysubtitle[1]{\renewcommand\@mysubtitle{#1}}

\newcommand\@mysubject{}    % Systemtechnik Labor
\newcommand\mysubject[1]{\renewcommand\@mysubject{#1}}

\newcommand\@mycourse{}     % 5xHIT 2017/18, Gruppe A
\newcommand\mycourse[1]{\renewcommand\@mycourse{#1}}

\newcommand\@myteacher{}    % Michel Borko
\newcommand\myteacher[1]{\renewcommand\@myteacher{#1}}

\newcommand\@myversion{}    % 1.0
\newcommand\myversion[1]{\renewcommand\@myversion{#1}}

\newcommand\@mybegin{}      % 31.1.2018
\newcommand\mybegin[1]{\renewcommand\@mybegin{#1}}

\newcommand\@myfinish{}     % 1.2.2018
\newcommand\myfinish[1]{\renewcommand\@myfinish{#1}}

% # Package configuration
\newcolumntype{Y}{p{.5\textwidth}}  % TabularX

\floatplacement{table}{H}   % Override default table float
\floatplacement{figure}{H}  % Override default figure float

\hypersetup{breaklinks=true, colorlinks=true,   % Hyperlinks
            linkcolor=MyBlue, urlcolor=MyBlue, citecolor=MyBlue}

% ## Footnotes
\def\arraystretch{1.5}
\renewcommand\thefootnote{\Roman{footnote}}

% ## Header
\pagestyle{fancy}\fancyhf{}

\makeatletter
\fancyhead[L]{\small \thetitle}
\fancyhead[C]{\small \@mysubject}
\fancyhead[R]{\small \@date}
\fancyfoot[L]{\small \theauthor ~ {\footnotesize\ccby}}
\fancyfoot[C]{\small \@mycourse}
\fancyfoot[R]{\small \thepage~/~{\lastpageref*{VeryLastPage}}}
\makeatother

\renewcommand{\footrulewidth}{\headrulewidth}


% ## Add glossary / bibliography entries if they exist
\IfFileExists{glossaries.tex}{\input{glossaries}\makeglossaries}{}
\IfFileExists{bibliography.bib}{\addbibresource{bibliography}}{}

% # Makros
% ## Title
\makeatletter
\renewcommand\@maketitle{
    \iflogos~\\              % Print logos
        \IfFileExists{images/tgm-logo.png}
            {\includegraphics[height=2cm]{images/tgm-logo.png}}{}\hfill
        \IfFileExists{images/hit-logo.png}
            {\includegraphics[height=2cm]{images/hit-logo.png}}{}\fi

    \vskip 1cm              % Minimum margin
    \iflandscape\else       % Do not increase margin on landscape
        \iftable\vskip 3cm  % + table margin
        \else\vskip 1cm\fi  % + default margin
    \fi
    % Content
    \begin{center}
        \if\relax\@mysubject\relax\else     {\Large\@mysubject}     ~\\\vspace{0.5em}\fi
        \if\relax\@mycourse\relax\else      \@mycourse              ~\\\vspace{2em}\fi
        {\Huge\textbf\thetitle}                                     ~\\\vspace{1em}
        \if\relax\@mysubtitle\relax\else    {\LARGE\@mysubtitle}    ~\\\vspace{2em}\fi
        \theauthor                                                  ~\\\vspace{0.5em}
        \@date
    \end{center}
    \vskip 1cm  % Minimum margin
}\makeatother

% ## Table after titlepage
\makeatletter
\newcommand\maketable{
    \vfill~\\
    \begin{minipage}[t]{0.3\textwidth}
        Bewertung:\hfill\vspace{0.5em}\\
        Betreuer:\hfill\@myteacher
    \end{minipage}
    \hfill
    \begin{minipage}[t]{0.3\textwidth}
        \if\relax\@myversion\relax\else Version:\hfill\@myversion   \vspace{0.5em}\\\fi
        \if\relax\@mybegin\relax\else   Begonnen:\hfill\@mybegin    \vspace{0.5em}\\\fi
        \if\relax\@myfinish\relax\else  Beendet:\hfill\@myfinish    \fi
    \end{minipage}
    \newpage
}\makeatother

% ## Basic centered figure
% \makefig{path}{width}{caption}{label}
\newcommand\makefig[4]{
    \begin{figure}[H]
        \centering
        \includegraphics[#2]{#1}
        \ifx\relax#3\relax
        \else\caption{#3}\fi
        \ifx\relax#4\relax
        \else\label{#4}\fi
    \end{figure}
}

% ## Math variable declaration
\newenvironment{vardef}{
	\center \small
	\begin{tabular}{l l l}
}{\end{tabular} \normalsize \endcenter}
\newcommand\addvardef[2]{
    {#1} & \dots & {#2}\\
}


% ## Code environments
% Extra % is used as a linefix for the code interpreter
\ifminted   % Minted goes here
    \newcommand\setcode[1]{\setminted{#1}}  % Code settings
    \newenvironment{code}[2][]{             % Code environment
        \VerbatimEnvironment%
        \begin{minted}[#1]{#2}%
    }{  \end{minted}}

    \newcommand\codein{\mintinline}                         % Inline code (alias)
    \newcommand\inputcode{\inputminted}                     % Input code (alias)

    \newcommand\codeline[3][]{\mint[#1]{#2}\relax#3\relax}  % Single line of code
\else       % Listings goes here
    \newcommand\setcode[1]{\lstset{#1}}                         % Code settings
    \lstnewenvironment{code}[2][]{\lstset{language={#2},#1}}{}  % Code environment

    \newcommand\codein[3][]{\lstinline[language=#2,#1]\relax#3\relax}               % Inline code
    \newcommand\inputcode[3][]{\lstinputlisting[language=#2,#1]{\detokenize{#3}}}   % Input code

    \newcommand\codeline[3][]{\begin{flushleft}
        \lstinline[language=#2,#1]\relax#3\relax            % Single line of code
    \end{flushleft}}
\fi

% ## Add common commands at the beginning of the document
\AtBeginDocument{
    \pagenumbering{arabic}                      % Required by pageslts
    \iftitle\maketitle\thispagestyle{empty}\fi  % Titlepage
    \iftable\maketable\fi                       % Version table
    \iftoc\tableofcontents\glsresetall\fi       % Table of contents
}

% ## Add common commands at the end of the document
\AtEndDocument{
    \ifglo  % Print glossaries
        % \glsaddall                % Also list unused glossary entries
        \printglossaries\fi         % List used glossary entries

    \ifbib  % Print bibliography
        \ifnatbib\bibliography{bib} % List bibliography entries with natbib
        \else\printbibliography[heading=bibintoc, title={Literaturverzeichnis}]\fi\fi
    % List lists if not empty
    \iftotalfigures\listoffigures\fi
    \iftotaltables\listoftables\fi
    \iftotallistings\listoflistings\fi
}

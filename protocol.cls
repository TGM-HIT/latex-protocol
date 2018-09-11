% ==================== %
% :: LaTeX Protocol :: %
% ==================== %

% LaTeX class for protocols designed for the HIT department at TGM Vienna.
% Thanks to @chro and @mborko for the previous templates and support!
%
% @author   Markus Reichl <markus@re1.at> 
% @version  2018-09-10
% @url      https://github.com/tgm-hit/latex-protocol


\ProvidesClass{protocol}
% ------------- %
% :: Options :: %
% ------------- %
\newif\ifen\enfalse             	% English language
\DeclareOption{en}{\entrue}
\newif\iflandscape\landscapefalse	% Landscape orientation
\DeclareOption{landscape}{\landscapetrue\PassOptionsToClass{landscape}{article}}
\newif\ifminted\mintedfalse			% Minted for code listings
\DeclareOption{minted}{\mintedtrue}
\newif\ifnatbib\natbibfalse			% NatBib as bibliography backend
\DeclareOption{natbib}{\bibtrue\natbibtrue}
\newif\ifbib\bibtrue                % Do not except bibliography
\DeclareOption{nobib}{\bibfalse}
\newif\ifcolor\colortrue            % No coloured links
\DeclareOption{nocolor}{\colorfalse}
\newif\iffonts\fontstrue            % No additional fonts
\DeclareOption{nofonts}{\fontsfalse}
\newif\ifglo\glotrue                % Do not except glossaries
\DeclareOption{noglo}{\glofalse}
\newif\iflogos\logostrue            % No logos
\DeclareOption{nologos}{\logosfalse}
\newif\iftable\tabletrue            % No information table on page bottom
\DeclareOption{notable}{\tablefalse}
\newif\iftitle\titletrue            % No title page
\DeclareOption{notitle}{\titlefalse}
\newif\iftoc\toctrue                % No table of contents
\DeclareOption{notoc}{\tocfalse}
\newif\ifparskip\parskipfalse       % Skip a line instead of indenting after blank line
\DeclareOption{parskip}{\parskiptrue}
\newif\ifsans\sansfalse          	% Sans-serif fonts
\DeclareOption{sans}{\sanstrue}
% Pass options
\ProcessOptions\relax
% Load article class
\IfFileExists{crimson.sty}{
    \iffonts\LoadClass[a4paper,11pt]{article}   % Crimson
    \else\LoadClass[a4paper, 10pt]{article}\fi  % Default
}{  \LoadClass[a4paper,10pt]{article}}          % Default


% -------------- %
% :: Packages :: %
% -------------- %
\iffonts	% Load correct fonts when available
	\ifsans	\renewcommand*\familydefault{\sfdefault}
	\else	\IfFileExists{crimson.sty}{\RequirePackage{crimson}}{}\fi
    \IfFileExists{inconsolata.sty}{\RequirePackage{inconsolata}}{}
\fi
% Require landscape geometry and use smaller margins
\iflandscape	\RequirePackage[landscape,margin=1in]{geometry}
\else			\RequirePackage{a4wide, geometry}\fi
% Make ccicons optional to support smaller TeX distrubtions
\newif\ifccicons\cciconstrue
\IfFileExists{ccicons.sty}{\RequirePackage{ccicons}}{\cciconsfalse}
% Font settings, language support and symbols
\RequirePackage[T1]{fontenc}
\RequirePackage[utf8]{inputenc}
\RequirePackage{csquotes, amssymb, mathtools}
% Language
\ifen 	\RequirePackage[ngerman, english]{babel}
\else 	\RequirePackage[english, ngerman]{babel}\fi
% Additional content, commands and settings
\RequirePackage{fancyhdr, float, multicol, multirow, titling}
\RequirePackage[marginal, norule, perpage]{footmisc}
\RequirePackage[dvipsnames]{xcolor}
\RequirePackage{hyperref, url, pageslts}
\RequirePackage{outlines, enumitem}
\RequirePackage{booktabs, tabularx}
\RequirePackage{graphicx, subcaption}
\RequirePackage[font=small]{caption}
\RequirePackage{accsupp}    % [1]
% Count list items for lists
\RequirePackage[figure,table,listing]{totalcount}
% Skip lines instead of indents after a blank line
\ifparskip\RequirePackage{parskip}\fi

% Glossaries
\ifglo 	\RequirePackage[acronym, xindy, toc, nohypertypes={acronym,notation}]{glossaries}
		\makeglossaries\fi

\ifbib  \ifnatbib\RequirePackage{natbib}	% Bibliography
        \else\RequirePackage[backend=bibtex]{biblatex}\fi\fi

\ifminted\RequirePackage[newfloat]{minted}  % Code listings
\else\RequirePackage{listing}               % Already defined by minted itself
     \RequirePackage{listingsutf8}\fi       % UTF-8 Input support for listings


% --------------- %
% :: Variables :: %
% --------------- %
\newcommand\@mysubtitle{}	% Optional subtitle
\newcommand\mysubtitle[1]{\renewcommand\@mysubtitle{#1}}
\newcommand\@mysubject{}    % Subject, class or topic
\newcommand\mysubject[1]{\renewcommand\@mysubject{#1}}
\newcommand\@mycourse{}     % Course, group or team
\newcommand\mycourse[1]{\renewcommand\@mycourse{#1}}
\newcommand\@myteacher{}    % Supporting teacher or supervisor
\newcommand\myteacher[1]{\renewcommand\@myteacher{#1}}
\newcommand\@myversion{}    % Current version of the document (x.x or yy.mm.xx)
\newcommand\myversion[1]{\renewcommand\@myversion{#1}}
\newcommand\@mybegin{}      % Start of work or its documentation
\newcommand\mybegin[1]{\renewcommand\@mybegin{#1}}
\newcommand\@myfinish{}     % End of work or its documentation
\newcommand\myfinish[1]{\renewcommand\@myfinish{#1}}

% :: Colours :: %
% Colour scheme: https://coolors.co/7c564f-f25f5c-facc6b-93d6a4-247ba0
\definecolor{MyLightGray}{HTML}{fafafa}
\definecolor{MyBrown}{HTML}{a25e56}
\definecolor{MyRed}{HTML}{f25f5c}
\definecolor{MyOrange}{HTML}{facc6b}
\definecolor{MyGreen}{HTML}{93d6a4}
\definecolor{MyBlue}{HTML}{247ba0}

% ------------------- %
% :: Configuration :: %
% ------------------- %

% :: Listings :: %
\ifminted							% Configure minted
    \floatplacement{listing}{H} 	% Override default listing float
    \usemintedstyle{tango}			% autumn, rainbow_dash, tango, trac
    \setminted{ fontsize=\small,
                linenos=true,
                breakanywhere=true,
                breaklines=true,
                framesep=2mm,
                tabsize=4}
    % [1] Avoid copying line numbers on listings
    \renewcommand\theFancyVerbLine{
        \BeginAccSupp{method=escape,ActualText={}}
        {\rmfamily\tiny\arabic{FancyVerbLine}}
        \EndAccSupp{}
    }
    % Change listings for German users
    \ifen\else\SetupFloatingEnvironment{listing}{
    	listname=Auflistungsverzeichnis,name=Auflistung
    }\fi
\else\IfFileExists{.lst.tex}{\input{.lst}}{}\fi % Load listings config if exists

% :: Hyperlinks :: %
\ifcolor 	\hypersetup{breaklinks=true, colorlinks=true,   	% Recolour links
                    	linkcolor=MyBlue, urlcolor=MyBlue, citecolor=MyBlue}
\else 		\hypersetup{breaklinks=true, colorlinks=false,  	% Remove colours
                    	linkcolor=Black, urlcolor=Black, citecolor=Black}\fi

% :: Headers :: %
\pagestyle{fancy}\fancyhf{}

\makeatletter
\fancyhead[L]{\small \thetitle}
\fancyhead[C]{\small \@mysubject}
\fancyhead[R]{\small \@date}
\fancyfoot[L]{\small \theauthor~{\ifccicons\footnotesize\ccby\fi}}
\fancyfoot[C]{\small \@mycourse}
\fancyfoot[R]{\small \thepage~/~{\lastpageref*{VeryLastPage}}}
\makeatother
% Adjust foot rule width (cannot be set explicitly)
\renewcommand{\footrulewidth}{\headrulewidth}
% Add glossary / bibliography entries if they exist
\IfFileExists{glossaries.tex}{\input{glossaries}\makeglossaries}{}
\IfFileExists{bibliography.bib}{\addbibresource{bibliography}}{}

% :: Hacks :: %
\def\arraystretch{1.5}      				% Increase table cell spacing
\floatplacement{table}{H}   				% Adjust default table float
\floatplacement{figure}{H}  				% Adjust default figure float
\newcolumntype{Y}{p{.5\textwidth}}  		% Half page TabularX column
\renewcommand\thefootnote{\Roman{footnote}}	% Roman footnotes

% ------------ %
% :: Macros :: %
% ------------ %

% :: Title :: %
\makeatletter
\renewcommand\@maketitle{
    \iflogos~\\	% Line fix
    	\begin{minipage}{3.2cm}
	        \IfFileExists{images/logo-left.png}{
	            \includegraphics[width=3.2cm]{images/logo-left.png}}{}
    	\end{minipage}
    	\hfill
        \begin{minipage}{3.2cm}
	    	\IfFileExists{images/logo-right.png}{
	            \includegraphics[width=3.2cm]{images/logo-right.png}}{}
	    \end{minipage}
    	\vfill\fi 	% Fill space between title header and project logo and headings
    \begin{center}
        \if\relax\@mysubject\relax\else     {\Large\@mysubject}     ~\\\vspace{0.5em}\fi
        \if\relax\@mycourse\relax\else      \@mycourse              ~\\\vspace{2em}\fi
        {\Huge\textbf\thetitle}                                     ~\\\vspace{1em}
        \if\relax\@mysubtitle\relax\else    {\LARGE\@mysubtitle}\fi ~\\\vspace{2em}
        \theauthor                                                  ~\\\vspace{0.5em}
        \@date
    \end{center}
    \vfill	% Fill space between headings and the rest of the page
}\makeatother

% :: Information table after title :: %
\makeatletter
\newcommand\maketable{
	~\\
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

% :: Basic centered figure :: %
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

% :: Math variable declaration :: %
\newenvironment{vardef}{
	\center \small
	\begin{tabular}{l l l}
}{\end{tabular} \normalsize \endcenter}
\newcommand\addvardef[2]{
    {#1} & \dots & {#2}\\
}


% :: Code environments :: %
% Extra % is used as a linefix for the code interpreter
\ifminted   % Minted goes here
    \newcommand\setcode[1]{\setminted{#1}}  % Code settings
    \newenvironment{code}[2][]{             % Code environment
        \VerbatimEnvironment%
        \begin{minted}[#1]{#2}%
    }{  \end{minted}}

    \newcommand\codeinline{\mintinline}     % Inline code
    \newcommand\codein{\codeinline}     	% Shorter command
    \newcommand\inputcode{\inputminted}		% Input code
\else       % Listings goes here
    \newcommand\setcode[1]{\lstset{#1}}                         % Code settings
    \lstnewenvironment{code}[2][]{\lstset{language={#2},#1}}{}  % Code environment

    \newcommand\codeinline[3][]{\lstinline[language=#2,#1]\relax#3\relax}   % Inline code
    \newcommand\codein{\codeinline}                                     	% Shorter command
    \newcommand\inputcode[3][]{\lstinputlisting[language=#2,#1]{\detokenize{#3}}}   % Input code
\fi

% :: Begin Document :: %
% Add common commands at the beginning of the document
\AtBeginDocument{
    \pagenumbering{arabic}                      % Required by pageslts
    \iftitle 	\newgeometry{left=1.25in, right=1.25in, top=.75in, bottom=1.75in}
    			\maketitle\thispagestyle{empty} % Print title on a clean page
    			\iftable\maketable\fi           % Version table
    			\restoregeometry\fi 			% Restore geometry
    \iftoc\tableofcontents\glsresetall\fi       % Table of contents
}

% :: End Document :: %
% Add common commands at the end of the document
\AtEndDocument{
    \ifglo\printglossaries\fi 				% List used glossary entries
    \ifbib 	\ifnatbib\bibliography{bib} 	% List bibliography entries with NatBib
    \else 	\ifen\printbibliography[heading=bibintoc]
            \else\printbibliography[heading=bibintoc, title=Literaturverzeichnis]\fi\fi
    % List lists if not empty
    \iftotalfigures\listoffigures\fi
    \iftotaltables\listoftables\fi
    \iftotallistings\listoflistings\fi
}

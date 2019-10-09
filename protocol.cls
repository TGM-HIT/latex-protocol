% ==================== %
% :: LaTeX Protocol :: %
% ==================== %

% LaTeX class for protocols designed for the HIT department at TGM Vienna.
% Thanks to @chro and @mborko for the previous templates and support!
%
% @author   Markus Reichl <markus@re1.at>
% @version  2018-05-29
% @url      https://github.com/TGM-HIT/latex-protocol


\ProvidesClass{protocol}

% ------------- %
% :: Options :: %
% ------------- %
\DeclareOption{landscape}{          % Pass landscape option to article and re1
    \PassOptionsToClass{\CurrentOption}{article}
    \PassOptionsToPackage{\CurrentOption}{re1}}
\newif\iffonts\fontstrue            % No additional fonts
\DeclareOption{nofonts}{\fontsfalse}
\newif\iflogos\logostrue            % No logos
\DeclareOption{nologos}{\logosfalse}
\newif\iftable\tabletrue            % No information table on page bottom
\DeclareOption{notable}{\tablefalse}
% Pass additional options to re1
\DeclareOption*{\PassOptionsToPackage{\CurrentOption}{re1}}
\ProcessOptions\relax
% Load article class
\IfFileExists{crimson.sty}{
    \LoadClass[a4paper,11pt]{article}   % Crimson
}{  \LoadClass[a4paper,10pt]{article}}  % Default


% -------------- %
% :: Packages :: %
% -------------- %
\RequirePackage{tgm}

\iffonts	% Load correct fonts when available
	\ifsans	\renewcommand*\familydefault{\sfdefault}
	\else	\IfFileExists{crimson.sty}{\RequirePackage{crimson}}{}\fi
    \IfFileExists{FiraMono.sty}{\RequirePackage[scale=0.5]{FiraSans}}{}
\fi



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


% ------------------- %
% :: Configuration :: %
% ------------------- %

% :: Hyperlinks :: %
\ifcolor\hypersetup{breaklinks=true, colorlinks=true,   	% Recolor links
                    linkcolor=Base, urlcolor=Dark, citecolor=Base}\fi

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


% ------------ %
% :: Macros :: %
% ------------ %

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
    \iftable\maketable\fi   % Add information table
}\makeatother

% :: Begin Document :: %
% Add common commands at the beginning of the document
\AtBeginDocument{\thispagestyle{fancy}}     % Make table of contents fancy too


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LaTeX Templates Journal Article
% Custom "article" Class
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{customarticle}[2024/03/14 Custom Article Class]

\usepackage{etoolbox}
\usepackage{xcolor} % Required for custom colors

% Define Dark Gray Color
\definecolor{darkgray}{HTML}{333333}

\newtoggle{unnumberedsections}
\settoggle{unnumberedsections}{false}
\DeclareOption{unnumberedsections}{\settoggle{unnumberedsections}{true}}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\LoadClass[twocolumn]{article}

%----------------------------------------------------------------------------------------
%	REQUIRED PACKAGES AND MISC CONFIGURATIONS
%----------------------------------------------------------------------------------------

\usepackage{graphicx}
\graphicspath{{Figures/}{./}}

\usepackage[bottom, hang]{footmisc}
\setlength{\footnotemargin}{6pt}

%----------------------------------------------------------------------------------------
%	MARGINS
%----------------------------------------------------------------------------------------

\usepackage[
	top=2.5cm,
	bottom=2.5cm,
	left=2cm,
	right=2cm,
	footskip=1cm,
	headsep=0.75cm,
	columnsep=20pt,
]{geometry}

%----------------------------------------------------------------------------------------
%	FONTS
%----------------------------------------------------------------------------------------

\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[sc]{mathpazo}
\linespread{1.05}
\usepackage{microtype}

%----------------------------------------------------------------------------------------
%	HEADERS AND FOOTERS
%----------------------------------------------------------------------------------------

\usepackage{fancyhdr}
\pagestyle{fancy}
\renewcommand{\headrulewidth}{0pt}
\fancyhf{}

\fancyhead[RO]{\small\textit{\runninghead}}
\fancyhead[LE]{\small\textit{\runninghead}}
\fancyfoot[RO]{\small\textbf{\thepage}}
\fancyfoot[LO]{\footnotesize\footertext}
\fancyfoot[LE]{\small\textbf{\thepage}}
\fancyfoot[RE]{\footnotesize\footertext}

%----------------------------------------------------------------------------------------
%	SECTIONS (With Dark Gray Coloring)
%----------------------------------------------------------------------------------------

\usepackage{titlesec}

\iftoggle{unnumberedsections}{
	\setcounter{secnumdepth}{0}
}{
	\setcounter{secnumdepth}{2}
}

\titleformat
	{\section}
	[block]
	{\Large\bfseries\centering\color{darkgray}} % Applied darkgray
	{\thesection}
	{0.5em}
	{}
	[]

\titleformat
	{\subsection}
	[block]
	{\raggedright\large\bfseries\color{darkgray}} % Applied darkgray
	{\thesubsection}
	{0.5em}
	{}
	[]

\titleformat
	{\subsubsection}
	[runin]
	{\bfseries\color{darkgray}} % Applied darkgray
	{}
	{5pt}
	{}
	[]

\titlespacing*{\subsubsection}{0pt}{0.5\baselineskip}{8pt}

%----------------------------------------------------------------------------------------
%	TITLE SECTION (With Dark Gray Coloring)
%----------------------------------------------------------------------------------------

\usepackage{titling}

\setlength{\droptitle}{-4\baselineskip}

\pretitle{\begin{center}\huge\bfseries\color{darkgray}} % Applied darkgray
\posttitle{\end{center}}

\setlength{\thanksmarkwidth}{3pt}
\setlength{\thanksmargin}{-3pt}

\patchcmd{\maketitle}{plain}{empty}{}{}

%----------------------------------------------------------------------------------------
%	ABSTRACT CUSTOMIZATION (With Dark Gray Coloring)
%----------------------------------------------------------------------------------------

\usepackage{abstract}

\renewcommand{\abstractnamefont}{\normalfont\bfseries\vspace{0.5\baselineskip}\color{darkgray}} % Applied darkgray to "Abstract" label
\renewcommand{\abstracttextfont}{\vspace{-0.5\baselineskip}\normalfont\small\itshape\color{darkgray}} % Applied darkgray to Abstract text

%----------------------------------------------------------------------------------------
%	BIBLIOGRAPHY
%----------------------------------------------------------------------------------------

\usepackage[
	backend=biber,
	citestyle=numeric,
	bibstyle=numeric,
	sorting=none,
]{biblatex}

%----------------------------------------------------------------------------------------
%	TABLES
%----------------------------------------------------------------------------------------

\usepackage{booktabs}
\usepackage{array}

\newcolumntype{R}[1]{>{\raggedleft\arraybackslash}p{#1}}
\newcolumntype{L}[1]{>{\raggedright\arraybackslash}p{#1}}
\newcolumntype{C}[1]{>{\centering\arraybackslash}p{#1}}

%----------------------------------------------------------------------------------------
%	CAPTIONS
%----------------------------------------------------------------------------------------

\usepackage{caption}
\captionsetup{skip=6pt}
\captionsetup{labelfont={bf,small}, textfont={it,small}}

%----------------------------------------------------------------------------------------
%	LISTS
%----------------------------------------------------------------------------------------

\usepackage{enumitem}
\setlist{noitemsep}

%----------------------------------------------------------------------------------------
%	LINKS
%----------------------------------------------------------------------------------------

\usepackage{hyperref}
\hypersetup{
	colorlinks=true,
	urlcolor=black,
	linkcolor=black,
	citecolor=black,
}

%----------------------------------------------------------------------------------------
%	CUSTOM COMMANDS
%----------------------------------------------------------------------------------------

\newcommand{\runninghead}[1]{\renewcommand{\runninghead}{#1}}
\newcommand{\footertext}[1]{\renewcommand{\footertext}{1}}

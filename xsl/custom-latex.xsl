<?xml version="1.0" encoding="UTF-8"?>


<!-- This file is part of the book                 -->
<!--                                               -->
<!--   Discrete Mathematics: an Open Introduction  -->
<!--                                               -->
<!-- Copyright (C) 2015-2018 Oscar Levin           -->
<!-- See the file COPYING for copying conditions.  -->

<!-- Parts of this file were adapted from the author guide at https://github.com/rbeezer/mathbook and the analagous file at https://github.com/twjudson/aata -->

<!DOCTYPE xsl:stylesheet [
    <!ENTITY % entities SYSTEM "entities.ent">
    %entities;
]>
<!-- DMOI customizations for LaTeX runs -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Assumes current file is in discrete-text/xsl and that the mathbook repository is adjacent -->
<xsl:import href="../../../mathbook/xsl/mathbook-latex.xsl" />
<!-- Assumes next file can be found in discrete-text/xsl -->
<xsl:import href="custom-common.xsl" />





<!-- Parameters to pass via xsltproc "stringparam" on command-line            -->
<!-- Or make a thin customization layer and use 'select' to provide overrides -->
<!--  -->
<!-- LaTeX executable, "engine"                       -->
<!-- pdflatex is default, xelatex or lualatex for Unicode support -->
<!-- N.B. This has no effect, and may never.  xelatex and lualatex support is automatic -->
<xsl:param name="latex.engine" select="'pdflatex'" />
<!--  -->
<!-- Standard fontsizes: 10pt, 11pt, or 12pt       -->
<!-- extsizes package: 8pt, 9pt, 14pt, 17pt, 20pt  -->
<!-- memoir class offers more, but maybe other changes? -->
<xsl:param name="latex.font.size" select="'10pt'" />
<!--  -->
<!-- Geometry: page shape, margins, etc            -->
<!-- Pass a string with any of geometry's options  -->
<!-- Default is empty and thus ineffective         -->
<!-- Otherwise, happens early in preamble template -->
<xsl:param name="latex.geometry" select="'papersize={7in,10in}, width=4.85in, inner=1in, height=8.5in, top=0.75in, twoside, ignoreheadfoot'"/>
<!--  -->
<!-- PDF Watermarking                    -->
<!-- Non-empty string makes it happen    -->
<!-- Scale works well for "CONFIDENTIAL" -->
<!-- or  for "DRAFT YYYY/MM/DD"          -->
<xsl:param name="latex.watermark" select="''"/>
<xsl:param name="watermark.scale" select="2.0"/>
<!--  -->
<!-- Author's Tools                                            -->
<!-- Set the author-tools parameter to 'yes'                   -->
<!-- (Documented in mathbook-common.xsl)                       -->
<!-- Installs some LaTeX-specific behavior                     -->
<!-- (1) Index entries in margin of the page                   -->
<!--      where defined, on single pass (no real index)        -->
<!-- (2) LaTeX labels near definition and use                  -->
<!--     N.B. Some are author-defined; others are internal,    -->
<!--     and CANNOT be used as xml:id's (will raise a warning) -->
<!--  -->
<!-- Draft Copies                                              -->
<!-- Various options for working copies for authors            -->
<!-- (1) LaTeX's draft mode                                    -->
<!-- (2) Crop marks on letter paper, centered                  -->
<!--     presuming geometry sets smaller page size             -->
<!--     with paperheight, paperwidth                          -->
<xsl:param name="latex.draft" select="'no'"/>
<!--  -->
<!-- Print Option                                         -->
<!-- For a non-electronic copy, inactive links in black   -->
<!-- Any color options go to black and white, as possible -->
<xsl:param name="latex.print" select="'no'"/>
<!--  -->
<!-- Preamble insertions                    -->
<!-- Insert packages, options into preamble -->
<!-- early or late                          -->
<xsl:param name="latex.preamble.early" select="''" />
<!-- <xsl:param name="latex.preamble.late" select="''" /> -->
<!--  -->
<!-- Console characters allow customization of how    -->
<!-- LaTeX macros are recognized in the fancyvrb      -->
<!-- package's Verbatim clone environment, "console"  -->
<!-- The defaults are traditional LaTeX, we let any   -->
<!-- other specification make a document-wide default -->
<!-- <xsl:param name="latex.console.macro-char" select="'\'" />
<xsl:param name="latex.console.begin-char" select="'{'" />
<xsl:param name="latex.console.end-char" select="'}'" /> -->

<!-- We have to identify snippets of LaTeX from the server,   -->
<!-- which we have stored in a directory, because XSLT 1.0    -->
<!-- is unable/unwilling to figure out where the source file  -->
<!-- lives (paths are relative to the stylesheet).  When this -->
<!-- is needed a fatal message will warn if it is not set.    -->
<!-- Path ends with a slash, anticipating appended filename   -->
<!-- This could be overridden in a compatibility layer        -->
<xsl:param name="webwork.server.latex" select="''" />






<!-- List Chapters and Sections in Table of Contents -->
<xsl:param name="toc.level" select="'3'" />


<!-- An exercise has a statement, and may have hints,      -->
<!-- answers and solutions.  An answer is just the         -->
<!-- final number, expression, whatever; while a solution  -->
<!-- includes intermediate steps. Parameters here control  -->
<!-- the *visibility* of these four parts                  -->
<!--                                                       -->
<!-- Parameters are:                                       -->
<!--   'yes' - visible                                     -->
<!--   'no' - not visible                                  -->
<!--                                                       -->
<!-- Five categories:                                      -->
<!--   inline (checpoint) exercises                        -->
<!--   divisional (inside an "exercises" division)         -->
<!--   worksheet (inside a "worksheet" division)           -->
<!--   reading (inside a "reading-questions" division)     -->
<!--   project (on a project-like,                         -->
<!--   or possibly on a terminal "task" of a project-like) -->
<!--                                                       -->
<!-- Default is "yes" for every part, so experiment        -->
<!-- with parameters to make some parts hidden.            -->
<!--                                                       -->
<!-- These are global switches, so only need to be fed     -->
<!-- into the construction of exercises via the            -->
<!-- "exercise-components" template.                       -->
<!-- N.B. "statement" switches are necessary or desirable  -->
<!-- for alternate collections of solutions (only)         -->
<xsl:param name="exercise.inline.statement" select="''" />
<xsl:param name="exercise.inline.hint" select="''" />
<xsl:param name="exercise.inline.answer" select="'no'" />
<xsl:param name="exercise.inline.solution" select="'no'" />
<xsl:param name="exercise.divisional.statement" select="''" />
<xsl:param name="exercise.divisional.hint" select="''" />
<xsl:param name="exercise.divisional.answer" select="'no'" />
<xsl:param name="exercise.divisional.solution" select="'no'" />
<xsl:param name="exercise.worksheet.statement" select="''" />
<xsl:param name="exercise.worksheet.hint" select="''" />
<xsl:param name="exercise.worksheet.answer" select="''" />
<xsl:param name="exercise.worksheet.solution" select="''" />
<xsl:param name="exercise.reading.statement" select="''" />
<xsl:param name="exercise.reading.hint" select="''" />
<xsl:param name="exercise.reading.answer" select="''" />
<xsl:param name="exercise.reading.solution" select="''" />
<xsl:param name="project.statement" select="''" />
<xsl:param name="project.hint" select="'no'" />
<xsl:param name="project.answer" select="'no'" />
<xsl:param name="project.solution" select="'no'" />

<!-- Forward links to hints: -->
<xsl:param name="debug.exercises.forward" select="'yes'" />

<!-- Include a style file at the end of the preamble: -->

<xsl:param name="latex.preamble.late">
  <xsl:text>%This should load all the style information that mbx does not.&#xa;</xsl:text>
    <xsl:text>\input{latex-preamble-styles}&#xa;</xsl:text>
</xsl:param>



<!-- %%%%%%%%%%%%% -->
<!-- Title Styles: -->
<!-- %%%%%%%%%%%%% -->

<xsl:template name="titlesec-chapter-style">
    <xsl:text>\titleformat{\chapter}[display]
    	{\Large\filcenter\scshape\bfseries}
    	{\rule[4pt]{.3\textwidth}{2pt} \hspace{2ex} \large\textsc{\chaptertitlename} \thechapter \hspace{3ex} \rule[4pt]{0.3\textwidth}{2pt} }
    	{0.0em}
    	{\titlerule\vspace{1ex}\huge\textsc #1}
    	[\vspace{.75ex}\titlerule]
    \titlespacing*{\chapter}{0pt}{-2em}{2em}&#xa;</xsl:text>
    <!-- <xsl:text>\titleformat{name=\chapter,numberless}
      {\Large\filcenter\scshape\bfseries}
    	{\rule[4pt]{.3\textwidth}{2pt} \hspace{2ex} \large\textsc{\chaptertitlename} \thechapter \hspace{3ex} \rule[4pt]{0.3\textwidth}{2pt} }
    	{0.0em}
    	{\titlerule\vspace{1ex}\huge\textsc #1}
    	[\vspace{.75ex}\titlerule]
    \titlespacing*{\chapter}{0pt}{-2em}{2em}&#xa;</xsl:text> -->
    <xsl:text>\titleformat{\subparagraph}[block]
      {\normalfont\filcenter\scshape\bfseries}
      {\theparagraph}
      {1em}
      {#1}
      [\normalsize\authorsptx]&#xa;</xsl:text>
</xsl:template>

<xsl:template name="titlesec-section-style">
    <xsl:text>\titleformat{\section}
    {\Large\filcenter\scshape\bfseries}
    {\thesection}
    {1em}
    {#1}
    [\large\authorsptx]&#xa;</xsl:text>
    <xsl:text>\titleformat{name=\section,numberless}
    {\filcenter\scshape\bfseries}
    {}
    {0.0em}
    {#1}&#xa;</xsl:text>
</xsl:template>

<xsl:template name="titlesec-subsection-style">
    <xsl:text>\titleformat{\subsection}
    {\large\filcenter\scshape\bfseries}
    {\thesubsection}
    {1em}
    {#1}
    [\normalsize\authorsptx]&#xa;</xsl:text>
</xsl:template>

<xsl:template name="titlesec-subsubsection-style">
    <xsl:text>\titleformat{\subsubsection}
      {\filcenter\scshape\bfseries}
      {\thesubsubsection}
      {1em}
      {#1}
      [\normalsize\authorsptx]&#xa;</xsl:text>
</xsl:template>

<!-- %%%%%%%%%%%%%%%% -->
<!-- End Title Stiles -->
<!-- %%%%%%%%%%%%%%%% -->



<!-- %%%%%%%%%%%%%%%%%%%%%%%% -->
<!--  Header/Footer Stiles    -->
<!-- %%%%%%%%%%%%%%%%%%%%%%%% -->

<!-- LaTeX uses four page styles, and we use the "titleps" package  -->
<!-- to redefine the "empty", "plain", and "headings" styles.  The  -->
<!-- actual management of which style is used, and when, is         -->
<!-- controlled by LaTeX with help from PreTeXt.  You can use the   -->
<!-- "titleps-global-style" template to change which style is the   -->
<!-- global default, optionally in concert with redefinitions of    -->
<!-- the style.                                                     -->
<!--                                                                -->
<!-- We do limited demonstration with the head, and use the         -->
<!-- left-side of the foot to display information on which          -->
<!-- pagestyle is in effect, so you could experiment here before    -->
<!-- making your own style.                                         -->
<!--                                                                -->
<!-- Note: the templates will be placed after a "\renewpagestyle{}" -->
<!-- command, so should be an optional argument, followed by a      -->
<!-- mandatory argument with commands like \setfoot, \sethead,      -->
<!-- \headrule, and \footrule.                                      -->
<!-- See titleps.pdf in the "titlesec" package for more             -->
<xsl:template match="book|article|letter|memo" mode="titleps-empty">
</xsl:template>

<xsl:template match="book|article|letter|memo" mode="titleps-plain">
    <xsl:text>{
    \setfoot[][\thepage][]
    {}{\thepage}{}
    }</xsl:text>
</xsl:template>


<!-- general headings -->
<xsl:template match="book" mode="titleps-headings">
    <xsl:text>{
    \sethead[{\footnotesize \textbf{\thepage}}~~~ \textsc{\scriptsize{\ifthechapter{\thechapter.~}{}\chaptertitle}}][][]
    {}{}{\textsc{\scriptsize{\ifthesection{\thesection.~\sectiontitle}{\chaptertitle}}} ~~~ {\footnotesize \textbf{\thepage}} }
    \setfoot[][][]
    {}{}{}
    }</xsl:text>
</xsl:template>

<xsl:template match="article|letter|memo" mode="titleps-headings">
    <xsl:text>[\small\sffamily]{
    \sethead[\thepage][\sectiontitle][]
    {}{\sectiontitle}{\thepage}
    \setfoot[foot/even/headings/article][][]
    {foot/odd or one-sided/headings/article}{}{}
    }</xsl:text>
</xsl:template>

<!-- Experiment with "empty", "plain", and "headings" to      -->
<!-- see the effect of the above definitions (for "article")  -->
<!-- employed in the sample article                           -->
<!-- DO NOT set this to return empty text, errors will result -->
<!-- You can comment it out, and let base definition execute  -->
<xsl:template match="article" mode="titleps-global-style">
    <xsl:text>plain</xsl:text>
</xsl:template>

<!-- %%%%%%%%%%%%%%%%%%%%%%%% -->
<!-- End Header/Footer Stiles -->
<!-- %%%%%%%%%%%%%%%%%%%%%%%% -->





<!-- %%%%%%%%%%%%%%%% -->
<!-- Block styles     -->
<!-- %%%%%%%%%%%%%%%% -->

<!-- A general strategy: put frame hidden, and then use borderline to get borders.  This prevents hairline borders at page breaks, and allows for selecting just some sides for the frame. -->


<!-- "commentary" -->
<!-- Green and ugly -->
<xsl:template match="commentary" mode="tcb-style">
    <xsl:text>enhanced, breakable, parbox=false, size=minimal, attach title to upper, after title={\space}, fonttitle=\bfseries, coltitle=black, colback=green</xsl:text>
</xsl:template>

<!-- "objectives", "outcomes" -->
<!-- Default tcb, identically -->
<xsl:template match="objectives|outcomes" mode="tcb-style">
    <xsl:text/>
</xsl:template>

<!-- "assemblage" -->
<!-- Boxed title, borrowed from the AIM style -->
<xsl:template match="assemblage" mode="tcb-style">
    <xsl:text>enhanced, boxrule=0.5pt, sharp corners, colback=MidnightBlue!5, colframe=MidnightBlue!20,&#xa;</xsl:text>
    <xsl:text>colbacktitle=MidnightBlue!25, coltitle=black, boxed title style={sharp corners, frame hidden},&#xa;</xsl:text>
    <xsl:text>fonttitle=\bfseries, attach boxed title to top left={xshift=4mm,yshift=-4mm,yshifttext=-2mm}, top=3mm,&#xa;</xsl:text>
</xsl:template>






<!-- EXAMPLE-LIKE: "example", "question", "problem" -->
<!-- Default tcolorbox, but with tricolor titles    -->
<!-- Each just slightly different                   -->

<!-- Example styling from CLP -->
<xsl:template match="example" mode="tcb-style">
    <xsl:text>
      enhanced,
      breakable,
      parbox=false,
      frame hidden,
      borderline west={1pt}{0mm}{MidnightBlue},
      overlay unbroken and last={
        \draw[MidnightBlue, path fading=east, line width=.5pt] (frame.south west) -- (frame.south east);
      },
      colback=white,
      coltitle=white,
      fonttitle=\bfseries\sffamily,
      attach boxed title to top left={xshift=0mm},
      boxed title style={colback=MidnightBlue, sharp corners, colframe=MidnightBlue},
      boxed title size=title,
      after skip=1em,
      before skip=1em,
    </xsl:text>
</xsl:template>

<xsl:template match="activity|investigation|exploration" mode="tcb-style">
  <xsl:text>
    breakable,
	enhanced,
    attach title to upper, after title={.\space}, fonttitle=\bfseries, coltitle=black,
	colback=white,
	top=.5em,
	before skip=1em,
	after skip=.5em,
	sharp corners=all,
	frame hidden,
	%Draw breakable decorations:
	overlay first={%
		\draw[black!60, path fading=west] (frame.north) -- (frame.north east) -- (frame.south east);
		},
	overlay middle={%
		\draw[black!60] (frame.south east) -- (frame.north east);
		},
	 overlay last={%
		\fill[right color=black!40, left color=white, white] ([xshift=-4pt]frame.south east) -- ++(0,-4pt) to[out=176, in=-2] (frame.south) -- cycle;
		\draw[black!60, path fading=west] (frame.south) -- (frame.south east);
		\draw[black!60] (frame.north east) -- (frame.south east);
		},
	overlay unbroken={%
		\fill[right color=black!40, left color=white, white] ([xshift=-4pt]frame.south east) -- ++(0,-4pt) to[out=176, in=-2] (frame.south) -- cycle;
		\draw[black!60, path fading=west] (frame.south) -- (frame.south east);
		\draw[black!60, path fading=west] (frame.north) -- (frame.north east) -- (frame.south east);
		}
  </xsl:text>
</xsl:template>

<!-- The following are blocks not yet styled (thus commented) -->
<!-- but could be some day                                    -->

<!-- <xsl:template match="&THEOREM-LIKE;" mode="tcb-style">
  <xsl:text/>
</xsl:template> -->


<!-- <xsl:template match="proof" mode="tcb-style">
  <xsl:text>breakable, parbox=false, borderline west={.5pt}{0mm}{red}</xsl:text>
</xsl:template> -->

<!-- DEFINITION-LIKE: "definition"   -->
<!-- Various extreme choices from the tcolorbox documentation -->
<!-- Note: a trailing comma is OK, and maybe a good idea      -->
<!-- Note: the style definition may split across several line -->
<!-- of the LaTeX source using the hex A (dec 10) character   -->
<!-- Note: "enhanced" is necessary for boxed titles           -->
<!-- <xsl:template match="&DEFINITION-LIKE;" mode="tcb-style">
  <xsl:text>breakable, parbox=false, colframe=MidnightBlue, colback=MidnightBlue!5, colbacktitle=MidnightBlue!70, coltitle=black, enhanced, attach boxed title to top left={xshift=7mm, yshift*=-2ex},sharp corners=northwest, arc=10pt,</xsl:text>
</xsl:template> -->

<!-- REMARK-LIKE: "remark", "convention", "note",   -->
<!--            "observation", "warning", "insight" -->
<!-- COMPUTATION-LIKE: "computation", "technology"  -->
 <!--White title text, but title backgounds vary    -->
 <!--by category, and remarks have sharp corners    -->
<!-- <xsl:template match="&REMARK-LIKE;" mode="tcb-style">
    <xsl:text/>
</xsl:template> -->



<!-- %%%%%%%%%%%%%%%% -->
<!-- End Block Stiles -->
<!-- %%%%%%%%%%%%%%%% -->





<!-- Override default frontmatter pages: -->

<!-- Remove "half-title" leading page with -->
<!-- title only, at about 1:2 split    -->
<xsl:template match="book" mode="half-title" >
    <xsl:text>%% no half-title&#xa;</xsl:text>
</xsl:template>

<!-- Remove Ad card (may contain list of other books        -->
<!-- Or may be overridden to make title page spread -->
<!-- Obverse of half-title                          -->
<xsl:template match="book" mode="ad-card">
    <xsl:text>%% No adcard&#xa;</xsl:text>
</xsl:template>


<!-- Import custom title page -->
<xsl:template match="book" mode="title-page">
    <xsl:text>%% begin: title page&#xa;</xsl:text>
    <xsl:text>%% my custom page.&#xa;</xsl:text>
    <xsl:text>\input{frontmatter/title-page}&#xa;</xsl:text>
    <xsl:text>%% end: title page&#xa;</xsl:text>
</xsl:template>

<!-- Import custom copyright page -->
<!-- <xsl:template match="book" mode="copyright-page" >
    <xsl:text>%% begin: copyright-page&#xa;</xsl:text>
    <xsl:text>\input{frontmatter/copyright-page}&#xa;</xsl:text>
    <xsl:text>%% end:   copyright-page&#xa;</xsl:text>
</xsl:template> -->

<!-- Dedication style -->
<!-- <xsl:template match="dedication/p|dedication/p[1]" priority="1">
    <xsl:text>\begin{flushright}\large%&#xa;</xsl:text>
        <xsl:apply-templates />
    <xsl:text>%&#xa;</xsl:text>
    <xsl:text>\end{flushright}&#xa;</xsl:text>
</xsl:template> -->








<!-- Set up headers for index -->
<xsl:template match="index-list">
    <xsl:text>%&#xa;</xsl:text>
    <xsl:text>%% The index is here, setup is all in preamble&#xa;</xsl:text>
    <!-- Not sure why this is needed, but this will get the headings right -->
    <xsl:text>\markright{Index}&#xa;</xsl:text>
    <xsl:text>\renewcommand{\leftmark}{Index}&#xa;</xsl:text>
    <xsl:text>\printindex&#xa;</xsl:text>
    <xsl:text>%&#xa;</xsl:text>
</xsl:template>






<!-- Hack backmatter to get hints to projects and tasks: -->








<!-- We print hints, answers, solutions with no heading. -->
<!-- TODO: make heading on solution components configurable -->
<!-- <xsl:template match="hint" mode="backmatter">
    <xsl:apply-templates />
    <xsl:text>&#xa;</xsl:text>
</xsl:template>

<xsl:template match="hint[2]" mode="backmatter">
    <xsl:text>\par\smallskip&#xa;\noindent\textbf{Additional Hint}: </xsl:text>
    <xsl:apply-templates />
    <xsl:text>&#xa;</xsl:text>
</xsl:template>

 -->


<!-- Fix style of forward links: -->

<xsl:template match="exercise|webwork-reps/static|webwork-reps/static/stage|myopenmath|&EXAMPLE-LIKE;|&PROJECT-LIKE;|task" mode="exercise-components">
    <xsl:param name="b-original" />
    <xsl:param name="purpose" />
    <xsl:param name="b-has-statement" />
    <xsl:param name="b-has-hint" />
    <xsl:param name="b-has-answer"  />
    <xsl:param name="b-has-solution"  />

    <!-- structured (with components) versus unstructured (simply a bare statement) -->
    <xsl:choose>
        <xsl:when test="statement">
            <xsl:if test="$b-has-statement">
                <xsl:apply-templates select="statement">
                    <xsl:with-param name="b-original" select="$b-original" />
                </xsl:apply-templates>
                <xsl:if test="$b-original and ($debug.exercises.forward = 'yes')">
                    <!-- if several, all exist together, so just work with first one -->
                    <xsl:for-each select="hint[1]|answer[1]|solution[1]">
                        <!-- closer is better, so mainmatter solutions first -->
                        <xsl:choose>
                            <xsl:when test="count(.|$solutions-mainmatter) = count($solutions-mainmatter)">
                                <xsl:text>\qquad~\hfill{\tiny</xsl:text>
                                <xsl:text>\hyperlink{</xsl:text>
                                <xsl:apply-templates select="." mode="latex-id-duplicate">
                                    <xsl:with-param name="suffix" select="'main'"/>
                                </xsl:apply-templates>
                                <xsl:text>}{[</xsl:text>
                                <xsl:apply-templates select="." mode="type-name"/>
                                <xsl:text>]}}</xsl:text>
                            </xsl:when>
                            <xsl:when test="count(.|$solutions-backmatter) = count($solutions-backmatter)">
                                <xsl:text>\qquad~\hfill{\tiny</xsl:text>
                                <xsl:text>\hyperlink{</xsl:text>
                                <xsl:apply-templates select="." mode="latex-id-duplicate">
                                    <xsl:with-param name="suffix" select="'back'"/>
                                </xsl:apply-templates>
                                <xsl:text>}{[</xsl:text>
                                <xsl:apply-templates select="." mode="type-name"/>
                                <xsl:text>]}}</xsl:text>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:if>
                <xsl:if test="(hint and $b-has-hint) or (answer and $b-has-answer) or (solution and $b-has-solution)">
                    <xsl:call-template name="exercise-component-separator" />
                </xsl:if>
            </xsl:if>
            <xsl:if test="$b-has-hint">
                <xsl:apply-templates select="hint">
                    <xsl:with-param name="b-original" select="$b-original" />
                    <xsl:with-param name="purpose" select="$purpose" />
                    <xsl:with-param name="b-has-answer" select="$b-has-answer" />
                    <xsl:with-param name="b-has-solution" select="$b-has-solution" />
                </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$b-has-answer">
                <xsl:apply-templates select="answer">
                    <xsl:with-param name="b-original" select="$b-original" />
                    <xsl:with-param name="purpose" select="$purpose" />
                    <xsl:with-param name="b-has-solution" select="$b-has-solution" />
                </xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$b-has-solution">
                <xsl:apply-templates select="solution">
                    <xsl:with-param name="b-original" select="$b-original" />
                    <xsl:with-param name="purpose" select="$purpose" />
                </xsl:apply-templates>
            </xsl:if>
        </xsl:when>
        <xsl:otherwise>
            <!-- no explicit "statement", so all content is the statement -->
            <xsl:if test="$b-has-statement">
                <xsl:apply-templates>
                    <xsl:with-param name="b-original" select="$b-original" />
                </xsl:apply-templates>
                <!-- no separator, since no trailing components -->
            </xsl:if>
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>








</xsl:stylesheet>

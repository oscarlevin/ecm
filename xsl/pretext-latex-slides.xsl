<?xml version='1.0'?> <!-- As XML file -->

<!--********************************************************************
Copyright 2013 Robert A. Beezer, 2018 Oscar Levin

This file is part of MathBook XML.

MathBook XML is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 2 or version 3 of the
License (at your option).

MathBook XML is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MathBook XML.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************-->

<!-- http://pimpmyxslt.com/articles/entity-tricks-part2/ -->
<!DOCTYPE xsl:stylesheet [
    <!ENTITY % entities SYSTEM "entities.ent">
    %entities;
]>

<!-- Identify as a stylesheet -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:xml="http://www.w3.org/XML/1998/namespace"
    xmlns:exsl="http://exslt.org/common"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="exsl date str"
>

<!-- Build off of standard latex xsl: -->
<xsl:import href="./mathbook-latex.xsl" />

<!-- Intend output for rendering by pdflatex -->
<xsl:output method="text" />


<!-- Parameters to pass via xsltproc "stringparam" on command-line            -->
<!-- Or make a thin customization layer and use 'select' to provide overrides -->
<!-- Produce all content (or select individually below): -->
<xsl:param name="everything" select="'no'"/>

<!-- Individual extras: -->
<!-- Produce beamer slides: -->
<xsl:param name="slides" select="'yes'"/>
<!-- Others to be added as needed -->

<!-- TODO: add options to limit what content gets included (perhaps per format) -->

<!-- TODO: Allow choices of chunk size (currently chunk at section for most things, but at activity for worksheets).  Might not be necessary.  I could always chunk and include using docmute -->


<!-- This is where I need to split up files based on chunk level -->
<!-- Also, probably change file names based on content? -->
<xsl:template match="/">
  <!-- Generate includable preambles as needed -->
  <xsl:if test="$everything='yes' or $slides='yes'">
    <xsl:call-template name="slides-preamble-file"/>
    <xsl:call-template name="slides-main-file" />
  </xsl:if>
</xsl:template>

<!-- Default behavior is to skip all elements unless defined below. -->
<xsl:template match="*" mode="slides">
  <xsl:apply-templates select="*" mode="slides" />
</xsl:template>


<xsl:template match="chapter" mode="slides">
  <xsl:text>\section*{</xsl:text>
  <xsl:apply-templates select="." mode="long-name" />
  <xsl:text>}&#xa;</xsl:text>
  <xsl:apply-templates select="*" mode="slides"/>
</xsl:template>


<xsl:template match="section" mode="slides">
  <xsl:variable name="filename">
      <!-- <text>sections/</text> -->
      <!-- <xsl:apply-templates select="." mode="long-name" /> -->
      <xsl:call-template name="type-and-number"/>
      <text>.tex</text>
  </xsl:variable>
  <!-- <xsl:text>\input{</xsl:text> -->
  <xsl:text>\subimport{sections/}{</xsl:text>
  <xsl:value-of select="$filename" />
  <xsl:text>}&#xa;</xsl:text>
  <xsl:call-template name="slides-subfiles"/>
</xsl:template>

<xsl:template match="subsection" mode="slides">
  <xsl:text>\subsubsection*{</xsl:text>
  <xsl:apply-templates select="." mode="long-name" />
  <xsl:text>}&#xa;</xsl:text>
  <xsl:apply-templates select="*" mode="slides"/>
</xsl:template>



<!-- Produce nice filenames: -->
<xsl:template name="type-and-number">
  <xsl:variable name="filename">
    <xsl:apply-templates select="." mode="type-name" />
    <xsl:text>_</xsl:text>
    <xsl:apply-templates select="." mode="number" />
  </xsl:variable>
  <xsl:value-of select="translate($filename, '.', '-')"/>
</xsl:template>



<!-- Assemblages -->
<xsl:template match="assemblage" mode="slides">
  <xsl:call-template name="start-slide" />
    <xsl:text>\begin{assemblage}</xsl:text>
    <xsl:if test="title">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates select="." mode="title-full" />
        <xsl:text>]</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="." mode="label"/>
    <xsl:text>&#xa;</xsl:text>
    <xsl:apply-templates select="p|blockquote|pre|sidebyside|sbsgroup" />
    <xsl:text>\end{assemblage}&#xa;</xsl:text>
  <xsl:call-template name="end-slide" />
</xsl:template>


<!-- Side-by-sides, which might contain images or tables -->
<!-- TODO: make large ones fit nicely -->
<!-- TODO: clean up sidebyside latex to make readable -->
<xsl:template match="sidebyside[image|tabular]" mode="slides">
<!-- <xsl:template match="image" mode="beamer"> -->
<xsl:call-template name="start-slide" />

  <!-- <xsl:text>\resizebox{!}{0.9\textheight}{% &#xa;</xsl:text> -->
  <!-- <xsl:text>\begin{adjustbox}{max totalsize={0.9\textwidth}{0.7\textheight},center}&#xa;&#xa;</xsl:text> -->
  <xsl:apply-templates select="." />
  <!-- <xsl:text>&#xa;\end{adjustbox}&#xa;</xsl:text> -->
  <!-- <xsl:text>}&#xa;</xsl:text> -->
  <xsl:call-template name="end-slide" />
</xsl:template>



<!-- Figures -->
<!-- Standard LaTeX figure environment redefined, see preamble comments -->
<xsl:template match="figure" mode="slides">
    <xsl:if test="not(preceding-sibling::*[not(&SUBDIVISION-METADATA-FILTER;)])">
        <xsl:call-template name="leave-vertical-mode" />
    </xsl:if>
    <xsl:call-template name="start-slide" />
    <xsl:text>\begin{figure}&#xa;</xsl:text>
    <!-- <xsl:text>\begin{adjustbox}{max totalsize={0.9\textwidth}{0.9\textheight}}&#xa;</xsl:text> -->
    <xsl:text>\centering&#xa;</xsl:text>
    <xsl:apply-templates select="*[not(self::caption)]"/>
    <!-- <xsl:text>\end{adjustbox}&#xa;</xsl:text> -->
    <xsl:apply-templates select="caption" mode="plain" />
    <xsl:text>\end{figure}&#xa;</xsl:text>
    <xsl:call-template name="end-slide" />
</xsl:template>


<!-- Tables -->
<!-- TODO: make large tables fit shrink automatically -->
<xsl:template match="table" mode="slides">
  <xsl:call-template name="start-slide" />
    <xsl:text>\begin{table}&#xa;</xsl:text>
    <!-- <xsl:text>\begin{adjustbox}{max totalsize={0.9\textwidth}{0.9\textheight}}&#xa;</xsl:text> -->
    <xsl:text>\centering&#xa;</xsl:text>
    <xsl:apply-templates select="*[not(self::caption)]" />
    <!-- <xsl:text>\end{adjustbox}&#xa;</xsl:text> -->
    <xsl:apply-templates select="caption" mode="plain"/>
    <xsl:text>\end{table}&#xa;</xsl:text>
    <xsl:call-template name="end-slide" />
</xsl:template>



<!-- Captions for Figures, Tables, Listings, Lists -->
<!-- xml:id is on parent, but LaTeX generates number with caption -->
<!-- For slides, we don't want "figure" or a number (for now) -->
<!-- Not sure what the \captionof does -->
<xsl:template match="caption" mode="plain">
    <!-- <xsl:choose>
      <xsl:when test="parent::table/parent::sidebyside">
            <xsl:text>\captionof{table}{</xsl:text>
      </xsl:when>
      <xsl:when test="parent::figure/parent::sidebyside">
            <xsl:text>\captionof{figure}{</xsl:text>
      </xsl:when>
      <xsl:when test="parent::listing">
            <xsl:text>\captionof{listingcap}{</xsl:text>
        </xsl:when>
      <xsl:when test="parent::list">
            <xsl:text>\captionof{namedlistcap}{</xsl:text>
        </xsl:when>
      <xsl:otherwise>
          <xsl:text>&#xa;\vfill &#xa;</xsl:text>
      </xsl:otherwise>
    </xsl:choose> -->
    <xsl:apply-templates />
    <xsl:apply-templates select="parent::*" mode="label" />
    <xsl:text>&#xa;</xsl:text>
</xsl:template>

<!-- Subcaptions showup in side-by-side -->
<xsl:template match="caption" mode="subcaption">
    <!-- <xsl:text>\subcaption{</xsl:text> -->
    <xsl:apply-templates />
    <!-- <xsl:apply-templates select="parent::*" mode="label" /> -->
    <xsl:text>}&#xa;</xsl:text>
</xsl:template>


<!-- Each element get's its own slide -->
<xsl:template match="&REMARK-LIKE;|&COMPUTATION-LIKE;|&EXAMPLE-LIKE;|&PROJECT-LIKE;|&DEFINITION-LIKE;|&THEOREM-LIKE;|&AXIOM-LIKE;" mode="slides">
  <xsl:call-template name="start-slide" />
  <xsl:apply-templates select="."/>
  <xsl:call-template name="end-slide" />
</xsl:template>


<!-- Don't include solutions -->
<xsl:template match="solution">
</xsl:template>

<!-- Don't include proofs -->
<xsl:template match="proof">
</xsl:template>

<!-- Don't inlcude index calls -->
<xsl:template match="idx">
</xsl:template>

<!-- Fix lists so we can label them without enumitem, which beamer plays poorly with -->
<xsl:template match="ol">
    <xsl:choose>
        <xsl:when test="not(ancestor::ol or ancestor::ul or ancestor::dl or parent::objectives)">
            <xsl:call-template name="leave-vertical-mode" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>%&#xa;</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@cols">
        <xsl:text>\begin{multicols}{</xsl:text>
        <xsl:value-of select="@cols" />
        <xsl:text>}&#xa;</xsl:text>
    </xsl:if>
    <xsl:text>\begin{enumerate}</xsl:text>
    <!-- override LaTeX defaults as indicated -->
    <xsl:if test="@label or ancestor::exercises or ancestor::references">
        <xsl:text>[</xsl:text> <!-- changed -->
        <xsl:apply-templates select="." mode="latex-list-label" />
        <xsl:text>]</xsl:text>
    </xsl:if>
    <xsl:text>&#xa;</xsl:text>
     <xsl:apply-templates />
    <xsl:text>\end{enumerate}&#xa;</xsl:text>
    <xsl:if test="@cols">
        <xsl:text>\end{multicols}&#xa;</xsl:text>
    </xsl:if>
</xsl:template>

<!-- MBX unordered list scheme is distinct -->
<!-- from LaTeX's so we write out a label  -->
<!-- choice for each such list             -->
<xsl:template match="ul">
    <xsl:choose>
        <xsl:when test="not(ancestor::ol or ancestor::ul or ancestor::dl or parent::objectives)">
            <xsl:call-template name="leave-vertical-mode" />
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>%&#xa;</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@cols">
        <xsl:text>\begin{multicols}{</xsl:text>
        <xsl:value-of select="@cols" />
        <xsl:text>}&#xa;</xsl:text>
    </xsl:if>
    <xsl:text>\begin{itemize}&#xa;</xsl:text> <!-- changed -->
    <!-- <xsl:apply-templates select="." mode="latex-list-label" /> -->
    <!-- <xsl:text>]&#xa;</xsl:text> -->
    <xsl:apply-templates />
    <xsl:text>\end{itemize}&#xa;</xsl:text>
    <xsl:if test="@cols">
        <xsl:text>\end{multicols}&#xa;</xsl:text>
    </xsl:if>
</xsl:template>



<!-- Start and end of slides -->
<!-- These will eventually get more, including comments -->
<!--   which include section numbers to easily identify them -->
<xsl:template name="start-slide">
    <xsl:text>\begin{frame}[allowframebreaks, plain]&#xa; &#xa;</xsl:text>
</xsl:template>

<xsl:template name="end-slide">
    <xsl:text>\end{frame}&#xa; &#xa;</xsl:text>
</xsl:template>




<!-- ########################################### -->
<!-- Templates to generate files:                -->
<!-- ########################################### -->

<!-- To generate single file which includes everything: -->
<xsl:template name="slides-main-file">
  <exsl:document href="slides.tex" method="text" >
    <xsl:text>\documentclass{beamer}&#xa;&#xa;</xsl:text>
    <xsl:text>\input{slides-preamble.tex}&#xa;</xsl:text>
    <!-- This will allow instructors to set variables unique to their course (course name, instructor name, semester etc.) -->
    <!-- <xsl:text>% Include a file allowing course customizations &#xa;</xsl:text> -->
    <!-- <xsl:text>\@input{../customize.tex}&#xa;</xsl:text> -->
    <xsl:text>&#xa;&#xa;\begin{document}&#xa;</xsl:text>
    <xsl:apply-templates select="*" mode="slides"/>
    <xsl:text>\end{document}&#xa;</xsl:text>
  </exsl:document>
</xsl:template>


<!-- Subfiles: -->
<xsl:template name="slides-subfiles">
  <xsl:variable name="filename">
      <!-- <text>sections/</text> -->
      <!-- <xsl:apply-templates select="." mode="long-name" /> -->
      <xsl:call-template name="type-and-number"/>
      <text>.tex</text>
  </xsl:variable>
  <exsl:document href="sections/{$filename}" method="text" >
    <xsl:text>\documentclass{beamer}&#xa;&#xa;</xsl:text>
    <xsl:text>\input{../slides-preamble.tex}&#xa;</xsl:text>
    <!-- <xsl:text>% Include a file allowing course customizations &#xa;</xsl:text> -->
    <!-- <xsl:text>\@input{../../customize.tex}&#xa;</xsl:text> -->
    <xsl:text>&#xa;&#xa;\begin{document}&#xa;</xsl:text>
    <xsl:text>\subsection*{</xsl:text>
    <xsl:apply-templates select="." mode="long-name" />
    <xsl:text>}&#xa;</xsl:text>
    <xsl:apply-templates select="*" mode="slides"/>
    <xsl:text>&#xa;\end{document}&#xa;</xsl:text>
  </exsl:document>
</xsl:template>





<!-- To generate single file with preambles: -->
<xsl:template name="slides-preamble-file" >
  <exsl:document href="slides-preamble.tex" method="text" >
    <xsl:call-template name="slides-preamble"/>
  </exsl:document>
</xsl:template>


<!-- ########################################### -->
<!-- End of main sheet.  Below is only preambles -->
<!-- ########################################### -->



<!-- Slides.  Remnant from when there were multiple outputs available -->
<xsl:template name="slides-preamble">
  <xsl:call-template name="beamer-preamble"/>
  <xsl:text>% Include docmute package to include files that can themselves compile. &#xa;</xsl:text>
  <xsl:text>\usepackage{docmute}&#xa;</xsl:text>
  <xsl:text>\usepackage{import}&#xa;</xsl:text>
</xsl:template>

<!-- Beamer Preamble template -->
<!-- There is likely lots to fix here -->
<!-- Currently exactly the same as latex preable, except: -->
<!--    remove all geometry stuff -->
<!--    include adjustbox -->
<!--    Removed newtheorems (included in beamer) -->
<!--    Removed index code (we never have an index) -->
<!-- It would be nice to either really clean this up or put it all in a new file -->
<xsl:template name="beamer-preamble">
  <xsl:text>%% Preamble:&#xa;</xsl:text>

  <xsl:text>%% Custom Preamble Entries, early (use latex.preamble.early)&#xa;</xsl:text>
  <xsl:if test="$latex.preamble.early != ''">
      <xsl:value-of select="$latex.preamble.early" />
      <xsl:text>&#xa;</xsl:text>
  </xsl:if>
  <xsl:text>\usepackage{adjustbox}&#xa;</xsl:text>
  <!-- Following need to be mature, robust, powerful, flexible, well-maintained -->
  <xsl:text>%% Default LaTeX packages&#xa;</xsl:text>
  <xsl:text>%%   1.  always employed (or nearly so) for some purpose, or&#xa;</xsl:text>
  <xsl:text>%%   2.  a stylewriter may assume their presence&#xa;</xsl:text>
  <xsl:text>\usepackage{geometry}&#xa;</xsl:text>
  <xsl:text>%% Some aspects of the preamble are conditional,&#xa;</xsl:text>
  <xsl:text>%% the LaTeX engine is one such determinant&#xa;</xsl:text>
  <xsl:text>\usepackage{ifthen}&#xa;</xsl:text>
  <xsl:text>\usepackage{ifxetex,ifluatex}&#xa;</xsl:text>
  <xsl:text>%% Raster graphics inclusion&#xa;</xsl:text>
  <xsl:text>\usepackage{graphicx}&#xa;</xsl:text>
  <xsl:text>%% Colored boxes, and much more, though mostly styling&#xa;</xsl:text>
  <xsl:text>%% skins library provides "enhanced" skin, employing tikzpicture&#xa;</xsl:text>
  <xsl:text>%% boxes may be configured as "breakable" or "unbreakable"&#xa;</xsl:text>
  <xsl:text>\usepackage{tcolorbox}&#xa;</xsl:text>
  <xsl:text>\tcbuselibrary{skins}&#xa;</xsl:text>
  <xsl:text>\tcbuselibrary{breakable}&#xa;</xsl:text>
  <xsl:text>%% Hyperref should be here, but likes to be loaded late&#xa;</xsl:text>
  <xsl:text>%%&#xa;</xsl:text>
  <xsl:text>%% Inline math delimiters, \(, \), need to be robust&#xa;</xsl:text>
  <xsl:text>%% 2016-01-31:  latexrelease.sty  supersedes  fixltx2e.sty&#xa;</xsl:text>
  <xsl:text>%% If  latexrelease.sty  exists, bugfix is in kernel&#xa;</xsl:text>
  <xsl:text>%% If not, bugfix is in  fixltx2e.sty&#xa;</xsl:text>
  <xsl:text>%% See:  https://tug.org/TUGboat/tb36-3/tb114ltnews22.pdf&#xa;</xsl:text>
  <xsl:text>%% and read "Fewer fragile commands" in distribution's  latexchanges.pdf&#xa;</xsl:text>
  <xsl:text>\IfFileExists{latexrelease.sty}{}{\usepackage{fixltx2e}}&#xa;</xsl:text>

  <xsl:text>%% This LaTeX file may be compiled with pdflatex, xelatex, or lualatex&#xa;</xsl:text>
  <xsl:text>%% The following provides engine-specific capabilities&#xa;</xsl:text>
  <xsl:text>%% Generally, xelatex and lualatex will do better languages other than US English&#xa;</xsl:text>
  <xsl:text>%% You can pick from the conditional if you will only ever use one engine&#xa;</xsl:text>
  <xsl:text>\ifthenelse{\boolean{xetex} \or \boolean{luatex}}{%&#xa;</xsl:text>
  <xsl:text>%% begin: xelatex and lualatex-specific configuration&#xa;</xsl:text>
  <xsl:text>%% fontspec package will make Latin Modern (lmodern) the default font&#xa;</xsl:text>
  <!-- http://tex.stackexchange.com/questions/115321/how-to-optimize-latin-modern-font-with-xelatex -->
  <xsl:text>\ifxetex\usepackage{xltxtra}\fi&#xa;</xsl:text>
  <xsl:text>\usepackage{fontspec}&#xa;</xsl:text>
  <xsl:text>%% realscripts is the only part of xltxtra relevant to lualatex &#xa;</xsl:text>
  <xsl:text>\ifluatex\usepackage{realscripts}\fi&#xa;</xsl:text>
  <!-- TODO: put a xelatex/lualatex font package hook here? -->
  <xsl:text>%% &#xa;</xsl:text>
  <!-- language tags appear in docinfo in renames, so be careful -->
  <xsl:text>%% Extensive support for other languages&#xa;</xsl:text>
  <xsl:text>\usepackage{polyglossia}&#xa;</xsl:text>
  <!--  -->
  <!-- US English -->
  <!-- switch to positive test once ready -->
  <xsl:if test="not($document-language = 'hu-HU')">
      <xsl:text>%% Main document language is US English&#xa;</xsl:text>
      <xsl:text>\setdefaultlanguage{english}&#xa;</xsl:text>
  </xsl:if>
  <!-- does this need a font family? -->
  <xsl:if test="$document-root//@xml:lang='en-US'">
      <xsl:text>%% Document language contains parts in US English&#xa;</xsl:text>
      <xsl:text>\setotherlanguage{english}&#xa;</xsl:text>
  </xsl:if>
  <!--  -->
  <xsl:if test="$document-root//@xml:lang='el'">
      <xsl:text>%% Greek (Modern) specified by 'el' language tag&#xa;</xsl:text>
      <xsl:text>%% Font families: CMU Serif (fonts-cmu package), Linux Libertine O, GFS Artemisia&#xa;</xsl:text>
      <!-- <xsl:text>\setotherlanguage[variant=ancient,numerals=greek]{greek}&#xa;</xsl:text> -->
      <xsl:text>\setotherlanguage{greek}&#xa;</xsl:text>
      <xsl:text>\newfontfamily\greekfont[Script=Greek]{CMU Serif}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$document-root//@xml:lang='ko-KR'">
      <xsl:text>%% Korean specified by 'ko-KR' language tag&#xa;</xsl:text>
      <xsl:text>%% Debian/Ubuntu "fonts-nanum" package&#xa;</xsl:text>
      <xsl:text>\setotherlanguage{korean}&#xa;</xsl:text>
      <xsl:text>\newfontfamily\koreanfont{NanumMyeongjo}&#xa;</xsl:text>
  </xsl:if>
  <!--  -->
  <!-- Magyar (Hungarian) -->
  <xsl:if test="$document-language = 'hu-HU'">
      <xsl:text>%% Main document language is Magyar (Hungarian)&#xa;</xsl:text>
      <xsl:text>\setdefaultlanguage{magyar}&#xa;</xsl:text>
  </xsl:if>
  <!-- does this need a font family -->
  <xsl:if test="$document-root//@xml:lang='hu-HU'">
      <xsl:text>%% Document contains parts in Magyar (Hungarian)&#xa;</xsl:text>
      <xsl:text>\setotherlanguage{magyar}&#xa;</xsl:text>
  </xsl:if>
  <!--  -->
  <xsl:if test="$document-root//@xml:lang='ru-RU'">
      <xsl:text>%% Russian specified by 'ru-RU' language tag&#xa;</xsl:text>
      <xsl:text>%% Font families: CMU Serif, Linux Libertine O&#xa;</xsl:text>
      <xsl:text>\setotherlanguage{russian}&#xa;</xsl:text>
      <xsl:text>\newfontfamily\cyrillicfont[Script=Cyrillic]{CMU Serif}&#xa;</xsl:text>
  </xsl:if>
  <xsl:text>%% Spanish&#xa;</xsl:text>
  <xsl:text>\setotherlanguage{spanish}&#xa;</xsl:text>
  <xsl:text>%% Vietnamese&#xa;</xsl:text>
  <xsl:text>\setotherlanguage{vietnamese}&#xa;</xsl:text>
  <!-- Korean gloss file may appear soon, 2016-07-25 -->
  <!-- <xsl:text>%% Korean&#xa;</xsl:text> -->
  <!-- <xsl:text>\setotherlanguage{korean}&#xa;</xsl:text> -->
  <!-- <xsl:text>\newfontfamily\koreanfont{NanumMyeongjo}&#xa;</xsl:text> -->
  <!-- <xsl:text>\newfontfamily\koreanfont[Script=Hangul]{UnBatang}&#xa;</xsl:text> -->
  <xsl:text>%% end: xelatex and lualatex-specific configuration&#xa;</xsl:text>
  <xsl:text>}{%&#xa;</xsl:text>
  <xsl:text>%% begin: pdflatex-specific configuration&#xa;</xsl:text>
  <xsl:text>%% translate common Unicode to their LaTeX equivalents&#xa;</xsl:text>
  <xsl:text>%% Also, fontenc with T1 makes CM-Super the default font&#xa;</xsl:text>
  <!-- https://tex.stackexchange.com/questions/664/why-should-i-use-usepackaget1fontenc -->
  <!-- http://tex.stackexchange.com/questions/88368/how-do-i-invoke-cm-super -->
  <xsl:text>%% (\input{ix-utf8enc.dfu} from the "inputenx" package is possible addition (broken?)&#xa;</xsl:text>
  <xsl:text>\usepackage[T1]{fontenc}&#xa;</xsl:text>
  <xsl:text>\usepackage[utf8]{inputenc}&#xa;</xsl:text>
  <!-- TODO: put a pdflatex font package hook here? -->
  <xsl:text>%% end: pdflatex-specific configuration&#xa;</xsl:text>
  <xsl:text>}&#xa;</xsl:text>
  <xsl:if test="$document-root//c or $document-root//cd or $document-root//pre or $document-root//program or $document-root//console or $document-root//sage">
      <xsl:text>%% Monospace font: Inconsolata (zi4)&#xa;</xsl:text>
      <xsl:text>%% Sponsored by TUG: http://levien.com/type/myfonts/inconsolata.html&#xa;</xsl:text>
      <xsl:text>%% See package documentation for excellent instructions&#xa;</xsl:text>
      <xsl:text>%% One caveat, seem to need full file name to locate OTF files&#xa;</xsl:text>
      <xsl:text>%% Loads the "upquote" package as needed, so we don't have to&#xa;</xsl:text>
      <xsl:text>%% Upright quotes might come from the  textcomp  package, which we also use&#xa;</xsl:text>
      <xsl:text>%% We employ the shapely \ell to match Google Font version&#xa;</xsl:text>
      <xsl:text>%% pdflatex: "varqu" option produces best upright quotes&#xa;</xsl:text>
      <xsl:text>%% xelatex,lualatex: add StylisticSet 1 for shapely \ell&#xa;</xsl:text>
      <xsl:text>%% xelatex,lualatex: add StylisticSet 2 for plain zero&#xa;</xsl:text>
      <xsl:text>%% xelatex,lualatex: we add StylisticSet 3 for upright quotes&#xa;</xsl:text>
      <xsl:text>%% &#xa;</xsl:text>
      <xsl:text>\ifthenelse{\boolean{xetex} \or \boolean{luatex}}{%&#xa;</xsl:text>
      <xsl:text>%% begin: xelatex and lualatex-specific monospace font&#xa;</xsl:text>
      <xsl:text>\usepackage{zi4}&#xa;</xsl:text>
      <xsl:text>\setmonofont[BoldFont=Inconsolatazi4-Bold.otf,StylisticSet={1,3}]{Inconsolatazi4-Regular.otf}&#xa;</xsl:text>
      <!-- <xsl:text>%% Mono spacing with \texttt, no extra space after period&#xa;</xsl:text> -->
      <!-- <xsl:text>\usepackage[mono,extrasp=0em]{zi4}&#xa;</xsl:text> -->
      <!-- TODO: put a xelatex/lualatex monospace font package hook here? -->
      <xsl:text>%% end: xelatex and lualatex-specific monospace font&#xa;</xsl:text>
      <xsl:text>}{%&#xa;</xsl:text>
      <xsl:text>%% begin: pdflatex-specific monospace font&#xa;</xsl:text>
      <xsl:text>%% "varqu" option provides textcomp \textquotedbl glyph&#xa;</xsl:text>
      <xsl:text>%% "varl"  option provides shapely "ell"&#xa;</xsl:text>
      <xsl:text>\usepackage[varqu,varl]{zi4}&#xa;</xsl:text>
      <!-- \@ifpackagelater: https://tex.stackexchange.com/questions/33806/is-it-possible-to-abort-loading-a-package-if-its-too-old -->
      <!-- <xsl:text>%% Mono spacing with \texttt, no extra space after period&#xa;</xsl:text> -->
      <!-- <xsl:text>\usepackage[mono,extrasp=0em]{zi4}&#xa;</xsl:text> -->
      <xsl:text>%% end: pdflatex-specific monospace font&#xa;</xsl:text>
      <xsl:text>}&#xa;</xsl:text>
      <!-- https://tex.stackexchange.com/questions/2790/when-should-one-use-verb-and-when-texttt/235917 -->
      <xsl:if test="$document-root//c">
          <xsl:text>%% \mono macro for content of "c" element only&#xa;</xsl:text>
          <xsl:text>\newcommand{\mono}[1]{\texttt{#1}}&#xa;</xsl:text>
      </xsl:if>
  </xsl:if>
  <xsl:text>%% Symbols, align environment, bracket-matrix&#xa;</xsl:text>
  <xsl:text>\usepackage{amsmath}&#xa;</xsl:text>
  <xsl:text>\usepackage{amssymb}&#xa;</xsl:text>
  <xsl:text>%% allow page breaks within display mathematics anywhere&#xa;</xsl:text>
  <xsl:text>%% level 4 is maximally permissive&#xa;</xsl:text>
  <xsl:text>%% this is exactly the opposite of AMSmath package philosophy&#xa;</xsl:text>
  <xsl:text>%% there are per-display, and per-equation options to control this&#xa;</xsl:text>
  <xsl:text>%% split, aligned, gathered, and alignedat are not affected&#xa;</xsl:text>
  <xsl:text>\allowdisplaybreaks[4]&#xa;</xsl:text>
  <xsl:text>%% allow more columns to a matrix&#xa;</xsl:text>
  <xsl:text>%% can make this even bigger by overriding with  latex.preamble.late  processing option&#xa;</xsl:text>
  <xsl:text>\setcounter{MaxMatrixCols}{30}&#xa;</xsl:text>
  <xsl:if test="//m[contains(text(),'sfrac')] or //md[contains(text(),'sfrac')] or //me[contains(text(),'sfrac')] or //mrow[contains(text(),'sfrac')]">
      <xsl:text>%% xfrac package for 'beveled fractions': http://tex.stackexchange.com/questions/3372/how-do-i-typeset-arbitrary-fractions-like-the-standard-symbol-for-5-%C2%BD&#xa;</xsl:text>
      <xsl:text>\usepackage{xfrac}&#xa;</xsl:text>
  </xsl:if>
  <xsl:text>%%&#xa;</xsl:text>
  <!-- load following conditionally if it presents problems -->
  <xsl:text>%% Color support, xcolor package&#xa;</xsl:text>
  <xsl:text>%% Always loaded, for: add/delete text, author tools&#xa;</xsl:text>
  <!-- Avoid option conflicts causing errors: -->
  <!-- http://tex.stackexchange.com/questions/57364/option-clash-for-package-xcolor -->
  <xsl:text>\PassOptionsToPackage{usenames,dvipsnames,svgnames,table}{xcolor}&#xa;</xsl:text>
  <xsl:text>\usepackage{xcolor}&#xa;</xsl:text>
  <xsl:text>%%&#xa;</xsl:text>
  <xsl:text>%% Semantic Macros&#xa;</xsl:text>
  <xsl:text>%% To preserve meaning in a LaTeX file&#xa;</xsl:text>
  <xsl:text>%% Only defined here if required in this document&#xa;</xsl:text>
  <!-- <xsl:if test="$document-root//alert">
      <xsl:text>%% Used for warnings, typically bold and italic&#xa;</xsl:text>
      <xsl:text>\newcommand{\alert}[1]{\textbf{\textit{#1}}}&#xa;</xsl:text>
  </xsl:if> -->
  <xsl:if test="$document-root//term">
      <xsl:text>%% Used for inline definitions of terms&#xa;</xsl:text>
      <xsl:text>\newcommand{\terminology}[1]{\textbf{#1}}&#xa;</xsl:text>
  </xsl:if>
  <!-- http://tex.stackexchange.com/questions/23711/strikethrough-text -->
  <!-- http://tex.stackexchange.com/questions/287599/thickness-for-sout-strikethrough-command-from-ulem-package -->
  <xsl:if test="$document-root//insert or $document-root//delete or $document-root//stale">
      <xsl:text>%% Edits (insert, delete), stale (irrelevant, obsolete)&#xa;</xsl:text>
      <xsl:text>%% Package: underlines and strikethroughs, no change to \emph{}&#xa;</xsl:text>
      <xsl:text>\usepackage[normalem]{ulem}&#xa;</xsl:text>
      <xsl:text>%% Rules in this package reset proportional to fontsize&#xa;</xsl:text>
      <xsl:text>%% NB: *never* reset to package default (0.4pt?) after use&#xa;</xsl:text>
      <xsl:text>%% Macros will use colors if  latex.print='no'  (the default)&#xa;</xsl:text>
      <xsl:if test="$document-root//insert">
          <xsl:text>%% Used for an edit that is an addition&#xa;</xsl:text>
          <xsl:text>\newcommand{\insertthick}{.1ex}&#xa;</xsl:text>
          <xsl:choose>
              <xsl:when test="$latex.print='yes'">
                  <xsl:text>\newcommand{\inserted}[1]{\renewcommand{\ULthickness}{\insertthick}\uline{#1}}&#xa;</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:text>\newcommand{\inserted}[1]{\renewcommand{\ULthickness}{\insertthick}\textcolor{green}{\uline{#1}}}&#xa;</xsl:text>
              </xsl:otherwise>
          </xsl:choose>
      </xsl:if>
      <xsl:if test="$document-root//delete">
          <xsl:text>%% Used for an edit that is a deletion&#xa;</xsl:text>
          <xsl:text>\newcommand{\deletethick}{.25ex}&#xa;</xsl:text>
          <xsl:choose>
              <xsl:when test="$latex.print='yes'">
                  <xsl:text>\newcommand{\deleted}[1]{\renewcommand{\ULthickness}{\deletethick}\sout{#1}}&#xa;</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:text>\newcommand{\deleted}[1]{\renewcommand{\ULthickness}{\deletethick}\textcolor{red}{\sout{#1}}}&#xa;</xsl:text>
              </xsl:otherwise>
          </xsl:choose>
      </xsl:if>
      <xsl:if test="$document-root//stale">
          <xsl:text>%% Used for inline irrelevant or obsolete text&#xa;</xsl:text>
          <xsl:text>\newcommand{\stalethick}{.1ex}&#xa;</xsl:text>
          <xsl:text>\newcommand{\stale}[1]{\renewcommand{\ULthickness}{\stalethick}\sout{#1}}&#xa;</xsl:text>
      </xsl:if>
  </xsl:if>
  <xsl:if test="$document-root//fillin">
      <xsl:text>%% Used for fillin answer blank&#xa;</xsl:text>
      <xsl:text>%% Argument is length in em&#xa;</xsl:text>
      <xsl:text>\newcommand{\fillin}[1]{\underline{\hspace{#1em}}}&#xa;</xsl:text>
  </xsl:if>
  <!-- lower-casing macro from: http://tex.stackexchange.com/questions/114592/force-all-small-caps -->
  <!-- Letter-spacing LaTeX: http://tex.stackexchange.com/questions/114578/tufte-running-headers-not-using-full-width-of-page -->
  <!-- PDF navigation panels has titles as simple strings,    -->
  <!-- devoid of any formatting, so we just give up, as any   -->
  <!-- attempt to use title-specific macros, \texorpdfstring, -->
  <!-- \protect, \DeclareRobustCommand does not help get      -->
  <!-- ToC, PDF navigation panel, text heading all correct    -->
  <!-- Obstacle is that sc shape does not come in bold,       -->
  <!-- http://tex.stackexchange.com/questions/17830/using-textsc-within-section -->
  <xsl:if test="$document-root//abbr">
      <xsl:text>%% Used to markup abbreviations, text or titles&#xa;</xsl:text>
      <xsl:text>%% default is small caps (Bringhurst, 4e, 3.2.2, p. 48)&#xa;</xsl:text>
      <xsl:text>%% Titles are no-ops now, see comments in XSL source&#xa;</xsl:text>
      <xsl:text>\newcommand{\abbreviation}[1]{\textsc{\MakeLowercase{#1}}}&#xa;</xsl:text>
      <xsl:text>\DeclareRobustCommand{\abbreviationintitle}[1]{\texorpdfstring{#1}{#1}}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$document-root//acro">
      <xsl:text>%% Used to markup acronyms, text or titles&#xa;</xsl:text>
      <xsl:text>%% default is small caps (Bringhurst, 4e, 3.2.2, p. 48)&#xa;</xsl:text>
      <xsl:text>%% Titles are no-ops now, see comments in XSL source&#xa;</xsl:text>
      <xsl:text>\newcommand{\acronym}[1]{\textsc{\MakeLowercase{#1}}}&#xa;</xsl:text>
      <xsl:text>\DeclareRobustCommand{\acronymintitle}[1]{\texorpdfstring{#1}{#1}}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$document-root//init">
      <xsl:text>%% Used to markup initialisms, text or titles&#xa;</xsl:text>
      <xsl:text>%% default is small caps (Bringhurst, 4e, 3.2.2, p. 48)&#xa;</xsl:text>
      <xsl:text>%% Titles are no-ops now, see comments in XSL source&#xa;</xsl:text>
      <xsl:text>\newcommand{\initialism}[1]{\textsc{\MakeLowercase{#1}}}&#xa;</xsl:text>
      <xsl:text>\DeclareRobustCommand{\initialismintitle}[1]{\texorpdfstring{#1}{#1}}&#xa;</xsl:text>
  </xsl:if>
  <!-- http://andrewmccarthy.ie/2014/11/06/swung-dash-in-latex/ -->
  <xsl:if test="$document-root//swungdash">
      <xsl:text>%% A character like a tilde, but different&#xa;</xsl:text>
      <xsl:text>\newcommand{\swungdash}{\raisebox{-2.25ex}{\scalebox{2}{\~{}}}}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$document-root//quantity">
      <xsl:text>%% Used for units and number formatting&#xa;</xsl:text>
      <xsl:text>\usepackage[per-mode=fraction]{siunitx}&#xa;</xsl:text>
      <xsl:text>\ifxetex\sisetup{math-micro=\text{µ},text-micro=µ}\fi</xsl:text>
      <xsl:text>\ifluatex\sisetup{math-micro=\text{µ},text-micro=µ}\fi</xsl:text>
      <xsl:text>%% Common non-SI units&#xa;</xsl:text>
      <xsl:for-each select="document('mathbook-units.xsl')//base[@siunitx]">
          <xsl:text>\DeclareSIUnit\</xsl:text>
          <xsl:value-of select="@full" />
          <xsl:text>{</xsl:text>
          <xsl:choose>
              <xsl:when test="@siunitx='none'">
                  <xsl:value-of select="@short" />
              </xsl:when>
              <xsl:otherwise>
                  <xsl:value-of select="@siunitx" />
              </xsl:otherwise>
          </xsl:choose>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:for-each>
  </xsl:if>
  <xsl:if test="$document-root//case[@direction]">
      <xsl:text>%% Arrows for iff proofs, with trailing space&#xa;</xsl:text>
      <xsl:text>\newcommand{\forwardimplication}{($\Rightarrow$)\space\space}&#xa;</xsl:text>
      <xsl:text>\newcommand{\backwardimplication}{($\Leftarrow$)\space\space}&#xa;</xsl:text>
  </xsl:if>
  <xsl:text>%% Subdivision Numbering, Chapters, Sections, Subsections, etc&#xa;</xsl:text>
  <xsl:text>%% Subdivision numbers may be turned off at some level ("depth")&#xa;</xsl:text>
  <xsl:text>%% A section *always* has depth 1, contrary to us counting from the document root&#xa;</xsl:text>
  <xsl:text>%% The latex default is 3.  If a larger number is present here, then&#xa;</xsl:text>
  <xsl:text>%% removing this command may make some cross-references ambiguous&#xa;</xsl:text>
  <xsl:text>%% The precursor variable $numbering-maxlevel is checked for consistency in the common XSL file&#xa;</xsl:text>
  <xsl:text>\setcounter{secnumdepth}{</xsl:text>
      <xsl:value-of select="$latex-numbering-maxlevel" />
  <xsl:text>}&#xa;</xsl:text>
  <!-- Could condition following on existence of any amsthm environment -->
  <xsl:text>%% Environments with amsthm package&#xa;</xsl:text>
  <xsl:text>%% Theorem-like environments in "plain" style, with or without proof&#xa;</xsl:text>
  <xsl:text>\usepackage{amsthm}&#xa;</xsl:text>
  <xsl:text>\theoremstyle{plain}&#xa;</xsl:text>
  <xsl:text>%% Numbering for Theorems, Conjectures, Examples, Figures, etc&#xa;</xsl:text>
  <xsl:text>%% Controlled by  numbering.theorems.level  processing parameter&#xa;</xsl:text>
  <xsl:text>%% Always need a theorem environment to set base numbering scheme&#xa;</xsl:text>
  <xsl:text>%% even if document has no theorems (but has other environments)&#xa;</xsl:text>
  <!-- http://tex.stackexchange.com/questions/155710/understanding-the-arguments-in-newtheorem-e-g-newtheoremtheoremtheoremsec/155714#155714 -->
  <!-- Removed \newtheorem{theorem} -->
  <xsl:text>%% Only variants actually used in document appear here&#xa;</xsl:text>
  <xsl:text>%% Style is like a theorem, and for statements without proofs&#xa;</xsl:text>
  <xsl:text>%% Numbering: all theorem-like numbered consecutively&#xa;</xsl:text>
  <xsl:text>%% i.e. Corollary 4.3 follows Theorem 4.2&#xa;</xsl:text>
  <!-- THEOREM-LIKE blocks, environments -->
  <!-- <xsl:if test="//corollary">
      <xsl:text>\newtheorem{corollary}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'corollary'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if> -->
  <!-- <xsl:if test="//lemma">
      <xsl:text>\newtheorem{lemma}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'lemma'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if> -->
  <xsl:if test="//algorithm">
      <xsl:text>\newtheorem{algorithm}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'algorithm'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//proposition">
      <xsl:text>\newtheorem{proposition}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'proposition'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//claim">
      <xsl:text>\newtheorem{claim}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'claim'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//fact">
      <xsl:text>\newtheorem{fact}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'fact'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//identity">
      <xsl:text>\newtheorem{identity}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'identity'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <!-- AXIOM-LIKE blocks, environments -->
  <xsl:if test="//axiom">
      <xsl:text>\newtheorem{axiom}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'axiom'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//conjecture">
      <xsl:text>\newtheorem{conjecture}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'conjecture'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//principle">
      <xsl:text>\newtheorem{principle}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'principle'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//heuristic">
      <xsl:text>\newtheorem{heuristic}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'heuristic'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//hypothesis">
      <xsl:text>\newtheorem{hypothesis}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'hypothesis'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//assumption">
      <xsl:text>\newtheorem{assumption}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'assumption'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <!-- DEFINITION-LIKE blocks, environments -->
  <!-- <xsl:if test="//definition">
      <xsl:text>%% Definition-like environments, normal text&#xa;</xsl:text>
      <xsl:text>%% Numbering is in sync with theorems, etc&#xa;</xsl:text>
      <xsl:text>\theoremstyle{definition}&#xa;</xsl:text>
      <xsl:if test="//definition">
          <xsl:text>\newtheorem{definition}[theorem]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'definition'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
  </xsl:if> -->
  <!-- REMARK-LIKE blocks, environments -->
  <xsl:if test="//remark or //convention or //note or //observation or //warning or //insight">
      <xsl:text>%% Remark-like environments, normal text&#xa;</xsl:text>
      <xsl:text>%% Numbering is in sync with theorems, etc&#xa;</xsl:text>
      <xsl:text>\theoremstyle{definition}&#xa;</xsl:text>
      <xsl:if test="//remark">
          <xsl:text>\newtheorem{remark}[theorem]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'remark'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="//convention">
          <xsl:text>\newtheorem{convention}[theorem]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'convention'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
      <!-- <xsl:if test="//note">
          <xsl:text>\newtheorem{note}[theorem]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'note'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if> -->
      <xsl:if test="//observation">
          <xsl:text>\newtheorem{observation}[theorem]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'observation'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="//warning">
          <xsl:text>\newtheorem{warning}[theorem]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'warning'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="//insight">
          <xsl:text>\newtheorem{insight}[theorem]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'insight'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
  </xsl:if>
  <!-- COMPUTATION-LIKE blocks, environments -->
  <xsl:if test="//computation or //technology">
      <xsl:text>%% Computation-like environments, normal text&#xa;</xsl:text>
      <xsl:text>%% Numbering is in sync with theorems, etc&#xa;</xsl:text>
      <xsl:text>\theoremstyle{definition}&#xa;</xsl:text>
      <xsl:if test="//computation">
          <xsl:text>\newtheorem{computation}[theorem]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'computation'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="//technology">
          <xsl:text>\newtheorem{technology}[theorem]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'technology'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
  </xsl:if>
  <!-- EXAMPLE-LIKE blocks, environments -->
  <xsl:if test="//example or //question or //problem">
      <xsl:text>%% Example-like environments, normal text&#xa;</xsl:text>
      <xsl:text>%% Numbering is in sync with theorems, etc&#xa;</xsl:text>
      <xsl:text>\theoremstyle{definition}&#xa;</xsl:text>
      <xsl:if test="//example">
<!-- Removed \newtheorem{exampel} -->
      </xsl:if>
      <xsl:if test="//question">
          <xsl:text>\newtheorem{question}[theorem]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'question'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="//problem">
          <xsl:text>\newtheorem{problem}[theorem]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'problem'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
  </xsl:if>
  <!-- PROJECT-LIKE blocks -->
  <xsl:if test="//project or //activity or //exploration or //investigation">
      <xsl:text>%% Numbering for Projects (independent of others)&#xa;</xsl:text>
      <xsl:text>%% Controlled by  numbering.projects.level  processing parameter&#xa;</xsl:text>
      <xsl:text>%% Always need a project environment to set base numbering scheme&#xa;</xsl:text>
      <xsl:text>%% even if document has no projectss (but has other blocks)&#xa;</xsl:text>
      <!-- http://tex.stackexchange.com/questions/155710/understanding-the-arguments-in-newtheorem-e-g-newtheoremtheoremtheoremsec/155714#155714 -->
      <xsl:text>\newtheorem{project}{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'project'" /></xsl:call-template>
      <xsl:text>}</xsl:text>
      <!-- See numbering-theorems variable being set in mathbook-common.xsl -->
      <xsl:if test="not($numbering-projects = 0)">
          <xsl:text>[</xsl:text>
          <xsl:call-template name="level-to-name">
              <xsl:with-param name="level" select="$numbering-projects" />
          </xsl:call-template>
          <xsl:text>]&#xa;</xsl:text>
      </xsl:if>
      <xsl:text>%% Project-like environments, normal text&#xa;</xsl:text>
      <xsl:text>\theoremstyle{definition}&#xa;</xsl:text>
      <xsl:if test="//activity">
          <xsl:text>\newtheorem{activity}[project]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'activity'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="//exploration">
          <xsl:text>\newtheorem{exploration}[project]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'exploration'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="//investigation">
          <xsl:text>\newtheorem{investigation}[project]{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'investigation'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
  </xsl:if>
  <xsl:if test="$document-root//assemblage">
      <xsl:text>%% begin: assemblage&#xa;</xsl:text>
      <xsl:text>%% minimally structured content, high visibility presentation&#xa;</xsl:text>
      <xsl:text>%% One optional argument (title) with default value blank&#xa;</xsl:text>
      <xsl:text>%% 3mm space below dropped title is increase over 2mm default&#xa;</xsl:text>
      <xsl:text>\newtcolorbox{assemblage}[1][]&#xa;</xsl:text>
      <xsl:text>  {breakable, skin=enhanced, arc=2ex, colback=blue!5, colframe=blue!75!black,&#xa;</xsl:text>
      <xsl:text>   colbacktitle=blue!20, coltitle=black, boxed title style={sharp corners, frame hidden},&#xa;</xsl:text>
      <xsl:text>   fonttitle=\bfseries, attach boxed title to top left={xshift=4mm,yshift=-3mm}, top=3mm, title={#1}}&#xa;</xsl:text>
      <xsl:text>%% end: assemblage&#xa;</xsl:text>
  </xsl:if>
  <!-- Following chould be duplicated as three environments, perhaps with  \tcbset{}   -->
  <!-- See https://tex.stackexchange.com/questions/180898/                             -->
  <!-- (is-it-possible-to-reuse-tcolorbox-definitions-in-another-tcolorbox-definition) -->
  <xsl:if test="$document-root//aside|$document-root//historical|$document-root//biographical">
      <xsl:text>%% aside, biographical, historical environments and style&#xa;</xsl:text>
      <xsl:text>\newtcolorbox{aside}[1]&#xa;</xsl:text>
      <xsl:text>  {breakable, skin=enhanced, sharp corners, colback=blue!3, colframe=blue!50!black,&#xa;</xsl:text>
      <xsl:text>   add to width=-1ex, shadow={1ex}{-1ex}{0ex}{black!50!white},&#xa;</xsl:text>
      <xsl:text>   coltitle=black, fonttitle=\bfseries, title=#1, detach title, before upper={\tcbtitle\ \ }}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//objectives">
      <xsl:text>%% objectives: early in a subdivision, introduction/list/conclusion&#xa;</xsl:text>
      <xsl:text>%% objectives environment and style&#xa;</xsl:text>
      <xsl:text>\newenvironment{objectives}[1]{\noindent\rule{\linewidth}{0.1ex}\newline{\textbf{{\large#1}}\par\smallskip}}{\par\noindent\rule{\linewidth}{0.1ex}\par\smallskip}&#xa;</xsl:text>
  </xsl:if>
  <!-- miscellaneous, not categorized yet -->
  <xsl:if test="$document-root//exercise">
      <xsl:text>%% Numbering for inline exercises is in sync with theorems, normal text&#xa;</xsl:text>
      <xsl:text>\theoremstyle{definition}&#xa;</xsl:text>
      <xsl:text>\newtheorem{exercise}[theorem]{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'exercise'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$document-root//list">
      <xsl:text>%% named list environment and style&#xa;</xsl:text>
      <xsl:text>\newtcolorbox{namedlistcontent}&#xa;</xsl:text>
      <xsl:text>  {breakable, skin=enhanced, sharp corners, colback=white, colframe=black,&#xa;</xsl:text>
      <xsl:text>   boxrule=0.15ex, left skip=3ex, right skip=3ex}&#xa;</xsl:text>
  </xsl:if>
  <!-- Localize various standard names in use         -->
  <!-- Many environments addressed upon creation above -->
  <!-- Figure and Table addressed elsewhere           -->
  <!-- Index, table of contents done elsewhere        -->
  <!-- http://www.tex.ac.uk/FAQ-fixnam.html           -->
  <!-- http://tex.stackexchange.com/questions/62020/how-to-change-the-word-proof-in-the-proof-environment -->
  <xsl:text>%% Localize LaTeX supplied names (possibly none)&#xa;</xsl:text>
  <!-- Localize AMS "proof" environment -->
  <xsl:if test="//proof">
      <xsl:text>\renewcommand*{\proofname}{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'proof'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//appendix">
      <xsl:text>\renewcommand*{\appendixname}{</xsl:text>
      <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'appendix'" /></xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$root/book">
      <xsl:if test="//part">
          <xsl:text>\renewcommand*{\partname}{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'part'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="//chapter">
          <xsl:text>\renewcommand*{\chaptername}{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'chapter'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
  </xsl:if>
  <xsl:if test="$root/article">
      <xsl:if test="//abstract">
          <xsl:text>\renewcommand*{\abstractname}{</xsl:text>
          <xsl:call-template name="type-name"><xsl:with-param name="string-id" select="'abstract'" /></xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
      </xsl:if>
  </xsl:if>
  <!-- Numbering Equations -->
  <!-- See numbering-equations variable being set in mathbook-common.xsl         -->
  <!-- With number="yes|no" on mrow, we must allow for the possibility of an md  -->
  <!-- variant having numbers (we could be more careful, but it is not critical) -->
  <xsl:if test="//men|//mdn|//md">
      <xsl:text>%% Equation Numbering&#xa;</xsl:text>
      <xsl:text>%% Controlled by  numbering.equations.level  processing parameter&#xa;</xsl:text>
      <xsl:text>\numberwithin{equation}{</xsl:text>
      <xsl:call-template name="level-to-name">
          <xsl:with-param name="level" select="$numbering-equations" />
      </xsl:call-template>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <!-- Tables -->
  <xsl:if test="//tabular">
      <xsl:text>%% For improved tables&#xa;</xsl:text>
      <xsl:text>\usepackage{array}&#xa;</xsl:text>
      <xsl:text>%% Some extra height on each row is desirable, especially with horizontal rules&#xa;</xsl:text>
      <xsl:text>%% Increment determined experimentally&#xa;</xsl:text>
      <xsl:text>\setlength{\extrarowheight}{0.2ex}&#xa;</xsl:text>
      <xsl:text>%% Define variable thickness horizontal rules, full and partial&#xa;</xsl:text>
      <xsl:text>%% Thicknesses are 0.03, 0.05, 0.08 in the  booktabs  package&#xa;</xsl:text>
      <xsl:text>\makeatletter&#xa;</xsl:text>
      <!-- http://tex.stackexchange.com/questions/119153/table-with-different-rule-widths -->
      <xsl:text>\newcommand{\hrulethin}  {\noalign{\hrule height 0.04em}}&#xa;</xsl:text>
      <xsl:text>\newcommand{\hrulemedium}{\noalign{\hrule height 0.07em}}&#xa;</xsl:text>
      <xsl:text>\newcommand{\hrulethick} {\noalign{\hrule height 0.11em}}&#xa;</xsl:text>
      <!-- TeX produced by a WeBWorK server may contain these booktabs table rule commands  -->
      <xsl:if test="//webwork[@source]">
          <xsl:text>% TeX imported from a WeBWorK server might use booktabs rule commands&#xa;</xsl:text>
          <xsl:text>% Replace/delete these three approximations if booktabs is loaded&#xa;</xsl:text>
          <xsl:text>\newcommand{\toprule}{\hrulethick}&#xa;</xsl:text>
          <xsl:text>\newcommand{\midrule}{\hrulemedium}&#xa;</xsl:text>
          <xsl:text>\newcommand{\bottomrule}{\hrulethick}&#xa;</xsl:text>
      </xsl:if>
      <!-- http://tex.stackexchange.com/questions/24549/horizontal-rule-with-adjustable-height-behaving-like-clinen-m -->
      <!-- Could preserve/restore \arrayrulewidth on entry/exit to tabular -->
      <!-- But we'll get cleaner source with this built into macros        -->
      <!-- Could condition \setlength debacle on the use of extpfeil       -->
      <!-- arrows (see discussion below)                                   -->
      <xsl:text>%% We preserve a copy of the \setlength package before other&#xa;</xsl:text>
      <xsl:text>%% packages (extpfeil) get a chance to load packages that redefine it&#xa;</xsl:text>
      <xsl:text>\let\oldsetlength\setlength&#xa;</xsl:text>
      <xsl:text>\newlength{\Oldarrayrulewidth}&#xa;</xsl:text>
      <xsl:text>\newcommand{\crulethin}[1]%&#xa;</xsl:text>
      <xsl:text>{\noalign{\global\oldsetlength{\Oldarrayrulewidth}{\arrayrulewidth}}%&#xa;</xsl:text>
      <xsl:text>\noalign{\global\oldsetlength{\arrayrulewidth}{0.04em}}\cline{#1}%&#xa;</xsl:text>
      <xsl:text>\noalign{\global\oldsetlength{\arrayrulewidth}{\Oldarrayrulewidth}}}%&#xa;</xsl:text>
      <xsl:text>\newcommand{\crulemedium}[1]%&#xa;</xsl:text>
      <xsl:text>{\noalign{\global\oldsetlength{\Oldarrayrulewidth}{\arrayrulewidth}}%&#xa;</xsl:text>
      <xsl:text>\noalign{\global\oldsetlength{\arrayrulewidth}{0.07em}}\cline{#1}%&#xa;</xsl:text>
      <xsl:text>\noalign{\global\oldsetlength{\arrayrulewidth}{\Oldarrayrulewidth}}}&#xa;</xsl:text>
      <xsl:text>\newcommand{\crulethick}[1]%&#xa;</xsl:text>
      <xsl:text>{\noalign{\global\oldsetlength{\Oldarrayrulewidth}{\arrayrulewidth}}%&#xa;</xsl:text>
      <xsl:text>\noalign{\global\oldsetlength{\arrayrulewidth}{0.11em}}\cline{#1}%&#xa;</xsl:text>
      <xsl:text>\noalign{\global\oldsetlength{\arrayrulewidth}{\Oldarrayrulewidth}}}&#xa;</xsl:text>
      <!-- http://tex.stackexchange.com/questions/119153/table-with-different-rule-widths -->
      <xsl:text>%% Single letter column specifiers defined via array package&#xa;</xsl:text>
      <xsl:text>\newcolumntype{A}{!{\vrule width 0.04em}}&#xa;</xsl:text>
      <xsl:text>\newcolumntype{B}{!{\vrule width 0.07em}}&#xa;</xsl:text>
      <xsl:text>\newcolumntype{C}{!{\vrule width 0.11em}}&#xa;</xsl:text>
      <xsl:text>\makeatother&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//cell/line">
      <xsl:text>\newcommand{\tablecelllines}[3]%&#xa;</xsl:text>
      <xsl:text>{\begin{tabular}[#2]{@{}#1@{}}#3\end{tabular}}&#xa;</xsl:text>
  </xsl:if>
  <!-- Float package allows for placment [H]ere                    -->
  <!-- Numbering happens along with theorem counter above,         -->
  <!-- but could be done with caption package hook, see both       -->
  <!-- New names are necessary to make "within" numbering possible -->
  <!-- http://tex.stackexchange.com/questions/127914/custom-counter-steps-twice-when-invoked-from-caption-using-caption-package -->
  <!-- http://tex.stackexchange.com/questions/160207/side-effect-of-caption-package-with-custom-counter                         -->
  <xsl:if test="$document-root//figure | $document-root//table | $document-root//listing | $document-root//list">
      <xsl:text>%% Figures, Tables, Listings, Named Lists, Floats&#xa;</xsl:text>
      <xsl:text>%% The [H]ere option of the float package fixes floats in-place,&#xa;</xsl:text>
      <xsl:text>%% in deference to web usage, where floats are totally irrelevant&#xa;</xsl:text>
      <xsl:text>%% You can remove some of this setup, to restore standard LaTeX behavior&#xa;</xsl:text>
      <xsl:text>%% HOWEVER, numbering of figures/tables AND theorems/examples/remarks, etc&#xa;</xsl:text>
      <xsl:text>%% may de-synchronize with the numbering in the HTML version&#xa;</xsl:text>
      <xsl:text>%% You can remove the "placement={H}" option to allow flotation and&#xa;</xsl:text>
      <xsl:text>%% preserve numbering, BUT the numbering may then appear "out-of-order"&#xa;</xsl:text>
      <xsl:text>%% Floating environments: http://tex.stackexchange.com/questions/95631/&#xa;</xsl:text>
      <!-- Float package defines the "H" specifier                       -->
      <!-- TODO: could conditionally load  float  for tables and figures -->
      <xsl:text>\usepackage{float}&#xa;</xsl:text>
      <!-- newfloat  package has \SetupFloatingEnvironment                -->
      <!-- \DeclareCaptionType is an undocumented command,                -->
      <!-- available in the  caption  package, by the same author         -->
      <!-- and also in the  subcaption  package, again by the same author -->
      <!-- See comment by this author, Axel Sommerfeldt in                -->
      <!-- https://tex.stackexchange.com/questions/115193/                -->
      <!-- (continuous-numbering-of-custom-float-with-caption-package)    -->
      <!-- capt-of  sounds appealing, but then can't bold-face labels (?) -->
      <xsl:text>\usepackage{newfloat}&#xa;</xsl:text>
      <xsl:text>\usepackage{caption}</xsl:text>
      <!-- First, captioned items subsidiary to a captioned figure -->
      <!-- Seem to be bold face without extra effort               -->
      <xsl:if test="$document-root//figure/sidebyside/*[caption]">
          <xsl:text>%% Captioned items inside side-by-side within captioned figure&#xa;</xsl:text>
          <xsl:text>\usepackage{subcaption}&#xa;</xsl:text>
          <xsl:text>\captionsetup[subfigure]{labelformat=simple}&#xa;</xsl:text>
          <xsl:text>\renewcommand\thesubfigure{(\alph{subfigure})}&#xa;</xsl:text>
      </xsl:if>
      <!-- if figures are numbered distinct from theorems, -->
      <!-- then we need to inquire about its level         -->
      <!-- $numbering-theorems from mathbook-common.xsl    -->
      <xsl:variable name="figure-levels">
          <xsl:choose>
              <xsl:when test="$b-number-figure-distinct">
                  <xsl:value-of select="$docinfo/numbering/figures/@level" />
              </xsl:when>
              <xsl:otherwise>
                  <xsl:value-of select="$numbering-theorems" />
              </xsl:otherwise>
          </xsl:choose>
      </xsl:variable>
      <!-- The "figure" counter is the lead for captioned items, -->
      <!-- so if these are distinct, we make this environment    -->
      <!-- just to make the counter, even if not explicitly used -->
      <xsl:if test="$document-root//figure or $b-number-figure-distinct">
          <xsl:text>%% Adjust stock figure environment so that it no longer floats&#xa;</xsl:text>
          <xsl:text>\SetupFloatingEnvironment{figure}{fileext=lof,placement={H},within=</xsl:text>
          <xsl:choose>
              <xsl:when test="$figure-levels = 0">
                  <xsl:text>none</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:call-template name="level-to-name">
                      <xsl:with-param name="level" select="$figure-levels" />
                  </xsl:call-template>
              </xsl:otherwise>
          </xsl:choose>
          <xsl:text>,name=</xsl:text>
          <xsl:call-template name="type-name">
                  <xsl:with-param name="string-id" select="'figure'" />
          </xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
          <xsl:text>\captionsetup[figure]{labelfont=bf}&#xa;</xsl:text>
          <xsl:if test="not($b-number-figure-distinct)">
              <xsl:text>%% http://tex.stackexchange.com/questions/16195&#xa;</xsl:text>
              <xsl:text>\makeatletter&#xa;</xsl:text>
              <xsl:text>\let\c@figure\c@theorem&#xa;</xsl:text>
              <xsl:text>\makeatother&#xa;</xsl:text>
          </xsl:if>
      </xsl:if>
      <xsl:if test="$document-root//table">
          <xsl:text>%% Adjust stock table environment so that it no longer floats&#xa;</xsl:text>
          <xsl:text>\SetupFloatingEnvironment{table}{fileext=lot,placement={H},within=</xsl:text>
          <xsl:choose>
              <xsl:when test="$figure-levels = 0">
                  <xsl:text>none</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:call-template name="level-to-name">
                      <xsl:with-param name="level" select="$figure-levels" />
                  </xsl:call-template>
              </xsl:otherwise>
          </xsl:choose>
          <xsl:text>,name=</xsl:text>
          <xsl:call-template name="type-name">
              <xsl:with-param name="string-id" select="'table'" />
          </xsl:call-template>
          <xsl:text>}&#xa;</xsl:text>
          <xsl:text>\captionsetup[table]{labelfont=bf}&#xa;</xsl:text>
          <!-- associate counter                  -->
          <!--   if independent, then with figure -->
          <!--   if grouped, then with theorem    -->
          <xsl:text>%% http://tex.stackexchange.com/questions/16195&#xa;</xsl:text>
          <xsl:text>\makeatletter&#xa;</xsl:text>
          <xsl:choose>
              <xsl:when test="$b-number-figure-distinct">
                  <xsl:text>\let\c@table\c@figure&#xa;</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:text>\let\c@table\c@theorem&#xa;</xsl:text>
              </xsl:otherwise>
          </xsl:choose>
          <xsl:text>\makeatother&#xa;</xsl:text>
      </xsl:if>
      <!-- Listings do not float yet have semantic captions -->
      <!-- New environment, new captiontype:                -->
      <!-- http://tex.stackexchange.com/questions/7210      -->
      <!-- Within numbering argument:                       -->
      <!-- http://tex.stackexchange.com/questions/115193    -->
      <!-- Caption formatting/style possibilities:          -->
      <!-- http://tex.stackexchange.com/questions/117531    -->
      <xsl:if test="$document-root//listing">
          <xsl:text>%% Create "listing" environment to hold program listings&#xa;</xsl:text>
          <xsl:text>%% The "lstlisting" environment defaults to allowing page-breaking,&#xa;</xsl:text>
          <xsl:text>%% so we do not use a floating environment, which would break this&#xa;</xsl:text>
          <!-- TODO: optionally force no-page-break with [float] on lstlisting? -->
          <xsl:text>\newenvironment{listing}{\par\bigskip\noindent}{}&#xa;</xsl:text>
          <xsl:text>%% New caption type for numbering, style, etc.&#xa;</xsl:text>
          <xsl:text>\DeclareCaptionType[within=</xsl:text>
          <xsl:choose>
              <xsl:when test="$figure-levels = 0">
                  <xsl:text>none</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:call-template name="level-to-name">
                      <xsl:with-param name="level" select="$figure-levels" />
                  </xsl:call-template>
              </xsl:otherwise>
          </xsl:choose>
          <xsl:text>]{listingcap}[</xsl:text>
          <xsl:call-template name="type-name">
              <xsl:with-param name="string-id" select="'listing'" />
          </xsl:call-template>
          <xsl:text>]&#xa;</xsl:text>
          <xsl:text>\captionsetup[listingcap]{labelfont=bf,aboveskip=1.0ex,belowskip=\baselineskip}&#xa;</xsl:text>
          <!-- associate counter                  -->
          <!--   if independent, then with figure -->
          <!--   if grouped, then with theorem    -->
          <xsl:text>%% http://tex.stackexchange.com/questions/16195&#xa;</xsl:text>
          <xsl:text>\makeatletter&#xa;</xsl:text>
          <xsl:choose>
              <xsl:when test="$b-number-figure-distinct">
                  <xsl:text>\let\c@listingcap\c@figure&#xa;</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:text>\let\c@listingcap\c@theorem&#xa;</xsl:text>
              </xsl:otherwise>
          </xsl:choose>
          <xsl:text>\makeatother&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="$document-root//list">
          <xsl:text>%% Create "named list" environment to hold lists with captions&#xa;</xsl:text>
          <xsl:text>%% We do not use a floating environment, so list can page-break&#xa;</xsl:text>
          <xsl:text>\newenvironment{namedlist}{\par\bigskip\noindent}{}&#xa;</xsl:text>
          <xsl:text>%% New caption type for numbering, style, etc.&#xa;</xsl:text>
          <xsl:text>\DeclareCaptionType[within=</xsl:text>
          <xsl:choose>
              <xsl:when test="$figure-levels = 0">
                  <xsl:text>none</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:call-template name="level-to-name">
                      <xsl:with-param name="level" select="$figure-levels" />
                  </xsl:call-template>
              </xsl:otherwise>
          </xsl:choose>
          <xsl:text>]{namedlistcap}[</xsl:text>
          <xsl:call-template name="type-name">
              <xsl:with-param name="string-id" select="'list'" />
          </xsl:call-template>
          <xsl:text>]&#xa;</xsl:text>
          <xsl:text>\captionsetup[namedlistcap]{labelfont=bf,aboveskip=1.0ex,belowskip=\baselineskip}&#xa;</xsl:text>
          <!-- associate counter                  -->
          <!--   if independent, then with figure -->
          <!--   if grouped, then with theorem    -->
          <xsl:text>%% http://tex.stackexchange.com/questions/16195&#xa;</xsl:text>
          <xsl:text>\makeatletter&#xa;</xsl:text>
          <xsl:choose>
              <xsl:when test="$b-number-figure-distinct">
                  <xsl:text>\let\c@namedlistcap\c@figure&#xa;</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                  <xsl:text>\let\c@namedlistcap\c@theorem&#xa;</xsl:text>
              </xsl:otherwise>
          </xsl:choose>
          <xsl:text>\makeatother&#xa;</xsl:text>
      </xsl:if>
  </xsl:if>
  <!-- Numbering Footnotes -->
  <xsl:if test="($numbering-footnotes != 0) and //fn">
      <xsl:text>%% Footnote Numbering&#xa;</xsl:text>
      <xsl:text>%% We reset the footnote counter, as given by numbering.footnotes.level&#xa;</xsl:text>
      <xsl:text>\makeatletter\@addtoreset{footnote}{</xsl:text>
      <xsl:call-template name="level-to-name">
          <xsl:with-param name="level" select="$numbering-footnotes" />
      </xsl:call-template>
      <xsl:text>}\makeatother&#xa;</xsl:text>
  </xsl:if>
  <!-- Poetry -->
  <xsl:if test="//poem">
      <xsl:text>%% Poetry Support&#xa;</xsl:text>
      <xsl:text>\newenvironment{poem}{\setlength{\parindent}{0em}}{}&#xa;</xsl:text>
      <xsl:text>\newcommand{\poemTitle}[1]{\begin{center}\large\textbf{#1}\end{center}}&#xa;</xsl:text>
      <xsl:text>\newcommand{\poemIndent}{\hspace{2 em}}&#xa;</xsl:text>
      <xsl:text>\newenvironment{stanza}{\vspace{0.25 em}\hangindent=4em}{\vspace{1 em}}&#xa;</xsl:text>
      <xsl:text>\newcommand{\stanzaTitle}[1]{{\centering\textbf{#1}\par}\vspace{-\parskip}}&#xa;</xsl:text>
      <xsl:text>\newcommand{\poemauthorleft}[1]{\vspace{-1em}\begin{flushleft}\textit{#1}\end{flushleft}}&#xa;</xsl:text>
      <xsl:text>\newcommand{\poemauthorcenter}[1]{\vspace{-1em}\begin{center}\textit{#1}\end{center}}&#xa;</xsl:text>
      <xsl:text>\newcommand{\poemauthorright}[1]{\vspace{-1em}\begin{flushright}\textit{#1}\end{flushright}}&#xa;</xsl:text>
      <xsl:text>\newcommand{\poemlineleft}[1]{{\raggedright{#1}\par}\vspace{-\parskip}}&#xa;</xsl:text>
      <xsl:text>\newcommand{\poemlinecenter}[1]{{\centering{#1}\par}\vspace{-\parskip}}&#xa;</xsl:text>
      <xsl:text>\newcommand{\poemlineright}[1]{{\raggedleft{#1}\par}\vspace{-\parskip}}&#xa;</xsl:text>
  </xsl:if>
  <!-- Music -->
  <xsl:if test="//n or //scaledeg or //chord">
      <xsl:text>%% Musical Symbol Support&#xa;</xsl:text>
      <xsl:text>\ifthenelse{\boolean{xetex}}{&#xa;</xsl:text>
      <xsl:text>%% begin: xelatex-specific configuration&#xa;</xsl:text>
      <xsl:text>%% lilyglyphs.sty in Ubuntu/Debian texlive-music&#xa;</xsl:text>
      <xsl:text>\usepackage{lilyglyphs}&#xa;</xsl:text>
      <xsl:text>\lilyGlobalOptions{scale=0.8}&#xa;</xsl:text>
      <!-- Create alias to lilyglyphs command with common name -->
      <xsl:text>\newcommand*{\doubleflat}{\flatflat}&#xa;</xsl:text>
      <xsl:text>%% end: xelatex-specific configuration&#xa;</xsl:text>
      <xsl:text>}{&#xa;</xsl:text>
      <xsl:text>%% begin: pdflatex-specific configuration&#xa;</xsl:text>
      <!-- Pulling accidentals from "musixtex" font -->
      <!-- http://tex.stackexchange.com/questions/207261/how-do-i-produce-a-double-flat-symbol-edit -->
      <xsl:text>\DeclareFontFamily{U}{musix}{}%&#xa;</xsl:text>
      <xsl:text>\DeclareFontShape{U}{musix}{m}{n}{%&#xa;</xsl:text>
      <xsl:text>&lt;-12&gt;   musix11&#xa;</xsl:text>
      <xsl:text>&lt;12-15&gt; musix13&#xa;</xsl:text>
      <xsl:text>&lt;15-18&gt; musix16&#xa;</xsl:text>
      <xsl:text>&lt;18-23&gt; musix20&#xa;</xsl:text>
      <xsl:text>&lt;23-&gt;   musix29&#xa;</xsl:text>
      <xsl:text>}{}%&#xa;</xsl:text>
      <xsl:text>%% We grab all five accidentals from the musix font so they are usable in both math and text mode&#xa;</xsl:text>
      <xsl:text>\renewcommand*\flat{\raisebox{0.5ex}{\usefont{U}{musix}{m}{n}\selectfont{2}}}&#xa;</xsl:text>
      <xsl:text>\newcommand*\doubleflat{\raisebox{0.5ex}{\usefont{U}{musix}{m}{n}\selectfont{3}}}&#xa;</xsl:text>
      <xsl:text>\renewcommand*\sharp{\raisebox{0.5ex}{\usefont{U}{musix}{m}{n}\selectfont{4}}}&#xa;</xsl:text>
      <xsl:text>\newcommand*\doublesharp{\raisebox{0.5ex}{\usefont{U}{musix}{m}{n}\selectfont{5}}}&#xa;</xsl:text>
      <xsl:text>\renewcommand*\natural{\raisebox{0.5ex}{\usefont{U}{musix}{m}{n}\selectfont{6}}}&#xa;</xsl:text>
      <xsl:text>%% end: pdflatex-specific configuration&#xa;</xsl:text>
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <!-- Inconsolata font, sponsored by TUG: http://levien.com/type/myfonts/inconsolata.html            -->
  <!-- As seen on: http://tex.stackexchange.com/questions/50810/good-monospace-font-for-code-in-latex -->
  <!-- "Fonts for Displaying Program Code in LaTeX":  http://nepsweb.co.uk/docs%/progfonts.pdf        -->
  <!-- Fonts and xelatex:  http://tex.stackexchange.com/questions/102525/use-type-1-fonts-with-xelatex -->
  <!--   http://tex.stackexchange.com/questions/179448/beramono-in-xetex -->
  <!-- http://tex.stackexchange.com/questions/25249/how-do-i-use-a-particular-font-for-a-small-section-of-text-in-my-document -->
  <!-- Bitstream Vera Font names within: https://github.com/timfel/texmf/blob/master/fonts/map/vtex/bera.ali -->
  <!-- Coloring listings: http://tex.stackexchange.com/questions/18376/beautiful-listing-for-csharp -->
  <!-- Song and Dance for font changes: http://jevopi.blogspot.com/2010/03/nicely-formatted-listings-in-latex-with.html -->
   <xsl:if test="$document-root//sage or $document-root//program">
      <xsl:text>%% Program listing support: for listings, programs, and Sage code&#xa;</xsl:text>
      <xsl:text>\usepackage{listings}&#xa;</xsl:text>
      <xsl:text>%% We define the listings font style to be the default "ttfamily"&#xa;</xsl:text>
      <xsl:text>%% To fix hyphens/dashes rendered in PDF as fancy minus signs by listing&#xa;</xsl:text>
      <xsl:text>%% http://tex.stackexchange.com/questions/33185/listings-package-changes-hyphens-to-minus-signs&#xa;</xsl:text>
      <xsl:text>\makeatletter&#xa;</xsl:text>
      <xsl:text>\lst@CCPutMacro\lst@ProcessOther {"2D}{\lst@ttfamily{-{}}{-{}}}&#xa;</xsl:text>
      <xsl:text>\@empty\z@\@empty&#xa;</xsl:text>
      <xsl:text>\makeatother&#xa;</xsl:text>
      <xsl:text>\ifthenelse{\boolean{xetex}}{}{%&#xa;</xsl:text>
      <xsl:text>%% begin: pdflatex-specific listings configuration&#xa;</xsl:text>
      <xsl:text>%% translate U+0080 - U+00F0 to their textmode LaTeX equivalents&#xa;</xsl:text>
      <xsl:text>%% Data originally from https://www.w3.org/Math/characters/unicode.xml, 2016-07-23&#xa;</xsl:text>
      <xsl:text>%% Lines marked in XSL with "$" were converted from mathmode to textmode&#xa;</xsl:text>
      <!-- encoding, etc: http://tex.stackexchange.com/questions/24528/ -->
      <!-- Format: {Unicode}{TeX}{rendered-length} Unicode name (in numerical order) -->
      <xsl:text>\lstset{extendedchars=true}&#xa;</xsl:text>
      <xsl:text>\lstset{literate=</xsl:text>
      <xsl:text>{&#x00A0;}{{~}}{1}</xsl:text>    <!--NO-BREAK SPACE-->
      <xsl:text>{&#x00A1;}{{\textexclamdown }}{1}</xsl:text>    <!--INVERTED EXCLAMATION MARK-->
      <xsl:text>{&#x00A2;}{{\textcent }}{1}</xsl:text>    <!--CENT SIGN-->
      <xsl:text>{&#x00A3;}{{\textsterling }}{1}</xsl:text>    <!--POUND SIGN-->
      <xsl:text>{&#x00A4;}{{\textcurrency }}{1}</xsl:text>    <!--CURRENCY SIGN-->
      <xsl:text>{&#x00A5;}{{\textyen }}{1}</xsl:text>    <!--YEN SIGN-->
      <xsl:text>{&#x00A6;}{{\textbrokenbar }}{1}</xsl:text>    <!--BROKEN BAR-->
      <xsl:text>{&#x00A7;}{{\textsection }}{1}</xsl:text>    <!--SECTION SIGN-->
      <xsl:text>{&#x00A8;}{{\textasciidieresis }}{1}</xsl:text>    <!--DIAERESIS-->
      <xsl:text>{&#x00A9;}{{\textcopyright }}{1}</xsl:text>    <!--COPYRIGHT SIGN-->
      <xsl:text>{&#x00AA;}{{\textordfeminine }}{1}</xsl:text>    <!--FEMININE ORDINAL INDICATOR-->
      <xsl:text>{&#x00AB;}{{\guillemotleft }}{1}</xsl:text>    <!--LEFT-POINTING DOUBLE ANGLE QUOTATION MARK-->
      <xsl:text>{&#x00AC;}{{\textlnot }}{1}</xsl:text>    <!--NOT SIGN-->  <!-- $ -->
      <xsl:text>{&#x00AD;}{{\-}}{1}</xsl:text>    <!--SOFT HYPHEN-->
      <xsl:text>{&#x00AE;}{{\textregistered }}{1}</xsl:text>    <!--REGISTERED SIGN-->
      <xsl:text>{&#x00AF;}{{\textasciimacron }}{1}</xsl:text>    <!--MACRON-->
      <xsl:text>{&#x00B0;}{{\textdegree }}{1}</xsl:text>    <!--DEGREE SIGN-->
      <xsl:text>{&#x00B1;}{{\textpm }}{1}</xsl:text>    <!--PLUS-MINUS SIGN-->  <!-- $ -->
      <xsl:text>{&#x00B2;}{{\texttwosuperior }}{1}</xsl:text>    <!--SUPERSCRIPT TWO-->  <!-- $ -->
      <xsl:text>{&#x00B3;}{{\textthreesuperior }}{1}</xsl:text>    <!--SUPERSCRIPT THREE-->   <!-- $ -->
      <xsl:text>{&#x00B4;}{{\textasciiacute }}{1}</xsl:text>    <!--ACUTE ACCENT-->
      <xsl:text>{&#x00B5;}{{\textmu }}{1}</xsl:text>    <!--MICRO SIGN-->  <!-- $ -->
      <xsl:text>{&#x00B6;}{{\textparagraph }}{1}</xsl:text>    <!--PILCROW SIGN-->
      <xsl:text>{&#x00B7;}{{\textperiodcentered }}{1}</xsl:text>    <!--MIDDLE DOT-->  <!-- $ -->
      <xsl:text>{&#x00B8;}{{\c{}}}{1}</xsl:text>    <!--CEDILLA-->
      <xsl:text>{&#x00B9;}{{\textonesuperior }}{1}</xsl:text>    <!--SUPERSCRIPT ONE-->  <!-- $ -->
      <xsl:text>{&#x00BA;}{{\textordmasculine }}{1}</xsl:text>    <!--MASCULINE ORDINAL INDICATOR-->
      <xsl:text>{&#x00BB;}{{\guillemotright }}{1}</xsl:text>    <!--RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK-->
      <xsl:text>{&#x00BC;}{{\textonequarter }}{1}</xsl:text>    <!--VULGAR FRACTION ONE QUARTER-->
      <xsl:text>{&#x00BD;}{{\textonehalf }}{1}</xsl:text>    <!--VULGAR FRACTION ONE HALF-->
      <xsl:text>{&#x00BE;}{{\textthreequarters }}{1}</xsl:text>    <!--VULGAR FRACTION THREE QUARTERS-->
      <xsl:text>{&#x00BF;}{{\textquestiondown }}{1}</xsl:text>    <!--INVERTED QUESTION MARK-->
      <xsl:text>{&#x00C0;}{{\`{A}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER A WITH GRAVE-->
      <xsl:text>{&#x00C1;}{{\'{A}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER A WITH ACUTE-->
      <xsl:text>{&#x00C2;}{{\^{A}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER A WITH CIRCUMFLEX-->
      <xsl:text>{&#x00C3;}{{\~{A}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER A WITH TILDE-->
      <xsl:text>{&#x00C4;}{{\"{A}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER A WITH DIAERESIS-->
      <xsl:text>{&#x00C5;}{{\AA }}{1}</xsl:text>    <!--LATIN CAPITAL LETTER A WITH RING ABOVE-->
      <xsl:text>{&#x00C6;}{{\AE }}{1}</xsl:text>    <!--LATIN CAPITAL LETTER AE-->
      <xsl:text>{&#x00C7;}{{\c{C}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER C WITH CEDILLA-->
      <xsl:text>{&#x00C8;}{{\`{E}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER E WITH GRAVE-->
      <xsl:text>{&#x00C9;}{{\'{E}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER E WITH ACUTE-->
      <xsl:text>{&#x00CA;}{{\^{E}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER E WITH CIRCUMFLEX-->
      <xsl:text>{&#x00CB;}{{\"{E}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER E WITH DIAERESIS-->
      <xsl:text>{&#x00CC;}{{\`{I}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER I WITH GRAVE-->
      <xsl:text>{&#x00CD;}{{\'{I}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER I WITH ACUTE-->
      <xsl:text>{&#x00CE;}{{\^{I}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER I WITH CIRCUMFLEX-->
      <xsl:text>{&#x00CF;}{{\"{I}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER I WITH DIAERESIS-->
      <xsl:text>{&#x00D0;}{{\DH }}{1}</xsl:text>    <!--LATIN CAPITAL LETTER ETH-->
      <xsl:text>{&#x00D1;}{{\~{N}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER N WITH TILDE-->
      <xsl:text>{&#x00D2;}{{\`{O}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER O WITH GRAVE-->
      <xsl:text>{&#x00D3;}{{\'{O}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER O WITH ACUTE-->
      <xsl:text>{&#x00D4;}{{\^{O}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER O WITH CIRCUMFLEX-->
      <xsl:text>{&#x00D5;}{{\~{O}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER O WITH TILDE-->
      <xsl:text>{&#x00D6;}{{\"{O}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER O WITH DIAERESIS-->
      <xsl:text>{&#x00D7;}{{\texttimes }}{1}</xsl:text>    <!--MULTIPLICATION SIGN-->
      <xsl:text>{&#x00D8;}{{\O }}{1}</xsl:text>    <!--LATIN CAPITAL LETTER O WITH STROKE-->
      <xsl:text>{&#x00D9;}{{\`{U}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER U WITH GRAVE-->
      <xsl:text>{&#x00DA;}{{\'{U}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER U WITH ACUTE-->
      <xsl:text>{&#x00DB;}{{\^{U}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER U WITH CIRCUMFLEX-->
      <xsl:text>{&#x00DC;}{{\"{U}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER U WITH DIAERESIS-->
      <xsl:text>{&#x00DD;}{{\'{Y}}}{1}</xsl:text>    <!--LATIN CAPITAL LETTER Y WITH ACUTE-->
      <xsl:text>{&#x00DE;}{{\TH }}{1}</xsl:text>    <!--LATIN CAPITAL LETTER THORN-->
      <xsl:text>{&#x00DF;}{{\ss }}{1}</xsl:text>    <!--LATIN SMALL LETTER SHARP S-->
      <xsl:text>{&#x00E0;}{{\`{a}}}{1}</xsl:text>    <!--LATIN SMALL LETTER A WITH GRAVE-->
      <xsl:text>{&#x00E1;}{{\'{a}}}{1}</xsl:text>    <!--LATIN SMALL LETTER A WITH ACUTE-->
      <xsl:text>{&#x00E2;}{{\^{a}}}{1}</xsl:text>    <!--LATIN SMALL LETTER A WITH CIRCUMFLEX-->
      <xsl:text>{&#x00E3;}{{\~{a}}}{1}</xsl:text>    <!--LATIN SMALL LETTER A WITH TILDE-->
      <xsl:text>{&#x00E4;}{{\"{a}}}{1}</xsl:text>    <!--LATIN SMALL LETTER A WITH DIAERESIS-->
      <xsl:text>{&#x00E5;}{{\aa }}{1}</xsl:text>    <!--LATIN SMALL LETTER A WITH RING ABOVE-->
      <xsl:text>{&#x00E6;}{{\ae }}{1}</xsl:text>    <!--LATIN SMALL LETTER AE-->
      <xsl:text>{&#x00E7;}{{\c{c}}}{1}</xsl:text>    <!--LATIN SMALL LETTER C WITH CEDILLA-->
      <xsl:text>{&#x00E8;}{{\`{e}}}{1}</xsl:text>    <!--LATIN SMALL LETTER E WITH GRAVE-->
      <xsl:text>{&#x00E9;}{{\'{e}}}{1}</xsl:text>    <!--LATIN SMALL LETTER E WITH ACUTE-->
      <xsl:text>{&#x00EA;}{{\^{e}}}{1}</xsl:text>    <!--LATIN SMALL LETTER E WITH CIRCUMFLEX-->
      <xsl:text>{&#x00EB;}{{\"{e}}}{1}</xsl:text>    <!--LATIN SMALL LETTER E WITH DIAERESIS-->
      <xsl:text>{&#x00EC;}{{\`{\i}}}{1}</xsl:text>    <!--LATIN SMALL LETTER I WITH GRAVE-->
      <xsl:text>{&#x00ED;}{{\'{\i}}}{1}</xsl:text>    <!--LATIN SMALL LETTER I WITH ACUTE-->
      <xsl:text>{&#x00EE;}{{\^{\i}}}{1}</xsl:text>    <!--LATIN SMALL LETTER I WITH CIRCUMFLEX-->
      <xsl:text>{&#x00EF;}{{\"{\i}}}{1}</xsl:text>    <!--LATIN SMALL LETTER I WITH DIAERESIS-->
      <xsl:text>{&#x00F0;}{{\dh }}{1}</xsl:text>    <!--LATIN SMALL LETTER ETH-->
      <xsl:text>{&#x00F1;}{{\~{n}}}{1}</xsl:text>    <!--LATIN SMALL LETTER N WITH TILDE-->
      <xsl:text>{&#x00F2;}{{\`{o}}}{1}</xsl:text>    <!--LATIN SMALL LETTER O WITH GRAVE-->
      <xsl:text>{&#x00F3;}{{\'{o}}}{1}</xsl:text>    <!--LATIN SMALL LETTER O WITH ACUTE-->
      <xsl:text>{&#x00F4;}{{\^{o}}}{1}</xsl:text>    <!--LATIN SMALL LETTER O WITH CIRCUMFLEX-->
      <xsl:text>{&#x00F5;}{{\~{o}}}{1}</xsl:text>    <!--LATIN SMALL LETTER O WITH TILDE-->
      <xsl:text>{&#x00F6;}{{\"{o}}}{1}</xsl:text>    <!--LATIN SMALL LETTER O WITH DIAERESIS-->
      <xsl:text>{&#x00F7;}{{\textdiv }}{1}</xsl:text>    <!--DIVISION SIGN-->  <!-- $ -->
      <xsl:text>{&#x00F8;}{{\o }}{1}</xsl:text>    <!--LATIN SMALL LETTER O WITH STROKE-->
      <xsl:text>{&#x00F9;}{{\`{u}}}{1}</xsl:text>    <!--LATIN SMALL LETTER U WITH GRAVE-->
      <xsl:text>{&#x00FA;}{{\'{u}}}{1}</xsl:text>    <!--LATIN SMALL LETTER U WITH ACUTE-->
      <xsl:text>{&#x00FB;}{{\^{u}}}{1}</xsl:text>    <!--LATIN SMALL LETTER U WITH CIRCUMFLEX-->
      <xsl:text>{&#x00FC;}{{\"{u}}}{1}</xsl:text>    <!--LATIN SMALL LETTER U WITH DIAERESIS-->
      <xsl:text>{&#x00FD;}{{\'{y}}}{1}</xsl:text>    <!--LATIN SMALL LETTER Y WITH ACUTE-->
      <xsl:text>{&#x00FE;}{{\th }}{1}</xsl:text>    <!--LATIN SMALL LETTER THORN-->
      <xsl:text>{&#x00FF;}{{\"{y}}}{1}</xsl:text>    <!--LATIN SMALL LETTER Y WITH DIAERESIS-->
      <xsl:text>}&#xa;</xsl:text> <!-- end of literate set -->
      <xsl:text>%% end: pdflatex-specific listings configuration&#xa;</xsl:text>
      <xsl:text>}&#xa;</xsl:text>
      <xsl:text>%% End of generic listing adjustments&#xa;</xsl:text>
      <xsl:if test="$document-root//program">
          <xsl:text>%% Program listings via the listings package&#xa;</xsl:text>
          <xsl:text>%% Line breaking, language per instance, frames, boxes&#xa;</xsl:text>
          <xsl:text>%% First a universal color scheme for parts of any language&#xa;</xsl:text>
          <xsl:if test="$latex.print='no'" >
              <xsl:text>%% Colors match a subset of Google prettify "Default" style&#xa;</xsl:text>
              <xsl:text>%% Set latex.print='yes' to get all black&#xa;</xsl:text>
              <xsl:text>%% http://code.google.com/p/google-code-prettify/source/browse/trunk/src/prettify.css&#xa;</xsl:text>
              <xsl:text>\definecolor{identifiers}{rgb}{0.375,0,0.375}&#xa;</xsl:text>
              <xsl:text>\definecolor{comments}{rgb}{0.5,0,0}&#xa;</xsl:text>
              <xsl:text>\definecolor{strings}{rgb}{0,0.5,0}&#xa;</xsl:text>
              <xsl:text>\definecolor{keywords}{rgb}{0,0,0.5}&#xa;</xsl:text>
          </xsl:if>
          <xsl:if test="$latex.print='yes'" >
              <xsl:text>%% All-black colors&#xa;</xsl:text>
              <xsl:text>%% Set latex.print='no' to get colors&#xa;</xsl:text>
              <xsl:text>\definecolor{identifiers}{rgb}{0,0,0}&#xa;</xsl:text>
              <xsl:text>\definecolor{comments}{rgb}{0,0,0}&#xa;</xsl:text>
              <xsl:text>\definecolor{strings}{rgb}{0,0,0}&#xa;</xsl:text>
              <xsl:text>\definecolor{keywords}{rgb}{0,0,0}&#xa;</xsl:text>
          </xsl:if>
          <xsl:text>%% We define a null language, free of any formatting or style&#xa;</xsl:text>
          <xsl:text>%% for use when a language is not supported, or pseudo-code&#xa;</xsl:text>
          <xsl:text>\lstdefinelanguage{none}{identifierstyle=,commentstyle=,stringstyle=,keywordstyle=}&#xa;</xsl:text>
          <xsl:text>%% A style, both text behavior and decorations all at once&#xa;</xsl:text>
          <xsl:text>\lstdefinestyle{programstyle}{breaklines=true,breakatwhitespace=true,columns=fixed,frame=leftline,framesep=3ex, xleftmargin=3ex,&#xa;</xsl:text>
          <xsl:text>basicstyle=\small\ttfamily,identifierstyle=\color{identifiers},commentstyle=\color{comments},stringstyle=\color{strings},keywordstyle=\color{keywords}}&#xa;</xsl:text>
          <xsl:text>%% The environments manufactured by the listings package&#xa;</xsl:text>
          <xsl:text>%% Two environments, one full-width, the other boxed for side-by-sides&#xa;</xsl:text>
          <xsl:text>%% "program" expects a language argument only&#xa;</xsl:text>
          <xsl:text>%% "programbox" expects a language and a linewidth&#xa;</xsl:text>
          <xsl:text>\lstnewenvironment{program}[1][]&#xa;</xsl:text>
          <xsl:text>  {\lstset{style=programstyle,#1}}&#xa;</xsl:text>
          <xsl:text>  {}&#xa;</xsl:text>
          <xsl:text>\lstnewenvironment{programbox}[1][]&#xa;</xsl:text>
          <xsl:text>  {\lstset{style=programstyle,#1}}&#xa;</xsl:text>
          <xsl:text>  {}&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="$document-root//sage">
          <xsl:text>%% Sage's blue is 50%, we go way lighter (blue!05 would work)&#xa;</xsl:text>
          <xsl:text>\definecolor{sageblue}{rgb}{0.95,0.95,1}&#xa;</xsl:text>
          <xsl:text>%% Sage input, listings package: Python syntax, boxed, colored, line breaking&#xa;</xsl:text>
          <xsl:text>%% To be flush with surrounding text's margins, set&#xa;</xsl:text>
          <xsl:text>%% xmargins to be sum of framerule, framesep, and epsilon (~0.25pt)&#xa;</xsl:text>
          <xsl:text>%% space between input/output comes from input style "belowskip",&#xa;</xsl:text>
          <xsl:text>%% by giving output an aboveskip of zero&#xa;</xsl:text>
          <xsl:text>\lstdefinestyle{sageinputstyle}{language=Python,breaklines=true,breakatwhitespace=true,%&#xa;</xsl:text>
          <xsl:text>basicstyle=\small\ttfamily,columns=fixed,frame=single,backgroundcolor=\color{sageblue},%&#xa;</xsl:text>
          <xsl:text>framerule=0.5pt,framesep=4pt,xleftmargin=4.75pt,xrightmargin=4.75pt}&#xa;</xsl:text>
          <xsl:text>%% Sage output, similar, but not boxed, not colored&#xa;</xsl:text>
          <xsl:text>\lstdefinestyle{sageoutputstyle}{language=Python,breaklines=true,%&#xa;</xsl:text>
          <xsl:text>breakatwhitespace=true,basicstyle=\small\ttfamily,columns=fixed,aboveskip=0pt}&#xa;</xsl:text>
          <xsl:text>%% The environments manufactured by the listings package&#xa;</xsl:text>
          <xsl:text>\lstnewenvironment{sageinput}&#xa;</xsl:text>
          <xsl:text>  {\lstset{style=sageinputstyle}}&#xa;</xsl:text>
          <xsl:text>  {}&#xa;</xsl:text>
          <xsl:text>\lstnewenvironment{sageoutput}&#xa;</xsl:text>
          <xsl:text>  {\lstset{style=sageoutputstyle}}&#xa;</xsl:text>
          <xsl:text>  {}&#xa;</xsl:text>
      </xsl:if>
  </xsl:if>
  <xsl:if test="$document-root//console or $document-root//pre or $document-root//cd">
      <xsl:text>%% Fancy Verbatim for consoles, preformatted, code display&#xa;</xsl:text>
      <xsl:text>\usepackage{fancyvrb}&#xa;</xsl:text>
      <xsl:if test="//pre">
          <xsl:text>%% Pre-formatted text, a peer of paragraphs&#xa;</xsl:text>
          <xsl:text>\DefineVerbatimEnvironment{preformatted}{Verbatim}{}&#xa;</xsl:text>
          <xsl:text>%% Pre-formatted text, as panel of a sidebyside&#xa;</xsl:text>
          <xsl:text>%% Default alignment is the bottom of the box on the baseline&#xa;</xsl:text>
          <xsl:text>\DefineVerbatimEnvironment{preformattedbox}{BVerbatim}{}&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="$document-root//cd">
          <xsl:text>%% code display (cd), by analogy with math display (md)&#xa;</xsl:text>
          <xsl:text>%% savebox, lrbox, etc to achieve centering&#xa;</xsl:text>
          <!-- https://tex.stackexchange.com/questions/182476/how-do-i-center-a-boxed-verbatim -->
          <!-- trying "\centering" here was a disaster -->
          <xsl:text>\newsavebox{\codedisplaybox}&#xa;</xsl:text>
          <xsl:text>\newenvironment{codedisplay}&#xa;</xsl:text>
          <xsl:text>{\VerbatimEnvironment\begin{center}\begin{lrbox}{\codedisplaybox}\begin{BVerbatim}}&#xa;</xsl:text>
          <xsl:text>{\end{BVerbatim}\end{lrbox}\usebox{\codedisplaybox}\end{center}}&#xa;</xsl:text>
      </xsl:if>
      <xsl:if test="$document-root//console">
          <xsl:text>%% Console session with prompt, input, output&#xa;</xsl:text>
          <xsl:text>%% Make a console environment from fancyvrb BVerbatim environment&#xa;</xsl:text>
          <xsl:text>%% Specify usual escape, begin group, end group characters&#xa;</xsl:text>
          <xsl:text>%% (boxed variant is useful for constructing sidebyside panels)&#xa;</xsl:text>
          <xsl:text>%% (BVerbatim environment allows for line numbers, make feature request?)&#xa;</xsl:text>
          <!-- "box verbatim" since could be used in a sidebyside panel, additional options are        -->
          <!-- trivial: numbers=left, stepnumber=5 (can mimic in HTML with counting recursive routine) -->
          <xsl:text>\DefineVerbatimEnvironment{console}{BVerbatim}{fontsize=\small,commandchars=\\\{\}}&#xa;</xsl:text>
          <xsl:text>%% A semantic macro for the user input portion&#xa;</xsl:text>
          <xsl:text>%% We define this in the traditional way,&#xa;</xsl:text>
          <xsl:text>%% but may realize it with different LaTeX escape characters&#xa;</xsl:text>
          <xsl:text>\newcommand{\consoleprompt}[1]{#1}&#xa;</xsl:text>
          <xsl:text>\newcommand{\consoleinput}[1]{\textbf{#1}}&#xa;</xsl:text>
          <xsl:text>\newcommand{\consoleoutput}[1]{#1}&#xa;</xsl:text>
      </xsl:if>
  </xsl:if>
  <xsl:if test="//tikz">
      <xsl:message>MBX:WARNING: the "tikz" element is deprecated (2015-10-16), use "latex-image-code" tag inside an "image" tag, and include the tikz package and relevant libraries in docinfo/latex-image-preamble</xsl:message>
      <xsl:text>%% Tikz graphics&#xa;</xsl:text>
      <xsl:text>\usepackage{tikz}&#xa;</xsl:text>
      <xsl:text>\usetikzlibrary{backgrounds}&#xa;</xsl:text>
      <xsl:text>\usetikzlibrary{arrows,matrix}&#xa;</xsl:text>
  </xsl:if>
  <!-- TODO:  \showidx package as part of a draft mode, prints entries in margin -->
   <xsl:if test="//ol[@cols] or //ul[@cols] or //dl[@cols]">
      <xsl:text>%% Multiple column, column-major lists&#xa;</xsl:text>
      <xsl:text>\usepackage{multicol}&#xa;</xsl:text>
  </xsl:if>
<!-- Removed enumitem stuff -->

  <xsl:if test="//webwork[@source]">
      <xsl:text>%% Package for breakable boxes on WeBWorK problems from server LaTeX&#xa;</xsl:text>
      <xsl:text>\usepackage{mdframed}&#xa;</xsl:text>
      <xsl:text>%% WeBWorK problem style&#xa;</xsl:text>
      <xsl:text>\mdfdefinestyle{webwork-server}{framemethod=default, linewidth=2pt}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//docinfo/logo">
      <xsl:text>%% Package for precise image placement (for logos on pages)&#xa;</xsl:text>
      <xsl:text>\usepackage{eso-pic}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//notation or //list-of">
      <xsl:text>%% Package for tables spanning several pages&#xa;</xsl:text>
      <xsl:text>\usepackage{longtable}&#xa;</xsl:text>
  </xsl:if>
  <!-- This is the place to add part numbers to the numbering, which   -->
  <!-- is *not* the default LaTeX behavior.  The \p@section scheme     -->
  <!-- is complicated, leading to about ten constructions like         -->
  <!--                                                                 -->
  <!-- \ifdefined\p@namedlist\renewcommand{\p@namedlist}{\thepart.}\fi -->
  <!--                                                                 -->
  <!-- Advice is to redefine these *before* loading hyperref           -->
  <!-- https://tex.stackexchange.com/questions/172962                  -->
  <!-- (hyperref-include-part-number-for-cross-references-to-chapters) -->
  <!-- Easier is to just adjust the chapter number, which filters down -->
  <!-- into anything that uses the chapter, though perhaps per-part    -->
  <!-- numbering will still need something?                            -->
  <!--                                                                 -->
  <!-- \renewcommand{\thechapter}{\thepart.\arabic{chapter}}           -->
  <!--                                                                 -->
  <!-- http://tex.stackexchange.com/questions/106159/why-i-shouldnt-load-pdftex-option-with-hyperref -->
  <xsl:text>%% hyperref driver does not need to be specified, it will be detected&#xa;</xsl:text>
  <xsl:text>\usepackage{hyperref}&#xa;</xsl:text>
  <!-- http://tex.stackexchange.com/questions/79051/how-to-style-text-in-hyperref-url -->
  <xsl:if test="//url">
  <xsl:text>%% configure hyperref's  \url  to match listings' inline verbatim&#xa;</xsl:text>
      <xsl:text>\renewcommand\UrlFont{\small\ttfamily}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$latex.print='no'">
      <xsl:text>%% Hyperlinking active in PDFs, all links solid and blue&#xa;</xsl:text>
      <xsl:text>\hypersetup{colorlinks=true,linkcolor=blue,citecolor=blue,filecolor=blue,urlcolor=blue}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$latex.print='yes'">
      <xsl:text>%% latex.print parameter set to 'yes', all hyperlinks black and inactive&#xa;</xsl:text>
      <xsl:text>\hypersetup{draft}&#xa;</xsl:text>
  </xsl:if>
  <xsl:text>\hypersetup{pdftitle={</xsl:text>
  <xsl:apply-templates select="." mode="title-simple" />
  <xsl:text>}}&#xa;</xsl:text>
  <!-- http://tex.stackexchange.com/questions/44088/when-do-i-need-to-invoke-phantomsection -->
  <xsl:text>%% If you manually remove hyperref, leave in this next command&#xa;</xsl:text>
  <xsl:text>\providecommand\phantomsection{}&#xa;</xsl:text>
  <!-- Later comment advises @addtoreset *after* hyperref -->
  <!-- https://tex.stackexchange.com/questions/35782      -->
  <xsl:if test="$parts = 'structural'">  <!-- implies book/part -->
      <xsl:text>%% Structural chapter numbers reset within parts&#xa;</xsl:text>
      <xsl:text>\makeatletter&#xa;</xsl:text>
      <xsl:text>\@addtoreset{chapter}{part}&#xa;</xsl:text>
      <xsl:text>\makeatother&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$latex.watermark">
      <xsl:text>\usepackage{draftwatermark}&#xa;</xsl:text>
      <xsl:text>\SetWatermarkText{</xsl:text>
      <xsl:value-of select="$latex.watermark" />
      <xsl:text>}&#xa;</xsl:text>
      <xsl:text>\SetWatermarkScale{</xsl:text>
      <xsl:value-of select="$latex.watermark.scale" />
      <xsl:text>}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$author-tools='yes'" >
      <xsl:text>%% Collected author tools options (author-tools='yes')&#xa;</xsl:text>
      <xsl:text>%% others need to be elsewhere, these are simply package additions&#xa;</xsl:text>
      <xsl:text>\usepackage{showkeys}&#xa;</xsl:text>
      <xsl:text>\usepackage[letter,cam,center,pdflatex]{crop}&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$docinfo/latex-image-preamble">
      <xsl:text>%% Graphics Preamble Entries&#xa;</xsl:text>
      <xsl:call-template name="sanitize-text">
          <xsl:with-param name="text" select="$docinfo/latex-image-preamble" />
      </xsl:call-template>
  </xsl:if>
  <xsl:text>%% If tikz has been loaded, replace ampersand with \amp macro&#xa;</xsl:text>
  <xsl:if test="$document-root//latex-image-code|$document-root//latex-image">
      <xsl:text>\ifdefined\tikzset&#xa;</xsl:text>
      <xsl:text>    \tikzset{ampersand replacement = \amp}&#xa;</xsl:text>
      <xsl:text>\fi&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="//sidebyside">
      <xsl:text>%% NB: calc redefines \setlength&#xa;</xsl:text>
      <xsl:text>\usepackage{calc}&#xa;</xsl:text>
      <xsl:text>%% used repeatedly for vertical dimensions of sidebyside panels&#xa;</xsl:text>
      <xsl:text>\newlength{\panelmax}&#xa;</xsl:text>
  </xsl:if>
  <!-- We could use contains() on the 5 types of arrows  -->
  <!-- to really defend against this problematic package -->
  <xsl:if test="//m or //md or //mrow">
      <xsl:text>%% extpfeil package for certain extensible arrows,&#xa;</xsl:text>
      <xsl:text>%% as also provided by MathJax extension of the same name&#xa;</xsl:text>
      <xsl:text>%% NB: this package loads mtools, which loads calc, which redefines&#xa;</xsl:text>
      <xsl:text>%%     \setlength, so it can be removed if it seems to be in the &#xa;</xsl:text>
      <xsl:text>%%     way and your math does not use:&#xa;</xsl:text>
      <xsl:text>%%     &#xa;</xsl:text>
      <xsl:text>%%     \xtwoheadrightarrow, \xtwoheadleftarrow, \xmapsto, \xlongequal, \xtofrom&#xa;</xsl:text>
      <xsl:text>%%     &#xa;</xsl:text>
      <xsl:text>%%     we have had to be extra careful with variable thickness&#xa;</xsl:text>
      <xsl:text>%%     lines in tables, and so also load this package late&#xa;</xsl:text>
      <xsl:text>\usepackage{extpfeil}&#xa;</xsl:text>
  </xsl:if>

  <xsl:text>%% Custom Preamble Entries, late (use latex.preamble.late)&#xa;</xsl:text>
  <xsl:if test="$latex.preamble.late != ''">
      <xsl:value-of select="$latex.preamble.late" />
      <xsl:text>&#xa;</xsl:text>
  </xsl:if>
  <xsl:text>%% Begin: Author-provided packages&#xa;</xsl:text>
  <xsl:text>%% (From  docinfo/latex-preamble/package  elements)&#xa;</xsl:text>
  <xsl:value-of select="$latex-packages" />
  <xsl:text>%% End: Author-provided packages&#xa;</xsl:text>
  <xsl:text>%% Begin: Author-provided macros&#xa;</xsl:text>
  <xsl:text>%% (From  docinfo/macros  element)&#xa;</xsl:text>
  <xsl:text>%% Plus three from MBX for XML characters&#xa;</xsl:text>
  <xsl:value-of select="$latex-macros" />
  <xsl:text>%% End: Author-provided macros&#xa;</xsl:text>

  <!-- Easter Egg -->
  <xsl:if test="$sbsdebug">
      <xsl:text>\setlength{\fboxrule}{1pt}&#xa;</xsl:text>
      <xsl:text>\setlength{\fboxsep}{-1pt}&#xa;</xsl:text>
  </xsl:if>

  <!-- PGML definitions. What follows is the PGML problem preamble in its entirety, taken from  -->
  <!-- https://github.com/openwebwork/pg/blob/master/macros/PGML.pl. However some lines are     -->
  <!-- commented out, as they clash with MBX LaTeX.                                             -->
  <xsl:if test="//webwork[@source]">
      <xsl:text>%% PGML macros&#xa;</xsl:text>
      <xsl:text>%% formatted to exactly match output from PGML.pl as of 11/22/2016&#xa;</xsl:text>
      <xsl:text>%% but with some lines commented out&#xa;</xsl:text>
      <xsl:text>%\ifx\pgmlMarker\undefined&#xa;</xsl:text>
      <xsl:text>%  \newdimen\pgmlMarker \pgmlMarker=0.00314159pt  % hack to tell if \newline was used&#xa;</xsl:text>
      <xsl:text>%\fi&#xa;</xsl:text>
      <xsl:text>%\ifx\oldnewline\undefined \let\oldnewline=\newline \fi&#xa;</xsl:text>
      <xsl:text>%\def\newline{\oldnewline\hskip-\pgmlMarker\hskip\pgmlMarker\relax}%&#xa;</xsl:text>
      <xsl:text>%\parindent=0pt&#xa;</xsl:text>
      <xsl:text>%\catcode`\^^M=\active&#xa;</xsl:text>
      <xsl:text>%\def^^M{\ifmmode\else\fi\ignorespaces}%  skip paragraph breaks in the preamble&#xa;</xsl:text>
      <xsl:text>%\def\par{\ifmmode\else\endgraf\fi\ignorespaces}%&#xa;</xsl:text>
      <xsl:text>%\ifdim\lastskip=\pgmlMarker&#xa;</xsl:text>
      <xsl:text>%  \let\pgmlPar=\relax&#xa;</xsl:text>
      <xsl:text>% \else&#xa;</xsl:text>
      <xsl:text>  \let\pgmlPar=\par&#xa;</xsl:text>
      <xsl:text>%  \vadjust{\kern3pt}%&#xa;</xsl:text>
      <xsl:text>%\fi&#xa;</xsl:text>
      <xsl:text>%&#xa;</xsl:text>
      <xsl:text>%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%&#xa;</xsl:text>
      <xsl:text>%%&#xa;</xsl:text>
      <xsl:text>%%    definitions for PGML&#xa;</xsl:text>
      <xsl:text>%%&#xa;</xsl:text>
      <xsl:text>%&#xa;</xsl:text>
      <xsl:text>%\ifx\pgmlCount\undefined  % do not redefine if multiple files load PGML.pl&#xa;</xsl:text>
      <xsl:text>  \newcount\pgmlCount&#xa;</xsl:text>
      <xsl:text>  \newdimen\pgmlPercent&#xa;</xsl:text>
      <xsl:text>  \newdimen\pgmlPixels  \pgmlPixels=.5pt&#xa;</xsl:text>
      <xsl:text>%\fi&#xa;</xsl:text>
      <xsl:text>%\pgmlPercent=.01\hsize&#xa;</xsl:text>
      <xsl:text>%&#xa;</xsl:text>
      <xsl:text>\def\pgmlSetup{%&#xa;</xsl:text>
      <xsl:text>  \parskip=0pt \parindent=0pt&#xa;</xsl:text>
      <xsl:text>%  \ifdim\lastskip=\pgmlMarker\else\par\fi&#xa;</xsl:text>
      <xsl:text>  \pgmlPar&#xa;</xsl:text>
      <xsl:text>}%&#xa;</xsl:text>
      <xsl:text>&#xa;</xsl:text>
      <xsl:text>\def\pgmlIndent{\par\advance\leftskip by 2em \advance\pgmlPercent by .02em \pgmlCount=0}%&#xa;</xsl:text>
      <xsl:text>\def\pgmlbulletItem{\par\indent\llap{$\bullet$ }\ignorespaces}%&#xa;</xsl:text>
      <xsl:text>\def\pgmlcircleItem{\par\indent\llap{$\circ$ }\ignorespaces}%&#xa;</xsl:text>
      <xsl:text>\def\pgmlsquareItem{\par\indent\llap{\vrule height 1ex width .75ex depth -.25ex\ }\ignorespaces}%&#xa;</xsl:text>
      <xsl:text>\def\pgmlnumericItem{\par\indent\advance\pgmlCount by 1 \llap{\the\pgmlCount. }\ignorespaces}%&#xa;</xsl:text>
      <xsl:text>\def\pgmlalphaItem{\par\indent{\advance\pgmlCount by `\a \llap{\char\pgmlCount. }}\advance\pgmlCount by 1\ignorespaces}%&#xa;</xsl:text>
      <xsl:text>\def\pgmlAlphaItem{\par\indent{\advance\pgmlCount by `\A \llap{\char\pgmlCount. }}\advance\pgmlCount by 1\ignorespaces}%&#xa;</xsl:text>
      <xsl:text>\def\pgmlromanItem{\par\indent\advance\pgmlCount by 1 \llap{\romannumeral\pgmlCount. }\ignorespaces}%&#xa;</xsl:text>
      <xsl:text>\def\pgmlRomanItem{\par\indent\advance\pgmlCount by 1 \llap{\uppercase\expandafter{\romannumeral\pgmlCount}. }\ignorespaces}%&#xa;</xsl:text>
      <xsl:text>&#xa;</xsl:text>
      <xsl:text>\def\pgmlCenter{%&#xa;</xsl:text>
      <xsl:text>  \par \parfillskip=0pt&#xa;</xsl:text>
      <xsl:text>  \advance\leftskip by 0pt plus .5\hsize&#xa;</xsl:text>
      <xsl:text>  \advance\rightskip by 0pt plus .5\hsize&#xa;</xsl:text>
      <xsl:text>  \def\pgmlBreak{\break}%&#xa;</xsl:text>
      <xsl:text>}%&#xa;</xsl:text>
      <xsl:text>\def\pgmlRight{%&#xa;</xsl:text>
      <xsl:text>  \par \parfillskip=0pt&#xa;</xsl:text>
      <xsl:text>  \advance\leftskip by 0pt plus \hsize&#xa;</xsl:text>
      <xsl:text>  \def\pgmlBreak{\break}%&#xa;</xsl:text>
      <xsl:text>}%&#xa;</xsl:text>
      <xsl:text>&#xa;</xsl:text>
      <xsl:text>\def\pgmlBreak{\\}%&#xa;</xsl:text>
      <xsl:text>&#xa;</xsl:text>
      <xsl:text>\def\pgmlHeading#1{%&#xa;</xsl:text>
      <xsl:text>  \par\bfseries&#xa;</xsl:text>
      <xsl:text>  \ifcase#1 \or\huge \or\LARGE \or\large \or\normalsize \or\footnotesize \or\scriptsize \fi&#xa;</xsl:text>
      <xsl:text>}%&#xa;</xsl:text>
      <xsl:text>&#xa;</xsl:text>
      <xsl:text>\def\pgmlRule#1#2{%&#xa;</xsl:text>
      <xsl:text>  \par\noindent&#xa;</xsl:text>
      <xsl:text>  \hbox{%&#xa;</xsl:text>
      <xsl:text>    \strut%&#xa;</xsl:text>
      <xsl:text>    \dimen1=\ht\strutbox%&#xa;</xsl:text>
      <xsl:text>    \advance\dimen1 by -#2%&#xa;</xsl:text>
      <xsl:text>    \divide\dimen1 by 2%&#xa;</xsl:text>
      <xsl:text>    \advance\dimen2 by -\dp\strutbox%&#xa;</xsl:text>
      <xsl:text>    \raise\dimen1\hbox{\vrule width #1 height #2 depth 0pt}%&#xa;</xsl:text>
      <xsl:text>  }%&#xa;</xsl:text>
      <xsl:text>  \par&#xa;</xsl:text>
      <xsl:text>}%&#xa;</xsl:text>
      <xsl:text>&#xa;</xsl:text>
      <xsl:text>\def\pgmlIC#1{\futurelet\pgmlNext\pgmlCheckIC}%&#xa;</xsl:text>
      <xsl:text>\def\pgmlCheckIC{\ifx\pgmlNext\pgmlSpace \/\fi}%&#xa;</xsl:text>
      <xsl:text>{\def\getSpace#1{\global\let\pgmlSpace= }\getSpace{} }%&#xa;</xsl:text>
      <xsl:text>%&#xa;</xsl:text>
      <xsl:text>%{\catcode`\ =12\global\let\pgmlSpaceChar= }%&#xa;</xsl:text>
      <xsl:text>%{\obeylines\gdef\pgmlPreformatted{\par\small\ttfamily\hsize=10\hsize\obeyspaces\obeylines\let^^M=\pgmlNL\pgmlNL}}%&#xa;</xsl:text>
      <xsl:text>%\def\pgmlNL{\par\bgroup\catcode`\ =12\pgmlTestSpace}%&#xa;</xsl:text>
      <xsl:text>%\def\pgmlTestSpace{\futurelet\next\pgmlTestChar}%&#xa;</xsl:text>
      <xsl:text>%\def\pgmlTestChar{\ifx\next\pgmlSpaceChar\ \pgmlTestNext\fi\egroup}%&#xa;</xsl:text>
      <xsl:text>%\def\pgmlTestNext\fi\egroup#1{\fi\pgmlTestSpace}%&#xa;</xsl:text>
      <xsl:text>%&#xa;</xsl:text>
      <xsl:text>%\def^^M{\ifmmode\else\space\fi\ignorespaces}%&#xa;</xsl:text>
      <xsl:text>%% END PGML macros&#xa;</xsl:text>
  </xsl:if>
  <xsl:if test="$document-root//contributors">
      <xsl:text>%% Semantic macros for contributor list&#xa;</xsl:text>
      <xsl:text>\newcommand{\contributor}[1]{\parbox{\linewidth}{#1}\par\bigskip}&#xa;</xsl:text>
      <xsl:text>\newcommand{\contributorname}[1]{\textsc{#1}\\[0.25\baselineskip]}&#xa;</xsl:text>
      <xsl:text>\newcommand{\contributorinfo}[1]{\hspace*{0.05\linewidth}\parbox{0.95\linewidth}{\textsl{#1}}}&#xa;</xsl:text>
  </xsl:if>

  <xsl:text>%% End of Preamble %% &#xa; &#xa;</xsl:text>
</xsl:template>

</xsl:stylesheet>

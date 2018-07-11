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
<xsl:import href="./custom-latex.xsl" />

<!-- Intend output for rendering by pdflatex -->
<xsl:output method="text" />


<!-- params to pass custom-latex: -->
<!-- These will need to be rethought when using updated mathbook -->
<xsl:param name="project.text.hint" select="'no'" />
<xsl:param name="task.text.hint" select="'no'" />
<xsl:param name="project.text.solution" select="'yes'" />
<xsl:param name="task.text.solution" select="'yes'" />



<!-- Parameters to pass via xsltproc "stringparam" on command-line            -->
<!-- Or make a thin customization layer and use 'select' to provide overrides -->
<!-- Produce all content (or select individually below): -->
<xsl:param name="everything" select="'no'"/>

<!-- Individual extras: -->
<!-- Produce activities: -->
<xsl:param name="activities" select="'yes'"/>
<!-- Produce (the start of) lecture notes: -->
<xsl:param name="notes" select="'no'"/>
<!-- Others to be added as needed -->

<!-- TODO: add options to limit what content gets included (perhaps per format) -->

<!-- TODO: Allow choices of chunk size (currently chunk at section for most things, but at activity for activities).  Might not be necessary.  I could always chunk and include using docmute -->


<!-- This is where I need to split up files based on chunk level -->
<!-- Also, probably change file names based on content? -->
<xsl:template match="/">
  <!-- Generate includable preambles as needed -->
  <xsl:if test="$everything='yes' or $activities='yes'">
    <xsl:call-template name="activities-preamble-file"/>
    <xsl:call-template name="activities-main-file" />
  </xsl:if>
  <xsl:if test="$everything='yes' or $notes='yes'">
    <xsl:call-template name="notes-preamble-file"/>
    <xsl:call-template name="notes-main-file" />
  </xsl:if>
</xsl:template>

<!-- Default behavior is to skip all elements unless defined below. -->
<xsl:template match="*" mode="activities">
  <xsl:apply-templates select="*" mode="activities" />
</xsl:template>
<xsl:template match="*" mode="notes">
  <xsl:apply-templates select="*" mode="notes" />
</xsl:template>



<xsl:template match="&PROJECT-LIKE;" mode="activities">
  <xsl:variable name="filename">
      <text>activities/</text>
      <!-- <xsl:apply-templates select="." mode="long-name" /> -->
      <xsl:call-template name="type-and-number"/>
      <text>.tex</text>
  </xsl:variable>
  <xsl:text>\input{</xsl:text>
  <xsl:value-of select="$filename" />
  <xsl:text>}&#xa;\clearpage&#xa;&#xa;</xsl:text>
  <!-- <xsl:text>\subsection*{</xsl:text>
  <xsl:apply-templates select="." mode="long-name" />
  <xsl:text>}&#xa;</xsl:text>
  <xsl:apply-templates select="*" mode="slides"/> -->
  <xsl:call-template name="activities-subfiles"/>
  <!-- <xsl:call-template name="start-activity" />
  <xsl:apply-templates select="."/>
  <xsl:call-template name="end-activity" /> -->
</xsl:template>


<!-- Produce nice filenames: -->
<xsl:template name="type-and-number">
  <xsl:variable name="filename">
    <xsl:apply-templates select="." mode="type-name" />
    <xsl:text>_</xsl:text>
    <xsl:apply-templates select="." mode="number" />
  </xsl:variable>
  <xsl:value-of select="translate(translate($filename, '!', ''), '.', '-')"/>
</xsl:template>





<!-- <xsl:template match="solution">
</xsl:template> -->



<!-- Start and end of activities -->
<!-- These will eventually get more, including comments -->
<!--   which include section numbers to easily identify them -->
<xsl:template name="start-activity">
    <!-- <xsl:text>\begin{frame}[allowframebreaks, plain]&#xa; &#xa;</xsl:text> -->
    <!-- <xsl:variable name="cptj-value">
      <xsl:apply-templates select="." mode="number"/>
    </xsl:variable> -->
    <xsl:text>\setcounter{project}{</xsl:text>
      <xsl:apply-templates select="." mode="serial-number"/>
    <xsl:text>}&#xa;\addtocounter{project}{-1}&#xa;</xsl:text>
</xsl:template>

<xsl:template name="end-activity">
    <!-- <xsl:text>\end{frame}&#xa; &#xa;</xsl:text> -->
    <!-- <xsl:text>&#xa;\clearpage &#xa;</xsl:text> -->
    
</xsl:template>




<!-- ########################################### -->
<!-- Templates to generate files:                -->
<!-- ########################################### -->

<!-- To generate single file which includes everything: -->
<xsl:template name="activities-main-file">
  <exsl:document href="activities.tex" method="text" >
    <xsl:text>\documentclass{book}&#xa;&#xa;</xsl:text>
    <xsl:text>\input{activities-preamble.tex}&#xa;</xsl:text>
    <!-- <xsl:text>% Include a file allowing course customizations &#xa;</xsl:text> -->
    <!-- <xsl:text>\@input{../customize.tex}&#xa;</xsl:text> -->
    <xsl:text>\begin{document}&#xa;&#xa;</xsl:text>
    <xsl:apply-templates select="*" mode="activities"/>
    <xsl:text>\end{document}&#xa;</xsl:text>
  </exsl:document>
</xsl:template>

<xsl:template name="notes-main-file">
  <exsl:document href="./notes/notes.tex" method="text" >
    <xsl:text>\documentclass{article}&#xa;&#xa;</xsl:text>
    <xsl:text>\input{notes-preamble.tex}&#xa;</xsl:text>
    <!-- <xsl:text>% Include a file allowing course customizations &#xa;</xsl:text> -->
    <!-- <xsl:text>\@input{../customize.tex}&#xa;</xsl:text> -->
    <xsl:text>\begin{document}&#xa;</xsl:text>
    <xsl:apply-templates select="*" mode="notes"/>
    <xsl:text>\end{document}&#xa;</xsl:text>
  </exsl:document>
</xsl:template>


<!-- Subfiles: -->
<xsl:template name="activities-subfiles">
  <xsl:variable name="filename">
      <text>activities/</text>
      <!-- <xsl:apply-templates select="." mode="long-name" /> -->
      <xsl:call-template name="type-and-number"/>
      <text>.tex</text>
  </xsl:variable>
  <exsl:document href="{$filename}" method="text" >
    <xsl:text>\documentclass{book}&#xa;&#xa;</xsl:text>
    <xsl:text>\input{../activities-preamble.tex}&#xa;</xsl:text>
    <!-- <xsl:text>% Include a file allowing course customizations &#xa;</xsl:text> -->
    <!-- <xsl:text>\@input{../../customize.tex}&#xa;</xsl:text> -->
    <xsl:text>\begin{document}&#xa;</xsl:text>
    <!-- <xsl:text>\subsection*{</xsl:text>
    <xsl:apply-templates select="." mode="long-name" />
    <xsl:text>}&#xa;</xsl:text> -->
    <!-- <xsl:apply-templates select="*" mode="activities"/> -->
    <xsl:call-template name="start-activity" />
    <xsl:apply-templates select="."/>
    <xsl:call-template name="end-activity" />
    <xsl:text>\end{document}&#xa;</xsl:text>
  </exsl:document>
</xsl:template>





<!-- To generate single file with preambles: -->

<xsl:template name="activities-preamble-file" >
  <exsl:document href="activities-preamble.tex" method="text" >
    <xsl:call-template name="activities-preamble"/>
  </exsl:document>
</xsl:template>

<xsl:template name="notes-preamble-file" >
  <exsl:document href="notes-preamble.tex" method="text" >
    <xsl:call-template name="notes-preamble"/>
  </exsl:document>
</xsl:template>




<!-- ########################################### -->
<!-- End of main sheet.  Below is only preambles -->
<!-- ########################################### -->



<!-- Activities: -->
<xsl:template name="activities-preamble">
  <!-- Hack to avoid error when compiling article -->
  <!-- <xsl:text>\newcommand*{\chaptername}{Chapter}</xsl:text>
  <xsl:text>\newcounter{chapter}</xsl:text> -->
  <!-- Preamble pulled from mathbook-latex.xsl -->
  <xsl:call-template name="latex-preamble"/>
  <xsl:text>% Include docmute package to include files that can themselves compile. &#xa;</xsl:text>
  <xsl:text>\usepackage{docmute}&#xa;</xsl:text>
  <xsl:text>\usepackage{import}&#xa;</xsl:text>
  <xsl:text>\pagestyle{empty}&#xa;</xsl:text>
</xsl:template>

<!-- Notes: -->
<xsl:template name="notes-preamble">
  <xsl:call-template name="latex-preamble"/>
</xsl:template>


</xsl:stylesheet>

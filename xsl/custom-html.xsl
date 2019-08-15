<?xml version="1.0" encoding="UTF-8"?>


<!-- This file is part of the book                 -->
<!--                                               -->
<!--   Discrete Mathematics: an Open Introduction  -->
<!--                                               -->
<!-- Copyright (C) 2015-2018 Oscar Levin           -->
<!-- See the file COPYING for copying conditions.  -->

<!-- Parts of this file were adapted from the author guide at https://github.com/rbeezer/mathbook and the analagous file at https://github.com/twjudson/aata -->


<!-- DMOI customizations for HTML runs -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!-- Assumes current file is in discrete-text/xsl and that the mathbook repository is adjacent -->
<xsl:import href="../../../mathbook/xsl/mathbook-html.xsl" />
<!-- Assumes next file can be found in discrete-text/xsl -->
<xsl:import href="custom-common.xsl" />

<!-- List Chapters and Sections in sidebar Table of Contents -->
<xsl:param name="toc.level" select="''" />


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
<xsl:param name="exercise.inline.answer" select="''" />
<xsl:param name="exercise.inline.solution" select="''" />
<xsl:param name="exercise.divisional.statement" select="''" />
<xsl:param name="exercise.divisional.hint" select="'yes'" />
<xsl:param name="exercise.divisional.answer" select="'no'" />
<xsl:param name="exercise.divisional.solution" select="'yes'" />
<xsl:param name="exercise.worksheet.statement" select="''" />
<xsl:param name="exercise.worksheet.hint" select="''" />
<xsl:param name="exercise.worksheet.answer" select="''" />
<xsl:param name="exercise.worksheet.solution" select="''" />
<xsl:param name="exercise.reading.statement" select="''" />
<xsl:param name="exercise.reading.hint" select="''" />
<xsl:param name="exercise.reading.answer" select="''" />
<xsl:param name="exercise.reading.solution" select="''" />
<xsl:param name="project.statement" select="''" />
<xsl:param name="project.hint" select="'yes'" />
<xsl:param name="project.answer" select="'no'" />
<xsl:param name="project.solution" select="'no'" />




<!-- Here are the options, taken from mathbook-html.xsl, changed as needed -->
<!-- ################################################ -->
<!-- Following is slated to migrate above, 2019-07-10 -->
<!-- ################################################ -->

<!-- Parameters -->
<!-- Parameters to pass via xsltproc "stringparam" on command-line            -->
<!-- Or make a thin customization layer and use 'select' to provide overrides -->
<!-- See more generally applicable parameters in mathbook-common.xsl file     -->

<!-- WeBWorK exercise may be rendered static="yes"    -->
<!-- TODO: implement middle option static="preview"   -->
<!-- Or static="no" makes an interactive problem      -->
<!-- Also in play here are params from -common:       -->
<!-- exercise.text.statement, exercise.text.hint, exercise.text.solution -->
<!-- For a divisional exercise, when static="no", that is an intentional -->
<!-- decision to show the live problem, which means the statement will   -->
<!-- be shown, regardless of exercise.text.statement. If the problem was -->
<!-- authored in PTX source, we can respect the values for               -->
<!-- exercise.text.hint and exercise.text.solution. If the problem       -->
<!-- source is on the webwork server, then hints and solutions will show -->
<!-- no matter what.                                                     -->
<!-- For a divisional exercise, when static="yes", each of the three     -->
<!-- -common params will be respected. Effectively the content is        -->
<!-- handled like a non-webwork exercise.                                -->
<!-- For an inline exercise (webwork or otherwise) statements, hints,    -->
<!-- and solutions are always shown. The -common params mentioned above  -->
<!-- do not apply. Whether static is "yes" or "no" doesn't matter.       -->
<xsl:param name="webwork.inline.static" select="'no'" />
<xsl:param name="webwork.divisional.static" select="'yes'" />
<xsl:param name="webwork.reading.static" select="'yes'" />
<xsl:param name="webwork.worksheet.static" select="'yes'" />

<!-- Content as Knowls -->
<!-- These parameters control if content is      -->
<!-- hidden in a knowl on first appearance       -->
<!-- The happens automatically sometimes,        -->
<!-- eg content of a footnote is always hidden   -->
<!-- Some things never are hidden,               -->
<!-- eg an entire section (too big),             -->
<!-- or a bibliographic item (pointless)         -->
<!-- These switches often control a whole group  -->
<!-- of similar items, for example the "theorem" -->
<!-- switch will similarly affect corrolaries,   -->
<!-- lemmas, etc - anything that can be proved   -->
<!-- NB: figures and tables inside of            -->
<!-- side-by-side panels are never born hidden,  -->
<!-- no matter how the switches below are set.   -->
<!-- You may elect to have entire side-by-side   -->
<!-- panels born as knowls, using the switch.    -->
<!-- PROJECT-LIKE gets own switch here           -->
<!-- "example" are set to 'yes' by default       -->
<!-- so new authors know that knowls exist       -->
<xsl:param name="html.knowl.theorem" select="'no'" />
<xsl:param name="html.knowl.proof" select="'yes'" />
<xsl:param name="html.knowl.definition" select="'no'" />
<xsl:param name="html.knowl.example" select="'no'" />
<xsl:param name="html.knowl.project" select="'no'" />
<xsl:param name="html.knowl.task" select="'no'" />
<xsl:param name="html.knowl.list" select="'no'" />
<xsl:param name="html.knowl.remark" select="'no'" />
<xsl:param name="html.knowl.objectives" select="'no'" />
<xsl:param name="html.knowl.outcomes" select="'no'" />
<xsl:param name="html.knowl.figure" select="'no'" />
<xsl:param name="html.knowl.table" select="'no'" />
<xsl:param name="html.knowl.listing" select="'no'" />
<xsl:param name="html.knowl.exercise.inline" select="'no'" />
<xsl:param name="html.knowl.exercise.sectional" select="'no'" />
<xsl:param name="html.knowl.exercise.worksheet" select="'no'" />
<xsl:param name="html.knowl.exercise.readingquestion" select="'no'" />
<!-- html.knowl.example.solution: always "yes", could be implemented -->

<!-- CSS and Javascript Servers -->
<!-- We allow processing paramteers to specify new servers   -->
<!-- or to specify the particular CSS file, which may have   -->
<!-- different color schemes.  The defaults should work      -->
<!-- fine and will not need changes on initial or casual use -->
<!-- Files with name colors_*.css set the colors.            -->
<!-- colors_default is similar to the old mathbook-3.css     -->
<xsl:param name="html.css.server" select="'https://pretextbook.org'" />
<xsl:param name="html.css.version" select="'0.2'" />
<xsl:param name="html.js.server" select="'https://pretextbook.org'" />
<xsl:param name="html.js.version" select="'0.12'" />
<xsl:param name="html.css.colorfile" select="''" />
<!-- A temporary variable for testing -->
<xsl:param name="debug.colors" select="''"/>

<xsl:variable name="html-css-colorfile">
    <xsl:choose>
        <!-- 2019-05-29: override with new files, no error-checking    -->
        <!-- if not used, then previous scheme is employed identically -->
        <xsl:when test="not($debug.colors = '')">
            <xsl:text>colors_</xsl:text>
            <xsl:value-of select="$debug.colors"/>
            <xsl:text>.css</xsl:text>
        </xsl:when>
        <xsl:when test="$html.css.colorfile = ''">
            <xsl:text>colors_default.css</xsl:text>
        </xsl:when>
        <xsl:otherwise>
            <xsl:value-of select="$html.css.colorfile"/>
        </xsl:otherwise>
    </xsl:choose>
</xsl:variable>
<!-- A space-separated list of CSS URLs (points to servers or local files) -->
<xsl:param name="html.css.extra"  select="'custom-styles.css'" />

<!-- Calculator -->
<!-- Possible values are geogebra-classic, geogebra-graphing -->
<!-- geogebra-geometry, geogebra-3d                          -->
<!-- Default is empty, meaning the calculator is not wanted. -->
<xsl:param name="html.calculator" select="''" />
<xsl:variable name="b-has-calculator" select="not($html.calculator = '')" />

<!-- Annotation -->
<xsl:param name="html.annotation" select="''" />
<xsl:variable name="b-activate-hypothesis" select="boolean($html.annotation='hypothesis')" />

<!-- Navigation -->
<!-- Navigation may follow two different logical models:                     -->
<!--   (a) Linear, Prev/Next - depth-first search, linear layout like a book -->
<!--       Previous and Next take you to the adjacent "page"                 -->
<!--   (b) Tree, Prev/Up/Next - explicitly traverse the document tree        -->
<!--       Prev and Next remain at same depth/level in tree                  -->
<!--       Must follow a summary link to descend to finer subdivisions       -->
<!--   'linear' is the default, 'tree' is an option                          -->
<xsl:param name="html.navigation.logic"  select="'linear'" />
<!-- The "up" button is optional given the contents sidebar, default is to have it -->
<!-- An up button is very desirable if you use the tree-like logic                 -->
<xsl:param name="html.navigation.upbutton"  select="'yes'" />
<!-- There are also "compact" versions of the navigation buttons in the top right -->
<xsl:param name="html.navigation.style"  select="'full'" />


<!-- Permalinks -->
<!-- Next to subdivision headings a "paragraph" symbol     -->
<!-- (a pilcrow) along with internationalized text         -->
<!-- ("permalink") indicates a link to that section.       -->
<!-- It is useful if you want to right-click on it to      -->
<!-- capture a link for use somewhere else.  (Similar      -->
<!-- behavior for theorems, examples, etc is planned.)     -->
<!--                                                       -->
<!-- "Permalink" is a bit of an exaggeration.  Site        -->
<!-- domain name is relative to wherever content is        -->
<!-- hosted.  We say a link is "stable" if there is        -->
<!-- an  xml:id  on the enclosing page AND an  xml:id      -->
<!-- on the subdivision (which could be the same).         -->
<!-- If you change the chunking level, then the enclosing  -->
<!-- page could change and these links will be affected.   -->
<!--                                                       -->
<!-- 'none' - no permalinks anywhere                       -->
<!-- 'stable' - only stable links (see paragraph above)    -->
<!-- 'all' - every section heading, even if links are poor -->
<xsl:param name="html.permalink"  select="'stable'" />
<!-- Parameters -->
<!-- Parameters to pass via xsltproc "stringparam" on command-line            -->
<!-- Or make a thin customization layer and use 'select' to provide overrides -->
<!-- See more generally applicable parameters in mathbook-common.xsl file     -->






<!-- Hack solution-list to display nicer headers -->
<xsl:template match="exercises" mode="backmatter">
    <!-- see if an "exercises" section has any solutions -->
    <xsl:variable name="nonempty" select="(.//hint and $exercise.backmatter.hint='yes') or
                                          (.//answer and $exercise.backmatter.answer='yes') or
                                          (.//solution and $exercise.backmatter.solution='yes')" />

    <xsl:if test="$nonempty='true'">
        <section class="exercises" id="">
            <h1 class="heading">
                <span class="type">Solutions for Section </span>
                <span class="codenumber"><xsl:apply-templates select="parent::*" mode="number" /></span>
                <!-- <span class="title"><xsl:apply-templates select="." mode="title-full" /></span> -->
            </h1>
            <!-- ignore introduction, conclusion, exercise groups -->
            <xsl:apply-templates select=".//exercise" mode="backmatter" />
        </section>
    </xsl:if>
</xsl:template>
<!-- Print exercises with some solution component -->
<!-- Respect switches about visibility            -->
<xsl:template match="exercise" mode="backmatter">
    <xsl:if test="answer or solution"><!-- Removed "hint or" -->
        <!-- Lead with the problem number and some space -->
        <xsl:variable name="xref">
            <xsl:apply-templates select="." mode="internal-id" />
        </xsl:variable>
        <article class="exercise-like" id="{$xref}">
            <h5 class="heading hidden-type">
            <!-- <span class="type"><xsl:apply-templates select="." mode="type-name" /></span> -->
            <span class="codenumber"><xsl:apply-templates select="." mode="number" /></span>
            <xsl:if test="title">
                <span class="title"><xsl:apply-templates select="." mode="title-full" /></span>
            </xsl:if>
            </h5>
            <!-- default templates will produce inline knowls -->
            <span class="hidden-knowl-wrapper">
              <xsl:if test="$exercise.backmatter.statement='yes'">
                <xsl:apply-templates select="statement" />
              </xsl:if> <!-- moved first one down -->
                <xsl:if test="hint and $exercise.backmatter.hint='yes'">
                    <xsl:apply-templates select="hint" />
                </xsl:if>
                <xsl:if test="answer and $exercise.backmatter.answer='yes'">
                    <xsl:apply-templates select="answer" />
                </xsl:if>
                <xsl:if test="solution and $exercise.backmatter.solution='yes'">
                    <xsl:apply-templates select="solution" />
                </xsl:if>
            </span>
        </article>
    </xsl:if>
</xsl:template>

<!-- HTML, CSS -->
<xsl:template match="exercise" mode="environment-element">
    <xsl:text>article</xsl:text>
</xsl:template>
<xsl:template match="exercise" mode="environment-class">
    <xsl:text>exercise-like</xsl:text>
</xsl:template>



<!-- Analytics Footers -->

<!-- Google Analytics                     -->
<!-- "Classic", not compared to Universal -->
<xsl:template match="google">
<xsl:comment>Start: Google code</xsl:comment>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-66485406-1', 'auto');
  ga('send', 'pageview');

</script>
<xsl:comment>End: Google code</xsl:comment>
</xsl:template>



</xsl:stylesheet>

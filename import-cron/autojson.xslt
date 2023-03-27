<?xml version="1.0" encoding="UTF-8"?>
<!--Author: Benjamin W. Broersma <bw@broersma.com> -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="https://organisaties.overheid.nl/static/schema/oo/export/2.6.1 https://almanak.overheid.nl/static/schema/oo/export/oo-export-2.4.10.xsd" xmlns:p="https://organisaties.overheid.nl/static/schema/oo/export/2.6.1">
  <xsl:output omit-xml-declaration="yes" encoding="UTF-8"/>
  <!--http://stackoverflow.com/a/7523245-->
  <!--how this works: it checks if the text contains the replace search value, if not return text, else get substring-before+replacement+recursive call self with substring-after as text-->
    <xsl:template name="replace-string">
      <xsl:param name="text"/>
      <xsl:param name="replace"/>
      <xsl:param name="with"/>
      <xsl:choose>
        <xsl:when test="contains($text,$replace)">
          <xsl:value-of select="substring-before($text,$replace)"/>
          <xsl:value-of select="$with"/>
          <xsl:call-template name="replace-string">
            <xsl:with-param name="text"
    select="substring-after($text,$replace)"/>
            <xsl:with-param name="replace" select="$replace"/>
            <xsl:with-param name="with" select="$with"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$text"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:template>
  <xsl:template match="p:overheidsorganisaties">[
    <xsl:apply-templates select="p:organisaties/p:organisatie"/>
    <xsl:if test="count(./p:gemeenten/p:gemeente) &gt; 0">
      ,
      <xsl:apply-templates select="p:gemeenten/p:gemeente"/>
    </xsl:if>
    <xsl:if test="count(./p:gemeenschappelijkeRegelingen/p:regeling) &gt; 0">
      ,
      <xsl:apply-templates select="p:gemeenschappelijkeRegelingen/p:regeling"/>
    </xsl:if>
    <xsl:if test="count(./p:zelfstandigeBestuursorganen/p:zelfstandigBestuursorgaan) &gt; 0">
      ,
      <xsl:apply-templates select="p:zelfstandigeBestuursorganen/p:zelfstandigBestuursorgaan"/>
    </xsl:if>
  ]
  </xsl:template>
  <!--xsl:template match="p:ministeries"><!- -consume it!- ->
  </xsl:template-->
  <!--xsl:template match="p:">
      {  <xsl:apply-templates select="*"/>}<xsl:if test="position() != last()">,</xsl:if>
  </xsl:template-->
  <!--store systemId as numbers, and unwrap them -->
  <xsl:template match="p:regeling">
    {<xsl:apply-templates select="*"/>}<xsl:if test="position() != last()">,</xsl:if>
  </xsl:template>
  <xsl:template match="p:systemId">
    "systemId": <xsl:value-of select="p:systemId" /><xsl:if test="position() != last()">,</xsl:if>
  </xsl:template>
  <!--store all nonNegativeInteger, boolean and double types without quotes -->
  <xsl:template match="p:vergoeding | p:aantal | p:aantalInwoners | p:inwonersPerKm2 | p:totaalZetels | p:organisatieId">
    "<xsl:value-of select="local-name()" />": <xsl:value-of select="." /><xsl:if test="position() != last()">,</xsl:if>
  </xsl:template>
  <!-- convert ja/nee to true/false -->
  <xsl:template match="p:kaderwetZboVanToepassing">
    "<xsl:value-of select="local-name()" />": <xsl:value-of select=". = 'ja'" /><xsl:if test="position() != last()">,</xsl:if>
  </xsl:template>
  <!-- takenEnBevoegdheden & aantekening have &lt;![CDATA[...]]&gt; crap-->
  <!-- unwrap adres node -->
  <xsl:template match="p:adres">
    {<xsl:apply-templates select="*"/>}<xsl:if test="position() != last()">,</xsl:if>
  </xsl:template>
  <!--unwrap ictuCode, note that codes can have 0-prefix, so we store them as string  -->
  <xsl:template match="p:ictuCode">
    "ictuCode": "<xsl:value-of select="p:ictuCode" />"<xsl:if test="position() != last()">,</xsl:if>
  </xsl:template>
<!-- using 'node()[]' will make it extremely slow, and using this setup created trailing comma issues, so better strip it in JQ
  <xsl:template match="p:contactpaginas[not(child::node())]|p:classificaties[not(child::node())]|p:organisaties[not(child::node())]|p:functies[not(child::node())]">
  </xsl:template>
-->
  <xsl:template match="node()">
    <xsl:choose>
      <xsl:when test="./@*">
        <xsl:choose>
          <xsl:when test="local-name() = 'bevoegdheidsverkrijging' or local-name() = 'instellingsbesluit' or local-name() = 'bbvFunctie' "><!--unwrap this to an array of strings-->
            "<xsl:value-of select="./@*" />"
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="local-name() != substring(local-name(..), 1, string-length(local-name())) and local-name(preceding-sibling::node()[1]) != local-name()">
              "<xsl:value-of select="local-name()" />":<xsl:if test="local-name(following-sibling::node()[1]) = local-name()">[</xsl:if></xsl:if> {
              <xsl:for-each select="./@*">
                 "<xsl:choose>
                    <xsl:when test="substring(local-name(), 1, string-length(local-name(..))) = local-name(..)"><!--remove prefix attributes-->
                      <xsl:value-of select="concat(translate(substring(local-name(), string-length(local-name(..)) + 1, 1), 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), substring(local-name(), string-length(local-name(..)) + 2))"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="local-name()"/>
                    </xsl:otherwise>
                  </xsl:choose>": <xsl:choose>
                    <xsl:when test="local-name() = 'systemId' or local-name() = 'catnr'">
                      <xsl:value-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                      "<xsl:call-template name="replace-string"><!--Yes this is needed!-->
            <xsl:with-param name="text" select="."/>
            <xsl:with-param name="replace" select="'&quot;'" />
            <xsl:with-param name="with" select="'\&quot;'"/>
          </xsl:call-template>"
                    </xsl:otherwise>
                  </xsl:choose><xsl:if test="position() != last()">,</xsl:if>
              </xsl:for-each>
              <xsl:if test="./*">
                ,<xsl:apply-templates select="*"/>
              </xsl:if>
              <xsl:if test="text()">
                ,"value": "<xsl:call-template name="replace-string"><!--Yes this is needed!-->
                    <xsl:with-param name="text" select="normalize-space(text())"/>
                    <xsl:with-param name="replace" select="'&quot;'" />
                    <xsl:with-param name="with" select="'\&quot;'"/>
                  </xsl:call-template>"
              </xsl:if>
            }<xsl:if test="local-name() != substring(local-name(..), 1, string-length(local-name())) and local-name(preceding-sibling::node()[1]) = local-name() and local-name(following-sibling::node()[1]) != local-name()">]</xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position() != last()">,</xsl:if>
      </xsl:when>
      <xsl:when test="text()">
        <xsl:if test="local-name(preceding-sibling::node()[1]) != local-name() and local-name() != substring(local-name(..), 1, string-length(local-name()))">"<xsl:value-of select="local-name()" />":</xsl:if>
        <xsl:if test="local-name(preceding-sibling::node()[1]) != local-name() and local-name(following-sibling::node()[1]) = local-name()">[</xsl:if> "<xsl:call-template name="replace-string"><!--Yes this is needed!-->
            <xsl:with-param name="text" select="normalize-space(text())"/>
            <xsl:with-param name="replace" select="'&quot;'" />
            <xsl:with-param name="with" select="'\&quot;'"/>
          </xsl:call-template>"<xsl:if test="local-name(preceding-sibling::node()[1]) = local-name() and local-name(following-sibling::node()[1]) != local-name()">]</xsl:if><xsl:if test="position() != last()">,</xsl:if>
        </xsl:when>
      <xsl:when test="self::*">
        <xsl:choose>
          <xsl:when test="local-name() = 'socialMedia'">
              "socialMedia": [<xsl:apply-templates select="*"/>]
          </xsl:when>
          <xsl:when test="local-name() = 'bevoegdheid'">
            {<xsl:apply-templates select="*"/>}
          </xsl:when>
          <xsl:when test="local-name() = 'socialmedium'">
            {
              <xsl:apply-templates select="*"/>
            }
          </xsl:when>
          <xsl:when test="local-name() = 'emailadres'">
            {
              "email": <xsl:apply-templates select="*"/>
            }
          </xsl:when>
          <xsl:when test="local-name() = 'evaluatieverslag'">
            {
              <xsl:apply-templates select="*"/>
            }
          </xsl:when>
          <xsl:when test="local-name(self::*/*[1]) = substring(local-name(), 1, string-length(local-name(self::*/*[1]))) or local-name() = 'clusterOnderdelen' or local-name() = 'bevoegdheden'">
            "<xsl:value-of select="local-name()" />": [
              <xsl:apply-templates select="*"/>
            ]
          </xsl:when>
          <xsl:when test="local-name() = substring(local-name(..), 1, string-length(local-name())) or local-name() = 'zelfstandigBestuursorgaan' or local-name() = 'clusterOnderdeel' ">
            {
              <xsl:apply-templates select="*"/>
            }
          </xsl:when>
          <xsl:otherwise>
            "<xsl:value-of select="local-name()" />": {
              <xsl:apply-templates select="*"/>
            }
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position() != last()">,</xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>

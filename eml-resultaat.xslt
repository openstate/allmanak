<?xml version="1.0" encoding="UTF-8"?>
<!--Author: Benjamin W. Broersma <bw@broersma.com>, License: CC-0 -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:eml="urn:oasis:names:tc:evs:schema:eml"
  xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
  xmlns:kr="http://www.kiesraad.nl/extensions"
  xmlns:rg="http://www.kiesraad.nl/reportgenerator"
  xmlns:xal="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"
  xmlns:xnl="urn:oasis:names:tc:ciq:xsdschema:xNL:2.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="urn:oasis:names:tc:evs:schema:eml 510-count-v5-0.xsd http://www.kiesraad.nl/extensions kiesraad-eml-extensions.xsd">
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
  <xsl:template match="eml:EML">{
  <xsl:if test="eml:Result/eml:Election/eml:ElectionIdentifier/kr:ElectionDomain/@Id">
  "domein": <xsl:value-of select="eml:Result/eml:Election/eml:ElectionIdentifier/kr:ElectionDomain/@Id"/>,
  </xsl:if>
  "datum": "<xsl:value-of select="eml:Result/eml:Election/eml:ElectionIdentifier/kr:ElectionDate"/>",
  "code": "<xsl:value-of select="eml:Result/eml:Election/eml:ElectionIdentifier/@Id"/>",
  "naam": "<xsl:value-of select="eml:Result/eml:Election/eml:ElectionIdentifier/eml:ElectionName"/>",
  "resultaat": {<xsl:apply-templates select="eml:Result/eml:Election/eml:Contest/eml:Selection[eml:AffiliationIdentifier]"/>
  }
}</xsl:template>
  <xsl:template match="eml:Selection">
    "<xsl:value-of select="eml:AffiliationIdentifier/@Id"/>": <xsl:value-of select="count(following-sibling::eml:Selection[not(eml:AffiliationIdentifier) and preceding-sibling::eml:Selection[eml:AffiliationIdentifier][1][eml:AffiliationIdentifier/@Id = current()/eml:AffiliationIdentifier/@Id] ])"/><xsl:if test="position() != last()">,</xsl:if>
  </xsl:template>
</xsl:stylesheet>

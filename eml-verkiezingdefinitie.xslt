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
<xsl:template match="eml:EML">{
  "code": "<xsl:value-of select="eml:ElectionEvent/eml:Election/eml:ElectionIdentifier/@Id"/>",
  <xsl:if test="eml:ElectionEvent/eml:Election/eml:ElectionIdentifier/kr:ElectionDomain/@Id">
  "domein": <xsl:value-of select="eml:ElectionEvent/eml:Election/eml:ElectionIdentifier/kr:ElectionDomain/@Id"/>,
  </xsl:if>
  "naam": "<xsl:value-of select="eml:ElectionEvent/eml:Election/eml:ElectionIdentifier/eml:ElectionName"/>",
  "datum": "<xsl:value-of select="eml:ElectionEvent/eml:Election/eml:ElectionIdentifier/kr:ElectionDate"/>",
  "zetels": <xsl:value-of select="eml:ElectionEvent/eml:Election/kr:NumberOfSeats"/>
}
</xsl:template>
</xsl:stylesheet>
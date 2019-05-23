<?xml version="1.0" encoding="UTF-8"?>
<!--Author: Benjamin W. Broersma <bw@broersma.com> -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	 xmlns:eml="urn:oasis:names:tc:evs:schema:eml"
	 xmlns="urn:oasis:names:tc:evs:schema:eml"
	 xmlns:ns2="urn:oasis:names:tc:ciq:xsdschema:xAL:2.0"
	 xmlns:ns3="urn:oasis:names:tc:ciq:xsdschema:xNL:2.0"
	 xmlns:ns4="http://www.w3.org/2000/09/xmldsig#"
	 xmlns:ns5="urn:oasis:names:tc:evs:schema:eml:ts"
	 xmlns:ns6="http://www.kiesraad.nl/extensions"
	 xmlns:ns7="http://www.kiesraad.nl/reportgenerator"
	 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	 xsi:schemaLocation="urn:oasis:names:tc:evs:schema:eml 230-candidatelist-v5-0.xsd http://www.kiesraad.nl/extensions kiesraad-eml-extensions.xsd">
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
<xsl:template match="eml:EML">
{
    <xsl:apply-templates select="eml:CandidateList/eml:Election"/>
}
</xsl:template>
<xsl:template match="eml:Election">
	<xsl:apply-templates select="eml:ElectionIdentifier"/>
	<xsl:apply-templates select="eml:Contest"/>
</xsl:template>
<xsl:template match="eml:ElectionIdentifier">
    "code": "<xsl:value-of select="@Id"/>",
    "naam": "<xsl:value-of select="eml:ElectionName"/>",
    "categorie": "<xsl:value-of select="eml:ElectionCategory"/>",
    "datum": "<xsl:value-of select="ns6:ElectionDate"/>",
</xsl:template>
<xsl:template match="eml:Contest">
	<xsl:if test="eml:ContestIdentifier/@Id != 'geen'">
	"kieskring": "<xsl:value-of select="eml:ContestIdentifier/@Id"/>",
	</xsl:if>
	"lijsten": [<xsl:apply-templates select="eml:Affiliation"/>]
</xsl:template>
<xsl:template match="eml:Affiliation">
	{
		"lijstnummer": <xsl:value-of select="eml:AffiliationIdentifier/@Id"/>,
		"lijstnaam": "<xsl:call-template name="replace-string"><!--Yes this is needed!-->
            <xsl:with-param name="text" select="eml:AffiliationIdentifier/eml:RegisteredName/text()"/>
            <xsl:with-param name="replace" select="'&quot;'" />
            <xsl:with-param name="with" select="'\&quot;'"/>
          </xsl:call-template>",
		<xsl:if test="ns6:ListData[@BelongsToCombination]">
			"lijstverbinding": "<xsl:value-of select="ns6:ListData/@BelongsToCombination"/>",</xsl:if>
		"kandidaten": [<xsl:apply-templates select="eml:Candidate"/>]
	}<xsl:if test="position() != last()">,
   </xsl:if>
</xsl:template>
<xsl:template match="eml:Candidate">
	{
		"kandidaatnummer": <xsl:value-of select="eml:CandidateIdentifier/@Id"/>,
		<!-- "naam": { -->
		<xsl:apply-templates select="eml:CandidateFullName/ns3:PersonName"/>
		<!-- } -->,
		"geslacht":
		<xsl:choose>
			<xsl:when test="eml:Gender/text() = 'male'">
				"man"
			</xsl:when>
			<xsl:when test="eml:Gender/text() = 'female'">
				"vrouw"
			</xsl:when>
			<xsl:otherwise>
				"<xsl:value-of select="eml:Gender"/>"
			</xsl:otherwise>
		</xsl:choose>,
		"woonplaats": "<xsl:value-of select="eml:QualifyingAddress/ns2:Locality/ns2:LocalityName"/>"
	}<xsl:if test="position() != last()">,</xsl:if>
</xsl:template>
<xsl:template match="ns3:NameLine[@NameType='Initials']">
	"initialen": "<xsl:value-of select="." />",
</xsl:template>
<xsl:template match="ns3:FirstName">
	"voornaam": "<xsl:value-of select="." />",
</xsl:template>
<xsl:template match="ns3:NamePrefix">
	"tussenvoegsel": "<xsl:value-of select="." />",
</xsl:template>
<xsl:template match="ns3:LastName">
	"achternaam": "<xsl:value-of select="." />"
</xsl:template>
</xsl:stylesheet>

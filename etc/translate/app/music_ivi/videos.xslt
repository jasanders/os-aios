<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes=""
>

<xsl:output method="xml" encoding="utf-8" indent="yes"/>

<xsl:template match="/">
    <xsl:apply-templates select="//ul[@class='video-list video_list']//li"/>
</xsl:template>

<xsl:template match="li">
  <xsl:variable name="img" select="a[1]/span[1]/img" />
  <xsl:variable name="title" select="$img/@alt" />
  <xsl:variable name="link" select="concat('http://music.ivi.ru', a[1]/@href)" />
  <xsl:variable name="song" select="a[1]/span[2]/strong" />
  <xsl:variable name="artist" select="span/a" />
		<item>
			<title><xsl:value-of select="$title" /></title>
			<link><xsl:value-of select="$link" /></link>
			<description></description>
			<source url="http://music.ivi.ru/videos">misic.ivi.ru/videos</source>
			<image url="{$img/@src}" width="" height=""/>
			<artist><xsl:value-of select="$artist" /></artist>
			<song><xsl:value-of select="$song" /></song>
		</item>

</xsl:template>

<xsl:template match="* | @* | node()"/>

</xsl:stylesheet>
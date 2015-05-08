<?xml version='1.0' ?>
<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform'
                xmlns:fn='http://www.w3.org/2005/02/xpath-functions'
                xmlns:xsd='http://www.w3.org/2001/XSL/XMLSchema'
                xmlns:xsi='http://www.w3.org/2001/XSL/XMLSchema-instance'
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                xmlns:owl="http://www.w3.org/2002/07/owl#"
                xmlns:rednet="http://redgates.com/2015/5/rednet"
                version='1.0'>

  <dc:title>Generate OpenVPN Rednet config</dc:title>
  <dc:creator>Karl Redgate</dc:creator>
  <dc:description>
  Create a Rednet RDF configuration file for a specific client

  Read in an template RDF file and populate it with the certificate
  authority certificate, diffie hellman key, ssh public key, and
  server address.

  The resulting file is published to the ... for the client
  </dc:description>

  <xsl:param name='certificateFile' as="xsd:string">ERROR</xsl:param>
  <xsl:param name='clientCertificateFile' as="xsd:string"></xsl:param>
  <xsl:param name='serverKeyFile' as="xsd:string">ERROR</xsl:param>
  <xsl:param name='sshKeyFile' as="xsd:string">ERROR</xsl:param>
  <xsl:param name='serverAddress' as="xsd:string">ERROR</xsl:param>

  <xsl:output method="xml"
              cdata-section-elements='rednet:certificate rednet:key'
              omit-xml-declaration="yes" />

  <xsl:template match="comment()"/>

  <xsl:template match="@*|node()">
    <xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy>
  </xsl:template>

  <dc:description>
  </dc:description>
  <xsl:template match='rednet:CA/rednet:certificate'>
     <xsl:copy-of select='document($certificateFile)' />
  </xsl:template>

  <dc:description>
  </dc:description>
  <xsl:template match='rednet:Client/rednet:certificate'>
     <xsl:copy-of select='document($clientCertificateFile)' />
  </xsl:template>

  <dc:description>
  </dc:description>
  <xsl:template match='rednet:DH/rednet:key'>
     <xsl:copy-of select='document($serverKeyFile)' />
  </xsl:template>

  <dc:description>
  </dc:description>
  <xsl:template match='rednet:SSH/rednet:key'>
     <xsl:copy-of select='document($sshKeyFile)' />
  </xsl:template>

  <dc:description>
  </dc:description>
  <xsl:template match='rednet:Server/rednet:address'>
      <rednet:address><xsl:value-of select='$serverAddress' /></rednet:address>
  </xsl:template>

</xsl:stylesheet>
<!-- vim: set autoindent expandtab sw=4 syntax=xslt: -->

<?xml version="1.0" encoding="UTF-8"?>
<!-- ********************************************************** -->
<!-- digital-measures-faculty-public.xsl             -->
<!-- used to transform faculty data from Activity Insight     -->
<!-- into XML used in online faculty profiles.          -->
<!-- Adapted from XSLT from Eric Banford (efb13)        -->
<!-- ********************************************************** -->
<xsl:stylesheet version="1.0" xmlns:dm="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" encoding="UTF-8" method="xml" />
  <xsl:template match="dm:Data">
    <faculty><xsl:text>
      </xsl:text>
      <xsl:for-each select="//dm:Record">
        <xsl:sort select="dm:PCI/dm:LNAME"/>
        <xsl:variable name="thisnetid" select="@username"/>
        <xsl:variable name="thisdept" select="dmd:IndexEntry[ @indexKey = 'DEPARTMENT' ]"/>

        <xsl:choose>
          <xsl:when test="@username='mew15' or @username='emb6' or @username='mhd11' or @username='oji2' or @username='cm226' or @username='lrm32' or @username='plr27' or @username='rrs3' or @username='has34'"/>

          <xsl:otherwise>
            <person>
              <xsl:attribute name="id">
                <xsl:value-of select="@username"/>
              </xsl:attribute><xsl:text>
              </xsl:text>

              <xsl:apply-templates select="document('https://s3.amazonaws.com/ILR_Profile_Data_Pull/ldap.xml')//*[@username=$thisnetid]"/>

              <xsl:apply-templates select="document('https://s3.amazonaws.com/ILR_Profile_Data_Pull/legacy_ilr_directory_HTML.xml')//*[@username=$thisnetid]"/>

              <netID>
                <xsl:value-of select="@username"/>
              </netID><xsl:text>
              </xsl:text>

              <userid>
                <xsl:value-of select="@userId"/>
              </userid><xsl:text>
              </xsl:text>

              <departments>
                <xsl:apply-templates select="dm:ADMIN/dm:DEP"/>
                <xsl:apply-templates select="dm:ADMIN/dm:JOINT_APPT_DEP"/>
              </departments><xsl:text>
              </xsl:text>

              <xsl:apply-templates select="dm:ADMIN/dm:RANK"/>
              <xsl:text>
              </xsl:text>

              <xsl:apply-templates select="dm:PCI/dm:ALTERNATE_TITLE"/>
              <xsl:text>
              </xsl:text>

              <xsl:apply-templates select="dm:ADMIN_PERM/dm:ADMIN_PERM_HIRE/dm:SRANK"/>
              <xsl:text>
              </xsl:text>

              <graduate_fields>
                <xsl:apply-templates select="dm:ADMIN"/>
              </graduate_fields><xsl:text>
              </xsl:text>

              <acadvise_graduate>
                <xsl:apply-templates select="dm:ACADVISE_GRADUATE"/>
              </acadvise_graduate><xsl:text>
              </xsl:text>

              <education>
                  <xsl:apply-templates select="dm:EDUCATION"/>
              </education><xsl:text>
              </xsl:text>

              <teaching_statement>
                <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:FOCUS_TEACH_WEB"/>
              </teaching_statement><xsl:text>
              </xsl:text>

              <service_statement>
                <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:FOCUS_SERVICE_WEB"/>
              </service_statement><xsl:text>
              </xsl:text>

              <outreach_statement>
                <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:FOCUS_OUTREACH_WEB"/>
              </outreach_statement><xsl:text>
              </xsl:text>

              <research_statement>
                <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:FOCUS_RESEARCH_WEB"/>
              </research_statement><xsl:text>
              </xsl:text>

              <research_statement_short>
                <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:FOCUS_RESEARCH_SHORT"/>
              </research_statement_short><xsl:text>
              </xsl:text>

              <research_areas><xsl:text>
                </xsl:text>
                  <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:RESEARCH_AREA/dm:AREA"/>
              </research_areas><xsl:text>
              </xsl:text>

              <areas_of_expertise><xsl:text>
                </xsl:text>
                  <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:CONCENTRATION"/>
              </areas_of_expertise><xsl:text>
              </xsl:text>

              <other_expertise>
                  <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:CONCENTRATION_OTHER"/>
              </other_expertise><xsl:text>
              </xsl:text>

              <teaching_keywords>
                <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:TEACHING_KEYWORD/dm:KEYWORD"/>
              </teaching_keywords><xsl:text>
              </xsl:text>

              <research_keywords>
                <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:RESEARCH_KEYWORD/dm:KEYWORD"/>
              </research_keywords><xsl:text>
              </xsl:text>

              <outreach_keywords>
                <xsl:apply-templates select="dm:OUTREACH_STATEMENT/dm:OUTREACH_STATEMENT_KEYWORD/dm:KEYWORD"/>
              </outreach_keywords><xsl:text>
              </xsl:text>

              <overview>
                  <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:BIO"/>
              </overview><xsl:text>
              </xsl:text>

              <outreach_activities>
                <xsl:apply-templates select="dm:OUTREACH_STATEMENT"/>
              </outreach_activities>

              <xsl:text>
              </xsl:text>

              <professional_activities>
                <xsl:if test=". != ''">
                  <xsl:text disable-output-escaping="yes">
                  &lt;</xsl:text>
                  <xsl:text disable-output-escaping="yes">![CDATA[</xsl:text>
                  <ul class="professional-activities">
                  <xsl:apply-templates select="dm:PRESENT">
                    <xsl:sort order="descending" select="dm:DATE_START"/>
                  </xsl:apply-templates>
                  </ul>
                  <xsl:text disable-output-escaping="yes">]]</xsl:text>
                  <xsl:text disable-output-escaping="yes">>
                  </xsl:text>
                </xsl:if>

                <!-- <xsl:apply-templates select="dm:PRESENT">
                  <xsl:sort order="descending" select="dm:DATE_START"/>
                </xsl:apply-templates> -->
              </professional_activities>

              <xsl:text>
              </xsl:text>

              <honors_awards>
                <xsl:if test=". != ''">
                  <xsl:text disable-output-escaping="yes">
                  &lt;</xsl:text>
                  <xsl:text disable-output-escaping="yes">![CDATA[</xsl:text>
                  <ul class="honors">
                  <xsl:apply-templates select="dm:AWARDHONOR">
                    <xsl:sort order="descending" select="DTY_DATE"/>
                  </xsl:apply-templates>
                  </ul>
                  <xsl:text disable-output-escaping="yes">]]</xsl:text>
                  <xsl:text disable-output-escaping="yes">>
                  </xsl:text>
                </xsl:if>
                <!-- <xsl:apply-templates select="dm:AWARDHONOR">
                  <xsl:sort order="descending" select="DTY_DATE"/>
                </xsl:apply-templates> -->
              </honors_awards>

              <xsl:text>
              </xsl:text>

              <publications>
                <xsl:if test=". != ''">
                  <xsl:text disable-output-escaping="yes">
                  &lt;</xsl:text>
                  <xsl:text disable-output-escaping="yes">![CDATA[</xsl:text>
                  <ul class="articles">
                  <xsl:apply-templates select="dm:INTELLCONT_JOURNAL">
                    <xsl:sort order="descending" select="DTY_PUB"/>
                  </xsl:apply-templates>
                  </ul>
                  <ul class="pubs">
                  <xsl:apply-templates select="dm:INTELLCONT">
                    <xsl:sort order="descending" select="DTY_PUB"/>
                  </xsl:apply-templates>
                  </ul>
                  <xsl:text disable-output-escaping="yes">]]</xsl:text>
                  <xsl:text disable-output-escaping="yes">>
                  </xsl:text>
                </xsl:if>
              </publications>

              <xsl:text>
              </xsl:text>

              <links>
                <xsl:choose>
                  <xsl:when test="dm:PCI/dm:PCI_WEBSITE/dm:WEBSITE != ''">
                    <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
                    <xsl:text disable-output-escaping="yes">![CDATA[</xsl:text>
                    <ul class="links">
                    <xsl:apply-templates select="dm:PCI/dm:PCI_WEBSITE"/>
                    </ul>
                    <xsl:text disable-output-escaping="yes">]]</xsl:text>
                    <xsl:text disable-output-escaping="yes">>
                    </xsl:text>
                  </xsl:when>
                </xsl:choose>
              </links><xsl:text>
              </xsl:text>

            </person><xsl:text>
            </xsl:text>

          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each><xsl:text>
      </xsl:text>
    </faculty>
  </xsl:template>

  <xsl:template match="dm:ADMIN/dm:DEP">
    <xsl:if test="position() = 1">
      <dept>
        <xsl:apply-templates/>
      </dept><xsl:text>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:ADMIN/dm:JOINT_APPT_DEP">
    <xsl:if test="position() = 1">
      <dept>
        <xsl:apply-templates/>
      </dept><xsl:text>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:ADMIN/dm:RANK">
    <xsl:if test="position() = 1">
      <rank>
        <xsl:apply-templates/>
      </rank><xsl:text>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:PCI/dm:ALTERNATE_TITLE">
    <xsl:if test="position() = 1">
      <alternate_title>
        <xsl:apply-templates/>
      </alternate_title><xsl:text>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:ADMIN_PERM/dm:ADMIN_PERM_HIRE/dm:SRANK">
    <xsl:if test="position() = 1">
      <srank>
        <xsl:apply-templates/>
      </srank><xsl:text>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:ADMIN">
    <xsl:if test="position() = 1">
      <xsl:apply-templates select="dm:DISCIPLINE"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:ACADVISE_GRADUATE">
    <xsl:if test="position() = 1">
      <xsl:apply-templates select="dm:MEMBERSHIP"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:ldap_display_name">
    <ldap_display_name>
    <xsl:apply-templates/>
    </ldap_display_name>
  </xsl:template>

  <xsl:template match="dm:ldap_local_address">
    <ldap_local_address>
    <xsl:apply-templates/>
    </ldap_local_address>
  </xsl:template>

  <xsl:template match="dm:ldap_campus_address">
    <ldap_campus_address>
    <xsl:apply-templates/>
    </ldap_campus_address>
  </xsl:template>

  <xsl:template match="dm:ldap_campus_phone">
    <ldap_campus_phone>
    <xsl:variable name="this_campus_phone" select="."/>
    <xsl:value-of select="substring-before($this_campus_phone,'/')" /><xsl:text>-</xsl:text>
    <xsl:value-of select="substring-after($this_campus_phone,'/')" />
    </ldap_campus_phone>
  </xsl:template>

  <xsl:template match="dm:ldap_email">
    <ldap_email>
    <xsl:apply-templates/>
    </ldap_email>
  </xsl:template>

  <xsl:template match="dm:ldap_working_title1">
    <ldap_working_title1>
    <xsl:apply-templates/>
    </ldap_working_title1>
  </xsl:template>

  <xsl:template match="dm:ldap_working_title2">
    <ldap_working_title2>
    <xsl:apply-templates/>
    </ldap_working_title2>
  </xsl:template>

  <xsl:template match="dm:ldap_uid">
    <ldap_uid>
    <xsl:apply-templates/>
    </ldap_uid>
  </xsl:template>

  <xsl:template match="dm:ldap_employee_type">
    <ldap_employee_type>
    <xsl:apply-templates/>
    </ldap_employee_type>
  </xsl:template>

  <xsl:template match="dm:ldap_department_name">
    <ldap_department_name>
    <xsl:apply-templates/>
    </ldap_department_name>
  </xsl:template>

  <xsl:template match="dm:ldap_department">
    <ldap_department>
    <xsl:apply-templates/>
    </ldap_department>
  </xsl:template>

  <xsl:template match="dm:ldap_first_name">
    <ldap_first_name>
    <xsl:apply-templates/>
    </ldap_first_name>
  </xsl:template>

  <xsl:template match="dm:ldap_last_name">
    <ldap_last_name>
    <xsl:apply-templates/>
    </ldap_last_name>
  </xsl:template>

  <xsl:template match="dm:ldap_mail_nickname">
    <ldap_mail_nickname>
    <xsl:apply-templates/>
    </ldap_mail_nickname>
  </xsl:template>

  <xsl:template match="dm:ldap_nickname">
    <ldap_nickname>
    <xsl:apply-templates/>
    </ldap_nickname>
  </xsl:template>

  <xsl:template match="dm:ldap_profile_type">
    <ldap_profile_type>
    <xsl:apply-templates/>
    </ldap_profile_type>
  </xsl:template>

  <xsl:template match="dm:ldap_leave_start">
    <ldap_leave_start>
    <xsl:apply-templates/>
    </ldap_leave_start>
  </xsl:template>

  <xsl:template match="dm:ldap_leave_end">
    <ldap_leave_end>
    <xsl:apply-templates/>
    </ldap_leave_end>
  </xsl:template>

  <xsl:template match="dm:ilrweb_publications_type">
    <ilrweb_publications_type>
    <xsl:apply-templates/>
    </ilrweb_publications_type>
  </xsl:template>

  <xsl:template match="dm:ilrweb_publications_doc">
    <ilrweb_publications_doc>
    <xsl:if test=". != ''">
      <xsl:text>http://www.ilr.cornell.edu</xsl:text>
      <xsl:apply-templates/>
    </xsl:if>
    </ilrweb_publications_doc>
  </xsl:template>

  <xsl:template match="dm:ilrweb_publications">
    <xsl:variable name="source">
      <xsl:value-of select="@source"/>
    </xsl:variable>
    <ilrweb_publications source="{$source}">
    <xsl:if test=". != ''">
      <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
      <xsl:text disable-output-escaping="yes">![CDATA[
      </xsl:text>
      <xsl:value-of select="." disable-output-escaping="yes" />
      <xsl:text disable-output-escaping="yes">
      ]]</xsl:text>
      <xsl:text disable-output-escaping="yes">>
      </xsl:text>
    </xsl:if>
    </ilrweb_publications>
    <xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:ilrweb_overview">
    <ilrweb_overview>
    <xsl:if test=". != ''">
      <xsl:text disable-output-escaping="yes">&lt;</xsl:text>
      <xsl:text disable-output-escaping="yes">![CDATA[
      </xsl:text>
      <xsl:value-of select="." disable-output-escaping="yes" />
      <xsl:text disable-output-escaping="yes">
      ]]</xsl:text>
      <xsl:text disable-output-escaping="yes">></xsl:text>
    </xsl:if>
    </ilrweb_overview>
    <xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:ilrweb_research">
    <ilrweb_research>
    <xsl:apply-templates/>
    </ilrweb_research>
    <xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:ilrweb_expertise">
    <ilrweb_expertise><xsl:text>
      </xsl:text>
      <xsl:apply-templates select="dm:ilrweb-expert"/>
    </ilrweb_expertise>
  </xsl:template>

  <xsl:template match="dm:ilrweb_expert">
    <ilrweb_expert>
    <xsl:copy-of select="./text()"/>
    </ilrweb_expert><xsl:text>
      </xsl:text>
  </xsl:template>

  <xsl:template match="dm:ilrweb_other_expertise">
    <ilrweb_other_expertise>
    <xsl:apply-templates/>
    </ilrweb_other_expertise>
  </xsl:template>

  <xsl:template match="dm:ilrweb_vita_type">
    <ilrweb_vita_type>
    <xsl:apply-templates/>
    </ilrweb_vita_type>
  </xsl:template>

  <xsl:template match="dm:ilrweb_vita_file">
    <ilrweb_vita_file>
    <xsl:apply-templates/>
    </ilrweb_vita_file>
  </xsl:template>

  <xsl:template match="dm:ilrweb_vita_html">
    <ilrweb_vita_html>
    <xsl:if test=". != ''">
      <xsl:text disable-output-escaping="yes">
        &lt;</xsl:text>
      <xsl:text disable-output-escaping="yes">![CDATA[
      </xsl:text>
      <xsl:value-of select="." disable-output-escaping="yes" />
      <xsl:text disable-output-escaping="yes">
      ]]</xsl:text>
      <xsl:text disable-output-escaping="yes">>
      </xsl:text>
    </xsl:if>
    </ilrweb_vita_html>
  </xsl:template>

  <xsl:template match="dm:ilrweb_photo_url">
    <ilrweb_photo_url>
    <xsl:apply-templates/>
    </ilrweb_photo_url>
  </xsl:template>

  <xsl:template match="dm:DISCIPLINE">
    <field>
    <xsl:apply-templates/>
    </field><xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:MEMBERSHIP">
    <membership>
    <xsl:apply-templates/>
    </membership><xsl:text>
    </xsl:text>
  </xsl:template>

  <!--  efb13 2012-02-13 chg concentration from         -->
  <!--   research-statement to 3 statement keywords        -->
  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:CONCENTRATION">
    <xsl:choose>
      <xsl:when test="position() = 1">
        <xsl:apply-templates select="dm:NARRATIVE_INTERESTS/dm:CONCENTRATION"/>
      </xsl:when>
      <xsl:otherwise>
        <area_of_expertise />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:CONCENTRATION">
    <xsl:variable name="thisexpertise" select="."/>
    <xsl:value-of select="substring-after($thisexpertise,'ILR-')" /><xsl:text>|</xsl:text>
  </xsl:template>

  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:CONCENTRATION_OTHER">
    <xsl:apply-templates/><xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:EDUCATION">
    <xsl:if test="dm:PUBLIC_VIEW='Yes'">
      <xsl:text>
      </xsl:text>
      <degree>
        <level>
          <xsl:choose>
            <xsl:when test="dm:DEG='BA'">Bachelor of Arts</xsl:when>
            <xsl:when test="dm:DEG='AB'">Bachelor of Arts</xsl:when>
            <xsl:when test="dm:DEG='B. Sc.'">Bachelor of Science</xsl:when>
            <xsl:when test="dm:DEG='BA'">Bachelor of Arts</xsl:when>
            <xsl:when test="dm:DEG='BS'">Bachelor of Science</xsl:when>
            <xsl:when test="dm:DEG='BSc'">Bachelor of Science</xsl:when>
            <xsl:when test="dm:DEG='M. Sc.'">Master of Science</xsl:when>
            <xsl:when test="dm:DEG='M.Phil'">Master of Philosophy</xsl:when>
            <xsl:when test="dm:DEG='MA'">Master's Degree</xsl:when>
            <xsl:when test="dm:DEG='MPS'">Master of Professional Studies</xsl:when>
            <xsl:when test="dm:DEG='MS'">Master of Science</xsl:when>
            <xsl:when test="dm:DEG='MSc'">Master of Science</xsl:when>
            <xsl:when test="dm:DEG='Other'">
              <xsl:value-of select="dm:DEGOTHER"/>
            </xsl:when>
            <xsl:when test="dm:DEG='Ph D'">Doctorate</xsl:when>
            <xsl:otherwise>
            <xsl:value-of select="dm:DEG"/>
            </xsl:otherwise>
          </xsl:choose>
        </level>
        <degother>
          <xsl:value-of select="dm:DEGOTHER"/>
        </degother>
        <year>
          <xsl:value-of select="dm:YR_COMP"/>
        </year>
        <institution>
          <xsl:value-of select="dm:SCHOOL"/>
        </institution>
      </degree><xsl:text>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:BIO">
    <xsl:apply-templates/><xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:FOCUS_TEACH_WEB">
    <xsl:if test=". != ''">
      <xsl:text disable-output-escaping="yes">
      &lt;</xsl:text>
      <xsl:text disable-output-escaping="yes">![CDATA[</xsl:text>
      <xsl:apply-templates/><xsl:text>
      </xsl:text>
      <xsl:text disable-output-escaping="yes">]]</xsl:text>
      <xsl:text disable-output-escaping="yes">>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:FOCUS_SERVICE_WEB">
    <xsl:if test=". != ''">
      <xsl:text disable-output-escaping="yes">
      &lt;</xsl:text>
      <xsl:text disable-output-escaping="yes">![CDATA[</xsl:text>
      <xsl:apply-templates/><xsl:text>
      </xsl:text>
      <xsl:text disable-output-escaping="yes">]]</xsl:text>
      <xsl:text disable-output-escaping="yes">>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:FOCUS_OUTREACH_WEB">
    <xsl:if test=". != ''">
      <xsl:text disable-output-escaping="yes">
      &lt;</xsl:text>
      <xsl:text disable-output-escaping="yes">![CDATA[</xsl:text>
      <xsl:apply-templates/><xsl:text>
      </xsl:text>
      <xsl:text disable-output-escaping="yes">]]</xsl:text>
      <xsl:text disable-output-escaping="yes">>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:FOCUS_RESEARCH_WEB">
    <xsl:if test=". != ''">
      <xsl:text disable-output-escaping="yes">
      &lt;</xsl:text>
      <xsl:text disable-output-escaping="yes">![CDATA[</xsl:text>
      <xsl:apply-templates/><xsl:text>
      </xsl:text>
      <xsl:text disable-output-escaping="yes">]]</xsl:text>
      <xsl:text disable-output-escaping="yes">>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:FOCUS_RESEARCH_SHORT">
    <xsl:if test=". != ''">
      <xsl:text disable-output-escaping="yes">
      &lt;</xsl:text>
      <xsl:text disable-output-escaping="yes">![CDATA[</xsl:text>
      <xsl:apply-templates/><xsl:text>
      </xsl:text>
      <xsl:text disable-output-escaping="yes">]]</xsl:text>
      <xsl:text disable-output-escaping="yes">>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:OUTREACH_STATEMENT/dm:OUTREACH_STATEMENT_KEYWORD/dm:KEYWORD">
    <keyword><xsl:value-of select="normalize-space(.)"/></keyword><xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:RESEARCH_KEYWORD/dm:KEYWORD">
    <keyword><xsl:value-of select="normalize-space(.)"/></keyword><xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:TEACHING_KEYWORD/dm:KEYWORD">
    <keyword><xsl:value-of select="normalize-space(.)"/></keyword><xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:NARRATIVE_INTERESTS/dm:RESEARCH_AREA/dm:AREA">
    <area><xsl:value-of select="normalize-space(.)"/></area><xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:RESEARCH_STATEMENT">
    <xsl:choose>
      <xsl:when test="dm:PUBLIC_VIEW='Yes'">
        <xsl:apply-templates select="dm:INTERESTS"/>
      </xsl:when>
      <xsl:otherwise>
        <focus>
          <type>Research Focus</type>
          <description />
        </focus><xsl:text>
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="dm:RESEARCH_STATEMENT/dm:INTERESTS">
    <focus>
      <type>Research Focus</type>
      <description>
        <xsl:apply-templates/>
      </description>
    </focus><xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:OUTREACH_STATEMENT">
      <xsl:if test="dm:PUBLIC_VIEW='Yes'">
        <xsl:apply-templates select="dm:INTERESTS"/>
      </xsl:if>
  </xsl:template>

  <xsl:template match="dm:OUTREACH_STATEMENT/dm:INTERESTS">
     <outreach_activity>
        <xsl:apply-templates/>
      </outreach_activity><xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:TEACHING_STATEMENT">
    <xsl:choose>
      <xsl:when test="dm:PUBLIC_VIEW='Yes'">
        <xsl:apply-templates select="dm:INTERESTS"/>
      </xsl:when>
      <xsl:otherwise>
        <focus>
          <type>Instruction Focus</type>
          <description />
        </focus><xsl:text>
        </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="dm:TEACHING_STATEMENT/dm:INTERESTS">
    <focus>
      <type>Instruction Focus</type>
      <description>
        <xsl:apply-templates/>
      </description>
    </focus><xsl:text>
    </xsl:text>
  </xsl:template>

  <xsl:template match="dm:PRESENT">
    <xsl:if test="dm:PUBLIC_VIEW='Yes'">
      <li class="presentation">
        <xsl:if test="dm:TITLE != ''"><span class=""><xsl:value-of select="dm:TITLE"/>. </span></xsl:if>
        <xsl:if test="dm:ORG != ''"><span class="">Presented to <xsl:value-of select="dm:ORG"/>. </span></xsl:if>
        <xsl:if test="dm:LOCATION != ''"><span class=""><xsl:value-of select="dm:LOCATION"/>. </span></xsl:if>
        <xsl:if test="dm:DTY_DATE != ''"><span class=""><xsl:value-of select="dm:DTY_DATE"/>.</span></xsl:if>
      </li>
      <xsl:text>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:AWARDHONOR">
    <xsl:if test="dm:PUBLIC_VIEW='Yes'">
      <li class="honor">
        <xsl:if test="dm:NAME != ''"><span class="award-name"><xsl:value-of select="dm:NAME"/>, </span></xsl:if>
        <xsl:if test="dm:ORG != ''"><span class="award-organization"><xsl:value-of select="dm:ORG"/>. </span></xsl:if>
        <xsl:if test="dm:DTY_END != ''"><span class="award-year"><xsl:value-of select="dm:DTY_END"/></span></xsl:if>
      </li>
      <xsl:text>
      </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dm:INTELLCONT/dm:INTELLCONT_AUTH">
    <xsl:value-of select="dm:FNAME"/><xsl:text> </xsl:text>
    <xsl:choose><xsl:when test="dm:MNAME != ''"><xsl:value-of select="dm:MNAME"/><xsl:text>. </xsl:text></xsl:when></xsl:choose>
    <xsl:value-of select="dm:LNAME"/><xsl:choose><xsl:when test="not(following-sibling::dm:INTELLCONT_JOURNAL/dm:INTELLCONT_AUTH)"><xsl:text>, </xsl:text></xsl:when></xsl:choose>
  </xsl:template>

  <xsl:template match="dm:INTELLCONT_JOURNAL">
    <xsl:choose>
    <xsl:when test="dm:PUBLIC_VIEW='Yes' and dm:USER_REFERENCE_CREATOR='Yes'">
      <li class="journal-article">
        <xsl:apply-templates select="dm:INTELLCONT_JOURNAL_AUTH"/><xsl:text>. </xsl:text>
        <span class="year"><xsl:value-of select="dm:DTY_PUB"/>. </span>
        <span class="title"><xsl:choose>
            <xsl:when test="dm:URI_NUM != ''">
              <xsl:choose>
                <xsl:when test="dm:URI_TYPE='ARXIV'">
                  <a href="http://arxiv.org/abs/{dm:URI_NUM}"><xsl:value-of select="dm:TITLE"/></a>
                  <xsl:variable name="pub_id">(ARXIV:<xsl:value-of select="dm:URI_NUM"/>)</xsl:variable>
                </xsl:when>
                <xsl:when test="dm:URI_TYPE='DOI'">
                  <a href="http://dx.doi.org/doi:{dm:URI_NUM}"><xsl:value-of select="dm:TITLE"/></a>
                  <xsl:variable name="pub_id">(DOI:<xsl:value-of select="dm:URI_NUM"/>)</xsl:variable>
                </xsl:when>
                <xsl:when test="dm:URI_TYPE='Pubmed'">
                  <a href="http://www.ncbi.nlm.nih.gov/pubmed/{dm:URI_NUM}"><xsl:value-of select="dm:TITLE"/></a>
                  <xsl:variable name="pub_id">(Pubmed:<xsl:value-of select="dm:URI_NUM"/>)</xsl:variable>
                </xsl:when>
                <xsl:otherwise>
                  <a href="{dm:URI_NUM}"><xsl:value-of select="dm:TITLE"/></a>
                  <xsl:variable name="pub_id" />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:variable name="pub_id" />
              <xsl:value-of select="dm:TITLE"/></xsl:otherwise></xsl:choose>, </span>
        <span class="journal-title">
          <xsl:choose>
            <xsl:when test="dm:TITLE='Other'">
              <xsl:value-of select="dm:JOURNAL_NAME_OTHER"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="dm:JOURNAL_NAME"/>
            </xsl:otherwise>
          </xsl:choose>. </span>
        <span class="location"><xsl:value-of select="dm:VOLUME"/>
        <xsl:choose>
          <xsl:when test="dm:ISSUE != ''">
            <xsl:text>(</xsl:text><xsl:value-of select="dm:ISSUE"/><xsl:text>)</xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:text>:</xsl:text><xsl:value-of select="dm:PAGENUM"/>.</span><xsl:choose><xsl:when test="dm:URI_NUM != ''"><xsl:choose>
          <xsl:when  test="dm:URI_TYPE='ARXIV'"> (ARXIV:<xsl:value-of select="dm:URI_NUM"/>)</xsl:when>
          <xsl:when  test="dm:URI_TYPE='DOI'"> (doi:<xsl:value-of select="dm:URI_NUM"/>)</xsl:when>
          <xsl:when  test="dm:URI_TYPE='(Pubmed:'"> (Pubmed:<xsl:value-of select="dm:URI_NUM"/>)</xsl:when>
          <xsl:otherwise /></xsl:choose></xsl:when></xsl:choose>
        </li><xsl:text>
      </xsl:text>
    </xsl:when>
    <xsl:otherwise>
    </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="dm:INTELLCONT_JOURNAL/dm:INTELLCONT_JOURNAL_AUTH">
    <xsl:value-of select="dm:FNAME"/><xsl:text> </xsl:text>
    <xsl:choose><xsl:when test="dm:MNAME != ''"><xsl:value-of select="dm:MNAME"/><xsl:text>. </xsl:text></xsl:when></xsl:choose>
    <xsl:value-of select="dm:LNAME"/><xsl:choose><xsl:when test="following-sibling::dm:INTELLCONT_JOURNAL_AUTH"><xsl:text>, </xsl:text></xsl:when></xsl:choose>
  </xsl:template>

  <xsl:template match="dm:PCI/dm:PCI_WEBSITE">
    <xsl:text>
    </xsl:text>
    <li class="link">
      <xsl:variable name="hyperlink"><xsl:value-of select="dm:WEBSITE" /></xsl:variable>
      <a href="{$hyperlink}">
        <xsl:value-of select="dm:DESC"/>
      </a>
    </li>
  </xsl:template>

  <xsl:template name="tail">
    <xsl:param name="string" select="."/>
    <xsl:choose>
      <xsl:when test="substring-after($string,' ')">
        <xsl:call-template name="tail">
        <xsl:with-param name="string" select="substring-after($string,' ')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- output each publication type in preferred order -->
  <xsl:template match="dm:INTELLCONT">
    <xsl:call-template name="outputpub">
      <xsl:with-param name="pubtype">Book Chapter</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="outputpub">
      <xsl:with-param name="pubtype">Book, Scholarly</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="outputpub">
      <xsl:with-param name="pubtype">Book Review</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="outputpub">
      <xsl:with-param name="pubtype">Conference Proceeding</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="outputpub">
      <xsl:with-param name="pubtype">Abstract</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="outputpub">
    <xsl:param name="pubtype" />
      <xsl:choose>
      <xsl:when test="dm:CONTYPE=$pubtype and dm:PUBLIC_VIEW='Yes' and dm:USER_REFERENCE_CREATOR='Yes'">
        <li class="publication">
          <span class="title"><xsl:value-of select="dm:TITLE"/>. </span>
          <span class="book-title"><xsl:value-of select="dm:BOOK_TITLE"/>. </span>
          <span class="pubctyst"><xsl:value-of select="dm:PUBCTYST"/>: </span>
          <span class="publisher"><xsl:value-of select="dm:PUBLISHER"/>, </span>
          <span class="year"><xsl:value-of select="dm:DTY_PUB"/>. </span>
          <span class="authors"><xsl:apply-templates select="dm:INTELLCONT_JOURNAL_AUTH"/><xsl:text>. </xsl:text></span>
          <span class="editors"><xsl:value-of select="dm:EDITORS"/>. </span>
          <span class="pages">(<xsl:value-of select="dm:PAGENUM"/>)</span>
          <span class="status">(<xsl:value-of select="dm:STATUS"/>)</span>
          <span class="content-type">(<xsl:value-of select="dm:CONTYPE"/>)</span>
        </li>
        <xsl:text>
        </xsl:text>
      </xsl:when>
      </xsl:choose>
  </xsl:template>

</xsl:stylesheet>

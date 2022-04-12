<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xpath-default-namespace="http://protege.stanford.edu/xml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xslt" xmlns:pro="http://protege.stanford.edu/xml" xmlns:eas="http://www.enterprise-architecture.org/essential" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ess="http://www.enterprise-architecture.org/essential/errorview">
    <xsl:include href="../../common/core_utilities.xsl"/>
	<xsl:include href="../../common/core_js_functions.xsl"/>
	<xsl:output method="text" encoding="UTF-8"/>
	<xsl:param name="param1"/> 


	<xsl:variable name="techProductBuild" select="/node()/simple_instance[type=('Technology_Product_Build')]"/>

	<xsl:variable name="deploymentRole" select="/node()/simple_instance[type=('Deployment_Role')]"/>
	<xsl:variable name="applicationDeployment" select="/node()/simple_instance[type=('Application_Deployment')][own_slot_value[slot_reference='application_deployment_technical_arch']/value=$techProductBuild/name]"/>
	<xsl:variable name="techBuildArchitecture" select="/node()/simple_instance[type=('Technology_Build_Architecture')]"/>
	<xsl:variable name="techComponent" select="/node()/simple_instance[type=('Technology_Component')]"/>
	<xsl:variable name="techProduct" select="/node()/simple_instance[type=('Technology_Product')]"/>
	<xsl:variable name="techProductRole" select="/node()/simple_instance[type=('Technology_Product_Role')]"/>
	<xsl:variable name="tpu" select="/node()/simple_instance[type=('Technology_Provider_Usage')]"/>
	<xsl:variable name="tpuRelation" select="/node()/simple_instance[type=(':TPU-TO-TPU-RELATION')]"/>
 	 <xsl:variable name="applications" select="/node()/simple_instance[type=('Application_Provider', 'Composite_Application_Provider')][name=$applicationDeployment/own_slot_value[slot_reference='application_provider_deployed']/value]"/>
 
	<xsl:key name="appDeployment_key" match="/node()/simple_instance[type=('Application_Deployment')]" use="own_slot_value[slot_reference = 'application_provider_deployed']/value"/>
	<xsl:key name="apptechbuild_key" match="/node()/simple_instance[type=('Technology_Build_Architecture')]" use="own_slot_value[slot_reference = 'describes_technology_provider']/value"/>
	<xsl:key name="tpu_key" match="/node()/simple_instance[type=('Technology_Provider_Usage')]" use="own_slot_value[slot_reference = 'used_in_technology_provider_architecture']/value"/>
	<xsl:key name="tputpu_key" match="/node()/simple_instance[type=(':TPU-TO-TPU-RELATION')]" use="own_slot_value[slot_reference = ':FROM']/value"/>
	<xsl:key name="techprod_key" match="/node()/simple_instance[type=('Technology_Product')]" use="own_slot_value[slot_reference = 'implements_technology_components']/value"/>
	<xsl:key name="techcomp_key" match="/node()/simple_instance[type=('Technology_Component')]" use="own_slot_value[slot_reference = 'realised_by_technology_products']/value"/>

	<!--
		* Copyright © 2008-2019 Enterprise Architecture Solutions Limited.
	 	* This file is part of Essential Architecture Manager, 
	 	* the Essential Architecture Meta Model and The Essential Project.
		*
		* Essential Architecture Manager is free software: you can redistribute it and/or modify
		* it under the terms of the GNU General Public License as published by
		* the Free Software Foundation, either version 3 of the License, or
		* (at your option) any later version.
		*
		* Essential Architecture Manager is distributed in the hope that it will be useful,
		* but WITHOUT ANY WARRANTY; without even the implied warranty of
		* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		* GNU General Public License for more details.
		*
		* You should have received a copy of the GNU General Public License
		* along with Essential Architecture Manager.  If not, see <http://www.gnu.org/licenses/>.
		* 
	-->
	<!-- 03.09.2019 JP  Created	 -->
	 
	<xsl:template match="knowledge_base">
		{"application_technology_architecture":[<xsl:apply-templates select="$applications" mode="applicationsTechArch"><xsl:sort select="own_slot_value[slot_reference='name']/value" order="ascending"/></xsl:apply-templates>],"version":"615"}
	</xsl:template>

	 
 <xsl:template match="node()" mode="applicationsTechArch">
	<xsl:variable name="thisDeployment" select="key('appDeployment_key',current()/name)"/>  
	{
	"id":"<xsl:value-of select="eas:getSafeJSString(current()/name)"/>",
	"application":"<xsl:call-template name="RenderMultiLangInstanceName"><xsl:with-param name="theSubjectInstance" select="current()"/><xsl:with-param name="isForJSONAPI" select="true()"/></xsl:call-template>",
	"supportingTech":[<xsl:for-each select="$thisDeployment">
	  <xsl:variable name="thisProductBuild" select="$techProductBuild[name=current()/own_slot_value[slot_reference='application_deployment_technical_arch']/value]"/>
	 <xsl:variable name="thistechBuildArchitecture" select="key('apptechbuild_key',$thisProductBuild/name)"/>    
	 <xsl:variable name="thistpu" select="key('tpu_key',$thistechBuildArchitecture/name)"/>  
	 <xsl:variable name="thisTpuRelation" select="key('tputpu_key',$thistpu/name)"/>    
	 <xsl:variable name="deploymentType" select="current()/own_slot_value[slot_reference='application_deployment_role']/value"/>	 
	 
			<xsl:for-each select="$thisTpuRelation">
			<xsl:variable name="sourcetpu" select="$tpu[name=current()/own_slot_value[slot_reference=':TO']/value]"/>
			<xsl:variable name="sourcetechProductRole" select="$techProductRole[name=$sourcetpu/own_slot_value[slot_reference='provider_as_role']/value]"/>
			<xsl:variable name="targettpu" select="$tpu[name=current()/own_slot_value[slot_reference=':FROM']/value]"/>
			<xsl:variable name="targettechProductRole" select="$techProductRole[name=$targettpu/own_slot_value[slot_reference='provider_as_role']/value]"/>
			<xsl:variable name="thisTechProdsSource" select="key('techprod_key',$sourcetechProductRole/name)"/>  
			<xsl:variable name="thisTechProdsTarget" select="key('techprod_key',$targettechProductRole/name)"/>  
			<xsl:variable name="thisTechCompsSource" select="key('techcomp_key',$sourcetechProductRole/name)"/>  
			<xsl:variable name="thisTechCompsTarget" select="key('techcomp_key',$targettechProductRole/name)"/>  
			{ 
			"fromTechProduct":"<xsl:value-of select="$thisTechProdsSource/own_slot_value[slot_reference='name']/value"/>",
			"fromTechComponent":"<xsl:value-of select="$thisTechCompsSource/own_slot_value[slot_reference='name']/value"/>",
			"toTechProduct":"<xsl:value-of select="$thisTechProdsTarget/own_slot_value[slot_reference='name']/value"/>",
			"toTechComponent":"<xsl:value-of select="$thisTechCompsTarget/own_slot_value[slot_reference='name']/value"/>",
			"fromTechProductId":"<xsl:value-of select="$thisTechProdsSource/name"/>",
			"fromTechComponentId":"<xsl:value-of select="$thisTechCompsSource/name"/>",
			"toTechProductId":"<xsl:value-of select="$thisTechProdsTarget/name"/>",
			"toTechComponentId":"<xsl:value-of select="$thisTechCompsTarget/name"/>",
			"environment":"<xsl:value-of select="$deploymentRole[name=$deploymentType]/name"/>",<xsl:call-template name="RenderSecurityClassificationsJSONForInstance"><xsl:with-param name="theInstance" select="current()"/></xsl:call-template>
			}, 
		</xsl:for-each>
		 
		</xsl:for-each>{}]
		,<xsl:call-template name="RenderSecurityClassificationsJSONForInstance"><xsl:with-param name="theInstance" select="current()"/></xsl:call-template>}<xsl:if test="position()!=last()">,</xsl:if>
  </xsl:template>

	
</xsl:stylesheet>

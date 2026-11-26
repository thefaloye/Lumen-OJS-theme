{**
 * templates/frontend/components/header.tpl
 *
 * Lumen theme: common frontend header (top bar, brand row, navigation).
 * Opens the page wrapper; footer.tpl closes it.
 *
 * @uses $lmHome bool Set by indexJournal.tpl: render the full-width homepage
 *       shell instead of the content + sidebar shell used by inner pages.
 * @uses $isFullWidth bool Should this page be displayed without sidebars?
 *}
{strip}
	{assign var="showingLogo" value=true}
	{if !$displayPageHeaderLogo}
		{assign var="showingLogo" value=false}
	{/if}
{/strip}
<!DOCTYPE html>
<html lang="{$currentLocale|replace:"_":"-"}" xml:lang="{$currentLocale|replace:"_":"-"}">
{if !$pageTitleTranslated}{capture assign="pageTitleTranslated"}{translate key=$pageTitle}{/capture}{/if}
{include file="frontend/components/headerHead.tpl"}
<body class="pkp_page_{$requestedPage|escape|default:"index"} pkp_op_{$requestedOp|escape|default:"index"} lm_body{if $lmHome} lm_is_home{/if}{if $showingLogo} has_site_logo{/if}" dir="{$currentLocaleLangDir|escape|default:"ltr"}">

	<div class="pkp_structure_page lm_page">

		<header class="lm_header" id="headerNavigationContainer" role="banner">
			{include file="frontend/components/skipLinks.tpl"}

			{* ---- Top bar: tagline, utility links, account ---- *}
			<div class="lm_topbar">
				<div class="lm_container lm_topbar_inner">
					<p class="lm_topbar_tagline">{$lumen.topbarTagline|escape}</p>
					<div class="lm_topbar_actions">
						{load_menu name="lumenTopbar" id="lmTopbarNav" ulClass="lm_topbar_menu" liClass="lm_topbar_item"}
						<div class="lm_user" id="navigationUserWrapper">
							{load_menu name="user" id="lmUserNav" ulClass="lm_user_menu" liClass="profile"}
						</div>
					</div>
				</div>
			</div>

			{* ---- Brand row: logo, title, ISSN, submit ---- *}
			<div class="lm_brandrow">
				<div class="lm_container lm_brandrow_inner">
					{capture assign="homeUrl"}{url page="index"}{/capture}
					{if $currentJournal}
						{assign var="lmOnlineIssn" value=$currentJournal->getData('onlineIssn')}
						{assign var="lmPrintIssn" value=$currentJournal->getData('printIssn')}
					{/if}

					<a class="lm_brand" href="{$homeUrl}">
						{if $displayPageHeaderLogo}
							<img class="lm_brand_logo" src="{$publicFilesDir}/{$displayPageHeaderLogo.uploadName|escape:"url"}" width="{$displayPageHeaderLogo.width|escape}" height="{$displayPageHeaderLogo.height|escape}" alt="{$displayPageHeaderLogo.altText|escape}">
						{elseif $lumen.monogram}
							<span class="lm_monogram" aria-hidden="true">{$lumen.monogram|escape}</span>
						{/if}
						<span class="lm_brand_text">
							<span class="lm_site_title">{if $currentContext}{$displayPageHeaderTitle|escape}{else}{$siteTitle|escape}{/if}</span>
							{if $lmOnlineIssn || $lmPrintIssn}
								<span class="lm_issn">
									{if $lmOnlineIssn}<span>ISSN {$lmOnlineIssn|escape} ({translate key="plugins.themes.lumen.issnOnline"})</span>{/if}
									{if $lmPrintIssn}<span>ISSN {$lmPrintIssn|escape} ({translate key="plugins.themes.lumen.issnPrint"})</span>{/if}
								</span>
							{/if}
						</span>
					</a>

					<div class="lm_brandrow_actions">
						{if $currentContext && $requestedPage !== 'search'}
							<a href="{url page="search"}" class="lm_icon_link lm_search_link">
								<span class="fa fa-search" aria-hidden="true"></span>
								<span class="lm_sr">{translate key="common.search"}</span>
							</a>
						{/if}
						{if $currentJournal}
							<a href="{url page="submission" op="wizard"}" class="lm_btn lm_btn--accent lm_btn--sm">{translate key="plugins.themes.lumen.submitManuscript"}</a>
						{/if}
						<button type="button" class="lm_nav_toggle" aria-expanded="false" aria-controls="lmPrimaryNav">
							<span class="lm_nav_toggle_bars" aria-hidden="true"></span>
							<span class="lm_nav_toggle_label">{translate key="plugins.themes.lumen.openMenu"}</span>
						</button>
					</div>
				</div>
			</div>

			{* ---- Primary navigation ---- *}
			<nav class="lm_nav" aria-label="{translate|escape key="common.navigation.site"}" data-submenu-label="{translate|escape key="plugins.themes.lumen.submenuLabel"}">
				<a id="siteNav"></a>
				<div class="lm_container">
					{load_menu name="primary" id="lmPrimaryNav" ulClass="lm_menu" liClass="lm_menu_item"}
				</div>
			</nav>
		</header><!-- .lm_header -->

		{* ---- Page content shell ---- *}
		{if $isFullWidth}
			{assign var=hasSidebar value=0}
		{/if}
		{if $lmHome}
		<main class="lm_home" id="lmMain" role="main">
			<a id="pkp_content_main"></a>
		{else}
		<div class="pkp_structure_content{if $hasSidebar} has_sidebar{/if}">
			<div class="pkp_structure_main" role="main">
				<a id="pkp_content_main"></a>
		{/if}

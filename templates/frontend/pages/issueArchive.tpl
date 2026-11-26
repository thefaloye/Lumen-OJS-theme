{**
 * templates/frontend/pages/issueArchive.tpl
 *
 * Lumen: the issue archive, grouped by year, with a year filter and a quick
 * search that are added by js/lumen.js (without JavaScript every issue is
 * simply listed). Variables are the same on OJS 3.4 and 3.5.
 *}
{capture assign="pageTitle"}
	{if $prevPage}
		{translate key="archive.archivesPageNumber" pageNumber=$prevPage+1}
	{else}
		{translate key="archive.archives"}
	{/if}
{/capture}
{include file="frontend/components/header.tpl" pageTitleTranslated=$pageTitle}

<div class="page page_issue_archive lm_archive">
	{include file="frontend/components/breadcrumbs.tpl" currentTitle=$pageTitle}

	<header class="lm_page_head">
		<p class="lm_eyebrow">{translate key="plugins.themes.lumen.archive.eyebrow"}</p>
		<h1>{$pageTitle|escape}</h1>
		<p class="lm_page_lead">{translate key="plugins.themes.lumen.archive.lead"}</p>
	</header>

	{if empty($issues)}
		<p class="lm_empty">{translate key="current.noCurrentIssueDesc"}</p>
	{else}
		{* Year filter and search: built by js/lumen.js, which reads these labels *}
		{capture assign=lmLabelYear}{translate key="plugins.themes.lumen.archive.browseByYear"}{/capture}
		{capture assign=lmLabelAll}{translate key="plugins.themes.lumen.archive.all"}{/capture}
		{capture assign=lmLabelSearch}{translate key="plugins.themes.lumen.archive.search"}{/capture}
		{capture assign=lmLabelNone}{translate key="plugins.themes.lumen.archive.noMatches"}{/capture}
		<div class="lm_archive_tools" hidden
			data-label-year="{$lmLabelYear|escape}"
			data-label-all="{$lmLabelAll|escape}"
			data-label-search="{$lmLabelSearch|escape}"
			data-label-none="{$lmLabelNone|escape}"></div>

		<div class="lm_archive_years">
			{assign var=lmYear value=''}
			{foreach from=$issues item="issue" name="lmIssues"}
				{assign var=lmThisYear value=$issue->getYear()}
				{if $smarty.foreach.lmIssues.first || $lmThisYear != $lmYear}
					{if !$smarty.foreach.lmIssues.first}
						</ul>
						</section>
					{/if}
					<section class="lm_year" data-year="{$lmThisYear|escape}">
						<header class="lm_year_head">
							<h2>{if $lmThisYear}{$lmThisYear|escape}{else}{translate key="plugins.themes.lumen.archive.otherIssues"}{/if}</h2>
							<span class="lm_year_label">{translate key="plugins.themes.lumen.archive.publishedIssues"}</span>
						</header>
						<ul class="issues_archive lm_issue_list">
					{assign var=lmYear value=$lmThisYear}
				{/if}
				<li class="lm_issue_item">
					{include file="frontend/objects/issue_summary.tpl" lmLatest=($smarty.foreach.lmIssues.first && !$prevPage)}
				</li>
			{/foreach}
						</ul>
					</section>
		</div>

		{* Pagination *}
		{if $prevPage > 1}
			{capture assign=prevUrl}{url page="issue" op="archive" path=$prevPage}{/capture}
		{elseif $prevPage === 1}
			{capture assign=prevUrl}{url page="issue" op="archive"}{/capture}
		{/if}
		{if $nextPage}
			{capture assign=nextUrl}{url page="issue" op="archive" path=$nextPage}{/capture}
		{/if}
		{include
			file="frontend/components/pagination.tpl"
			prevUrl=$prevUrl
			nextUrl=$nextUrl
			showingStart=$showingStart
			showingEnd=$showingEnd
			total=$total
		}
	{/if}
</div><!-- .page -->

{include file="frontend/components/footer.tpl"}

{**
 * templates/frontend/objects/issue_summary.tpl
 *
 * Lumen: one issue card on the archive page. Cover on the left; status label,
 * title, volume line, date, description and two buttons on the right.
 *
 * @uses $issue Issue
 * @uses $lmLatest bool Marks the newest issue
 *}
{if $issue->getShowTitle()}
	{assign var=issueTitle value=$issue->getLocalizedTitle()}
{/if}
{assign var=issueSeries value=$issue->getIssueSeries()}
{assign var=issueCover value=$issue->getLocalizedCoverImageUrl()}
{capture assign=issueUrl}{url page="issue" op="view" path=$issue->getBestIssueId()}{/capture}
{assign var=issueDescription value=$issue->getLocalizedDescription()|strip_tags|trim}

<article class="obj_issue_summary lm_issue{if $lmLatest} lm_issue--latest{/if}">
	<a class="cover lm_issue_cover" href="{$issueUrl}" tabindex="-1" aria-hidden="true">
		{if $issueCover}
			<img src="{$issueCover|escape}" alt="{$issue->getLocalizedCoverImageAltText()|escape|default:''}" loading="lazy">
		{else}
			<span class="lm_issue_cover_ph">
				<span class="lm_issue_cover_mark">{$lumen.monogram|escape}</span>
				<span class="lm_issue_cover_series">{$issueSeries|escape}</span>
			</span>
		{/if}
	</a>

	<div class="lm_issue_body">
		<p class="lm_issue_flag">
			{if $lmLatest}{translate key="plugins.themes.lumen.archive.latest"}{else}{translate key="plugins.themes.lumen.archive.archiveIssue"}{/if}
		</p>
		<h3 class="lm_issue_title">
			<a class="title" href="{$issueUrl}">
				{if $issueTitle}{$issueTitle|escape}{else}{$currentJournal->getLocalizedName()|escape}{/if}
			</a>
		</h3>
		{if $issueSeries}
			<p class="series lm_issue_series">{$issueSeries|escape}</p>
		{/if}
		{if $issue->getDatePublished()}
			<p class="lm_issue_date">
				{translate key="plugins.themes.lumen.archive.published"}
				<time>{$issue->getDatePublished()|date_format:$dateFormatLong}</time>
			</p>
		{/if}
		<div class="description lm_issue_desc">
			{if $issueDescription}
				{$issueDescription|truncate:220:"…"|escape}
			{else}
				{translate key="plugins.themes.lumen.archive.defaultDescription"}
			{/if}
		</div>
		<p class="lm_issue_actions">
			<a class="lm_btn lm_btn--primary" href="{$issueUrl}">{translate key="plugins.themes.lumen.archive.viewIssue"} <span aria-hidden="true">&rarr;</span></a>
			<a class="lm_btn lm_btn--ghost" href="{$issueUrl}#pkp_content_main">{translate key="plugins.themes.lumen.archive.toc"}</a>
		</p>
	</div>
</article><!-- .obj_issue_summary -->

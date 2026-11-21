{**
 * templates/frontend/pages/indexJournal.tpl
 *
 * Lumen theme: journal homepage.
 *
 * @uses $currentJournal Journal This journal
 * @uses $journalDescription string Journal description from HTML text editor
 * @uses $homepageImage object Image to be displayed in the hero
 * @uses $additionalHomeContent string Arbitrary input from HTML text editor
 * @uses $announcements array List of announcements
 * @uses $numAnnouncementsHomepage int Number of announcements to display
 * @uses $issue Issue Current issue
 * @uses $publishedSubmissions array Current issue articles, grouped by section
 * @uses $lumen array Theme data (see LumenThemePlugin::loadTemplateData)
 *}
{include file="frontend/components/header.tpl" pageTitleTranslated=$currentJournal->getLocalizedName() lmHome=true}

{call_hook name="Templates::Index::journal"}

{* OJS 3.5: journal highlights carousel configured under Website > Highlights *}
{if $lumen.coreHighlights && isset($highlights) && is_object($highlights) && $highlights->count()}
	{include file="frontend/components/highlights.tpl" highlights=$highlights}
{/if}

{* ============ Hero ============ *}
<section class="lm_hero">
	<div class="lm_container lm_hero_grid">
		<div class="lm_hero_copy">
			<p class="lm_eyebrow">{$lumen.heroEyebrow|escape}</p>
			<h1 class="lm_hero_title">{$currentJournal->getLocalizedName()|escape}</h1>
			<p class="lm_hero_subtitle">{$lumen.heroSubtitle|escape}</p>
			<p class="lm_hero_text">{$lumen.heroText|escape}</p>
			<div class="lm_actions">
				<a class="lm_btn lm_btn--accent" href="{url page="issue" op="current"}">
					{translate key="plugins.themes.lumen.currentIssueArrow"} <span aria-hidden="true">&rarr;</span>
				</a>
				<a class="lm_btn lm_btn--outline" href="{url page="search"}">{translate key="plugins.themes.lumen.exploreArticles"}</a>
			</div>
		</div>
		<div class="lm_hero_art">
			<div class="lm_hero_frame">
				{if $homepageImage}
					<img src="{$publicFilesDir}/{$homepageImage.uploadName|escape:"url"}" alt="{$homepageImage.altText|escape}">
				{else}
					<img src="{$lumen.heroFallbackImage|escape}" alt="">
				{/if}
			</div>
		</div>
	</div>
</section>

{* ============ Highlights strip ============ *}
{if $lumen.highlights}
	<div class="lm_container lm_highlights_wrap">
		<ul class="lm_highlights" aria-label="{translate|escape key="plugins.themes.lumen.highlightsLabel"}">
			{foreach from=$lumen.highlights item=lmHighlight}
				<li class="lm_highlight">
					<strong class="lm_highlight_title">{$lmHighlight.title|escape}</strong>
					{if $lmHighlight.text}<span class="lm_highlight_text">{$lmHighlight.text|escape}</span>{/if}
				</li>
			{/foreach}
		</ul>
	</div>
{/if}

{* ============ Latest research (current issue) ============ *}
{if $issue}
	<section class="lm_section lm_latest" aria-labelledby="lmLatestTitle">
		<a id="homepageIssue"></a>
		<div class="lm_container">
			<header class="lm_section_head">
				<div>
					<p class="lm_eyebrow lm_eyebrow--dark">{translate key="plugins.themes.lumen.currentScholarship"}</p>
					<h2 class="lm_section_title" id="lmLatestTitle">{translate key="plugins.themes.lumen.latestResearch"}</h2>
				</div>
				<a class="lm_link_arrow" href="{url page="issue" op="current"}">{translate key="plugins.themes.lumen.viewCurrentIssue"} <span aria-hidden="true">&rarr;</span></a>
			</header>

			<div class="lm_latest_grid">

				{* -- Issue card -- *}
				<article class="lm_issue_card">
					{assign var=lmIssueCover value=$issue->getLocalizedCoverImageUrl()}
					{if $lmIssueCover}
						{capture assign="lmDefaultAlt"}{translate key="issue.viewIssueIdentification" identification=$issue->getIssueIdentification()|escape}{/capture}
						<a class="lm_issue_cover" href="{url page="issue" op="view" path=$issue->getBestIssueId()}">
							<img src="{$lmIssueCover|escape}" alt="{$issue->getLocalizedCoverImageAltText()|escape|default:$lmDefaultAlt}">
						</a>
					{/if}
					<div class="lm_issue_body">
						<p class="lm_label">{translate key="journal.currentIssue"}</p>
						<h3 class="lm_issue_title">{$issue->getIssueIdentification()|strip_unsafe_html}</h3>
						{if $issue->getDatePublished()}
							<p class="lm_meta">{translate key="submissions.published"}: {$issue->getDatePublished()|date_format:$dateFormatShort}</p>
						{/if}
						{if $issue->hasDescription()}
							<div class="lm_issue_desc">{$issue->getLocalizedDescription()|strip_unsafe_html}</div>
						{/if}
						<div class="lm_actions">
							<a class="lm_btn lm_btn--primary lm_btn--sm" href="{url page="issue" op="view" path=$issue->getBestIssueId()}">{translate key="plugins.themes.lumen.viewIssue"}</a>
							<a class="lm_btn lm_btn--ghost lm_btn--sm" href="{url page="issue" op="archive"}">{translate key="plugins.themes.lumen.allIssues"}</a>
						</div>
					</div>
				</article>

				{* -- Article cards (first six articles of the issue) -- *}
				<div class="lm_articles">
					<h3 class="lm_sr">{translate key="plugins.themes.lumen.articles"}</h3>
					{assign var="lmShown" value=0}
					{assign var="lmLimit" value=6}
					{foreach from=$publishedSubmissions item=lmSection}
						{foreach from=$lmSection.articles item=article}
							{if $lmShown >= $lmLimit}{break}{/if}
							{assign var="lmShown" value=$lmShown+1}

							{assign var=publication value=$article->getCurrentPublication()}
							{assign var=articlePath value=$publication->getData('urlPath')|default:$article->getId()}
							{assign var="lmShowAuthor" value=false}
							{if (!$lmSection.hideAuthor && $publication->getData('hideAuthor') == \APP\submission\Submission::AUTHOR_TOC_DEFAULT) || $publication->getData('hideAuthor') == \APP\submission\Submission::AUTHOR_TOC_SHOW}
								{assign var="lmShowAuthor" value=true}
							{/if}
							{assign var="lmAbstract" value=$publication->getLocalizedData('abstract')}

							<article class="lm_article_card">
								{if $lmSection.title}<p class="lm_label">{$lmSection.title|escape}</p>{/if}
								<h4 class="lm_article_title">
									<a id="article-{$article->getId()}" href="{url page="article" op="view" path=$articlePath}">
										{$publication->getLocalizedTitle(null, 'html')|strip_unsafe_html}
									</a>
								</h4>
								{if $lmShowAuthor}
									<p class="lm_article_authors">{$publication->getAuthorString($authorUserGroups)|escape}</p>
								{/if}
								{if $lmAbstract}
									<p class="lm_article_excerpt">{$lmAbstract|strip_tags|truncate:240:"…"|escape:"html":"UTF-8":false}</p>
								{/if}
								<div class="lm_article_foot">
									<a class="lm_link_arrow lm_link_arrow--sm" href="{url page="article" op="view" path=$articlePath}">{translate key="plugins.themes.lumen.viewArticle"} <span aria-hidden="true">&rarr;</span></a>
									{if $publication->getData('pages')}<span class="lm_pages">{$publication->getData('pages')|escape}</span>{/if}
									{if $article->getGalleys()}
										<ul class="lm_galleys galleys_links">
											{foreach from=$article->getGalleys() item=galley}
												{if $primaryGenreIds}
													{assign var="file" value=$galley->getFile()}
													{if !$galley->getData('urlRemote') && !($file && in_array($file->getGenreId(), $primaryGenreIds))}
														{continue}
													{/if}
												{/if}
												<li>
													{assign var="hasArticleAccess" value=$hasAccess}
													{if $currentContext->getSetting('publishingMode') == \APP\journal\Journal::PUBLISHING_MODE_OPEN || $publication->getData('accessStatus') == \APP\submission\Submission::ARTICLE_ACCESS_OPEN}
														{assign var="hasArticleAccess" value=1}
													{/if}
													{assign var="id" value="article-{$article->getId()}-galley-{$galley->getId()}"}
													{include file="frontend/objects/galley_link.tpl" parent=$article publication=$publication id=$id labelledBy="{$id} article-{$article->getId()}" hasAccess=$hasArticleAccess purchaseFee=$currentJournal->getData('purchaseArticleFee') purchaseCurrency=$currentJournal->getData('currency')}
												</li>
											{/foreach}
										</ul>
									{/if}
								</div>
								{call_hook name="Templates::Issue::Issue::Article"}
							</article>
						{/foreach}
					{/foreach}

					<p class="lm_articles_more">
						<a class="lm_link_arrow" href="{url page="issue" op="archive"}">{translate key="plugins.themes.lumen.viewAllIssues"} <span aria-hidden="true">&rarr;</span></a>
					</p>
				</div>
			</div>
		</div>
	</section>
{/if}

{* ============ About + subject scope ============ *}
{if $journalDescription || $lumen.scope}
	<section class="lm_section lm_section--paper lm_about" aria-labelledby="lmAboutTitle">
		<a id="homepageAbout"></a>
		<div class="lm_container lm_about_grid{if !$journalDescription || !$lumen.scope} lm_about_grid--single{/if}">
			{if $journalDescription}
				<div class="lm_about_main">
					<header class="lm_section_head lm_section_head--inline">
						<h2 class="lm_section_title" id="lmAboutTitle">{translate key="about.aboutContext"}</h2>
						<a class="lm_link_arrow" href="{url page="about"}">{translate key="plugins.themes.lumen.learnMore"} <span aria-hidden="true">&rarr;</span></a>
					</header>
					<div class="lm_prose">{$journalDescription}</div>
				</div>
			{/if}
			{if $lumen.scope}
				<aside class="lm_scope_card" aria-labelledby="lmScopeTitle">
					<h2 class="lm_scope_title" id="lmScopeTitle">{translate key="plugins.themes.lumen.subjectScope"}</h2>
					<ul class="lm_scope_list">
						{foreach from=$lumen.scope item=lmSubject}
							<li>{$lmSubject|escape}</li>
						{/foreach}
					</ul>
				</aside>
			{/if}
		</div>
	</section>
{/if}

{* ============ Announcements ============ *}
{if $lumen.news}
	<section class="lm_section lm_news" aria-labelledby="lmNewsTitle">
		<a id="homepageAnnouncements"></a>
		<div class="lm_container">
			<header class="lm_section_head">
				<h2 class="lm_section_title" id="lmNewsTitle">{translate key="announcement.announcements"}</h2>
				<a class="lm_link_arrow" href="{url page="announcement"}">{translate key="plugins.themes.lumen.viewAll"} <span aria-hidden="true">&rarr;</span></a>
			</header>
			<div class="lm_news_grid">
				{foreach from=$lumen.news item=lmNews}
					<a class="lm_news_card" href="{url page="announcement" op="view" path=$lmNews.id}">
						{if $lmNews.time}<time class="lm_news_date">{$lmNews.time|date_format:$dateFormatShort}</time>{/if}
						<h3 class="lm_news_title">{$lmNews.title|escape}</h3>
						<p class="lm_news_text">{$lmNews.text|strip_tags|truncate:120:"…"|escape:"html":"UTF-8":false}</p>
						<span class="lm_news_arrow" aria-hidden="true">&rarr;</span>
					</a>
				{/foreach}
			</div>
		</div>
	</section>
{/if}

{* ============ Indexing and abstracting ============ *}
{if $lumen.indexing}
	<section class="lm_section lm_section--paper lm_indexing" aria-labelledby="lmIndexTitle">
		<div class="lm_container">
			<header class="lm_section_head">
				<h2 class="lm_section_title" id="lmIndexTitle">{translate key="plugins.themes.lumen.indexed"}</h2>
			</header>
			<ul class="lm_index_list">
				{foreach from=$lumen.indexing item=lmIndex}
					<li>
						{if $lmIndex.url}<a class="lm_index_item" href="{$lmIndex.url|escape}" rel="noopener">{else}<span class="lm_index_item">{/if}
							{if $lmIndex.image}
								<img src="{$lmIndex.image|escape}" alt="{$lmIndex.name|escape}" loading="lazy">
							{else}
								{$lmIndex.name|escape}
							{/if}
						{if $lmIndex.url}</a>{else}</span>{/if}
					</li>
				{/foreach}
			</ul>
		</div>
	</section>
{/if}

{* ============ Newsletter + submit ============ *}
<section class="lm_section lm_cta">
	<div class="lm_container lm_cta_grid{if !$lumen.newsletterAction} lm_cta_grid--single{/if}">
		{if $lumen.newsletterAction}
			<div class="lm_cta_card lm_cta_card--news">
				<h2 class="lm_cta_title">{translate key="plugins.themes.lumen.stayInformed"}</h2>
				<p>{translate key="plugins.themes.lumen.stayInformedText"}</p>
				<form class="lm_news_form" action="{$lumen.newsletterAction|escape}" method="post" target="_blank" rel="noopener">
					<label class="lm_sr" for="lmNewsEmail">{translate key="plugins.themes.lumen.emailAddress"}</label>
					<input type="email" id="lmNewsEmail" name="EMAIL" required placeholder="{translate|escape key="plugins.themes.lumen.emailAddress"}">
					<button type="submit" class="lm_btn lm_btn--primary">{translate key="plugins.themes.lumen.subscribe"}</button>
				</form>
			</div>
		{/if}
		<div class="lm_cta_card lm_cta_card--submit">
			<h2 class="lm_cta_title">{translate key="plugins.themes.lumen.submitCardTitle"}</h2>
			<p>{translate key="plugins.themes.lumen.submitCardText"}</p>
			<a class="lm_btn lm_btn--accent" href="{url page="submission" op="wizard"}">{translate key="plugins.themes.lumen.submitManuscript"} <span aria-hidden="true">&rarr;</span></a>
		</div>
	</div>
</section>

{* ============ Additional homepage content (from Website settings) ============ *}
{if $additionalHomeContent}
	<section class="lm_section lm_additional">
		<div class="lm_container lm_prose">
			{$additionalHomeContent}
		</div>
	</section>
{/if}

{include file="frontend/components/footer.tpl" lmHome=true}

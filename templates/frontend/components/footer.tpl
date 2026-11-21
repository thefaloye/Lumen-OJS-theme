{**
 * templates/frontend/components/footer.tpl
 *
 * Lumen theme: common frontend footer. Closes the shell opened in header.tpl.
 *
 * @uses $lmHome bool See header.tpl.
 * @uses $isFullWidth bool Should this page be displayed without sidebars?
 *}

{if $lmHome}
		</main><!-- .lm_home -->
{else}
			</div><!-- .pkp_structure_main -->

			{* Sidebars *}
			{if empty($isFullWidth)}
				{capture assign="sidebarCode"}{call_hook name="Templates::Common::Sidebar"}{/capture}
				{if $sidebarCode}
					<div class="pkp_structure_sidebar left" role="complementary">
						{$sidebarCode}
					</div><!-- .pkp_structure_sidebar -->
				{/if}
			{/if}
		</div><!-- .pkp_structure_content -->
{/if}

		<footer class="lm_footer" role="contentinfo">
			<a id="pkp_content_footer"></a>

			<div class="lm_container lm_footer_grid">

				<div class="lm_footer_col lm_footer_brand">
					<a class="lm_brand lm_brand--footer" href="{url page="index"}">
						{if $displayPageHeaderLogo}
							<img class="lm_brand_logo" src="{$publicFilesDir}/{$displayPageHeaderLogo.uploadName|escape:"url"}" width="{$displayPageHeaderLogo.width|escape}" height="{$displayPageHeaderLogo.height|escape}" alt="{$displayPageHeaderLogo.altText|escape}">
						{elseif $lumen.monogram}
							<span class="lm_monogram" aria-hidden="true">{$lumen.monogram|escape}</span>
						{/if}
						<span class="lm_site_title">{if $currentContext}{$displayPageHeaderTitle|escape}{else}{$siteTitle|escape}{/if}</span>
					</a>
					<p class="lm_footer_tagline">{$lumen.footerTagline|escape}</p>
				</div>

				{if $currentJournal}
					<nav class="lm_footer_col" aria-labelledby="lmFooterQuick">
						<h2 class="lm_footer_heading" id="lmFooterQuick">{translate key="plugins.themes.lumen.quickLinks"}</h2>
						{capture assign="lmQuickMenu"}{load_menu name="lumenFooterQuick" id="lmFooterQuickNav" ulClass="lm_footer_list" liClass="lm_footer_item"}{/capture}
						{assign var="lmQuickCheck" value=$lmQuickMenu|regex_replace:"/\s+/":""}
						{if $lmQuickCheck}
							{$lmQuickMenu}
						{else}
							<ul class="lm_footer_list">
								<li><a href="{url page="issue" op="current"}">{translate key="navigation.current"}</a></li>
								<li><a href="{url page="issue" op="archive"}">{translate key="navigation.archives"}</a></li>
								<li><a href="{url page="about"}">{translate key="navigation.about"}</a></li>
								<li><a href="{url page="about" op=$lumen.editorialOp}">{translate key="plugins.themes.lumen.editorialTeam"}</a></li>
								<li><a href="{url page="about" op="contact"}">{translate key="about.contact"}</a></li>
							</ul>
						{/if}
					</nav>

					<nav class="lm_footer_col" aria-labelledby="lmFooterPolicies">
						<h2 class="lm_footer_heading" id="lmFooterPolicies">{translate key="plugins.themes.lumen.policies"}</h2>
						{capture assign="lmPolicyMenu"}{load_menu name="lumenFooterPolicies" id="lmFooterPoliciesNav" ulClass="lm_footer_list" liClass="lm_footer_item"}{/capture}
						{assign var="lmPolicyCheck" value=$lmPolicyMenu|regex_replace:"/\s+/":""}
						{if $lmPolicyCheck}
							{$lmPolicyMenu}
						{else}
							<ul class="lm_footer_list">
								<li><a href="{url page="about" op="submissions"}">{translate key="about.submissions"}</a></li>
								<li><a href="{url page="about" op="privacy"}">{translate key="plugins.themes.lumen.privacy"}</a></li>
							</ul>
						{/if}
					</nav>
				{/if}

				{if $lumen.social}
					<div class="lm_footer_col">
						<h2 class="lm_footer_heading">{translate key="plugins.themes.lumen.connect"}</h2>
						<ul class="lm_social">
							{foreach from=$lumen.social item=lmLink}
								<li><a href="{$lmLink.url|escape}" rel="noopener">{$lmLink.label|escape}</a></li>
							{/foreach}
						</ul>
					</div>
				{/if}
			</div>

			{if $pageFooter}
				<div class="lm_container lm_footer_custom">
					{$pageFooter}
				</div>
			{/if}

			<div class="lm_footer_bottom">
				<div class="lm_container lm_footer_bottom_inner">
					<p>{translate key="plugins.themes.lumen.footerCopyright" year=$smarty.now|date_format:"%Y" name=$displayPageHeaderTitle|escape}</p>
					<a class="lm_powered" href="{url page="about" op="aboutThisPublishingSystem"}">{translate key="plugins.themes.lumen.poweredBy"}</a>
				</div>
			</div>
		</footer><!-- .lm_footer -->

	</div><!-- .pkp_structure_page -->

{load_script context="frontend"}

{call_hook name="Templates::Common::Footer::PageFooter"}
</body>
</html>

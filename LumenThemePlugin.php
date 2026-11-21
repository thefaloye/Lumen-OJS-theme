<?php

/**
 * @file plugins/themes/lumen/LumenThemePlugin.php
 *
 * Distributed under the GNU GPL v3.
 *
 * @class LumenThemePlugin
 *
 * @brief Lumen: an editorial, card-based journal theme for OJS 3.4.
 *        It is a child of the Default theme, so every inner page (article,
 *        issue, archive, login, search, ...) keeps working while the header,
 *        footer and journal homepage are replaced.
 */

namespace APP\plugins\themes\lumen;

use APP\core\Application;
use APP\template\TemplateManager;
use PKP\plugins\Hook;
use PKP\plugins\ThemePlugin;

class LumenThemePlugin extends ThemePlugin
{
    public const DEFAULT_PRIMARY = '#14284b';
    public const DEFAULT_ACCENT = '#c8963e';

    /**
     * @copydoc ThemePlugin::isActive()
     */
    public function isActive()
    {
        if ($this->isSessionDisabled()) {
            return true;
        }
        return parent::isActive();
    }

    /**
     * True when OJS runs without a session (CLI tools, scheduled tasks).
     * OJS 3.5 replaced SessionManager with PKPSessionGuard, so ask whichever exists.
     */
    protected function isSessionDisabled(): bool
    {
        if (class_exists('\\PKP\\core\\PKPSessionGuard')) {
            return (bool) \PKP\core\PKPSessionGuard::isSessionDisable();
        }
        if (class_exists('\\PKP\\session\\SessionManager')) {
            return (bool) \PKP\session\SessionManager::isDisabled();
        }
        return false;
    }

    /** True on OJS 3.5 or newer. */
    protected function isOjs35(): bool
    {
        try {
            $version = Application::get()->getCurrentVersion()->getVersionString();
        } catch (\Throwable $e) {
            return false;
        }
        return version_compare((string) $version, '3.5', '>=');
    }

    /**
     * Register options, styles, scripts, menu areas and hooks.
     */
    public function init()
    {
        $this->setParent('defaultthemeplugin');

        // The parent's typography and colour pickers are replaced by this
        // theme's own options, so hide the ones that would have no effect.
        foreach (['typography', 'baseColour', 'showDescriptionInJournalIndex', 'useHomepageImageAsHeader'] as $name) {
            $this->removeOption($name);
        }

        $this->registerOptions();

        // ---- Colours and fonts -------------------------------------------
        $primary = $this->safeColour($this->getOption('primaryColor'), self::DEFAULT_PRIMARY);
        $accent = $this->safeColour($this->getOption('accentColor'), self::DEFAULT_ACCENT);
        $useGoogleFonts = (bool) $this->getOption('useGoogleFonts');

        // Re-colour (and optionally re-type) every page that is still drawn by
        // the parent theme, by feeding extra LESS variables into its stylesheet.
        $lessVariables = '@primary:' . $primary . ';@bg-base:' . $primary . ';@text-bg-base:#fff;';
        if ($useGoogleFonts) {
            $lessVariables .= '@font:"Inter",-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif;';
            $lessVariables .= '@font-heading:"Source Serif 4",Georgia,"Times New Roman",serif;';
        }
        $parentStyle = &$this->getStyle('stylesheet');
        if (is_array($parentStyle)) {
            $parentStyle['addLessVariables'] = ($parentStyle['addLessVariables'] ?? '') . "\n" . $lessVariables;
        }
        unset($parentStyle);

        if ($useGoogleFonts) {
            // Replace the parent's bundled Noto Sans with Inter + Source Serif 4.
            $this->removeStyle('font');
            $this->addStyle(
                'lumenFonts',
                'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;0,8..60,700;1,8..60,400&display=swap',
                ['baseUrl' => '']
            );
        }

        // Colour tokens used by styles/lumen.css
        $this->addStyle(
            'lumenTokens',
            ':root{--lm-primary:' . $primary . ';--lm-accent:' . $accent . ';'
                . ($useGoogleFonts
                    ? '--lm-font:"Inter",-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Helvetica Neue",Arial,sans-serif;--lm-font-serif:"Source Serif 4",Georgia,"Times New Roman",serif;'
                    : '')
                . '}',
            ['inline' => true, 'priority' => TemplateManager::STYLE_SEQUENCE_LATE]
        );
        $this->addStyle('lumen', 'styles/lumen.css', ['priority' => TemplateManager::STYLE_SEQUENCE_LAST]);

        $this->addScript('lumen', 'js/lumen.js');

        // ---- Navigation menu areas ---------------------------------------
        // Assign a navigation menu to each one under Website > Navigation Menus.
        $this->addMenuArea(['primary', 'user', 'lumenTopbar', 'lumenFooterQuick', 'lumenFooterPolicies']);

        // ---- Template data ------------------------------------------------
        Hook::add('TemplateManager::display', [$this, 'loadTemplateData']);
    }

    /**
     * Theme options shown under Website > Appearance > Theme.
     */
    protected function registerOptions(): void
    {
        $this->addOption('primaryColor', 'FieldColor', [
            'label' => __('plugins.themes.lumen.option.primaryColor.label'),
            'description' => __('plugins.themes.lumen.option.primaryColor.description'),
            'default' => self::DEFAULT_PRIMARY,
        ]);
        $this->addOption('accentColor', 'FieldColor', [
            'label' => __('plugins.themes.lumen.option.accentColor.label'),
            'description' => __('plugins.themes.lumen.option.accentColor.description'),
            'default' => self::DEFAULT_ACCENT,
        ]);
        $this->addOption('useGoogleFonts', 'FieldOptions', [
            'label' => __('plugins.themes.lumen.option.useGoogleFonts.label'),
            'description' => __('plugins.themes.lumen.option.useGoogleFonts.description'),
            'options' => [
                ['value' => true, 'label' => __('plugins.themes.lumen.option.useGoogleFonts.option')],
            ],
            'default' => true,
        ]);

        $text = [
            'topbarTagline' => 'FieldText',
            'heroEyebrow' => 'FieldText',
            'heroSubtitle' => 'FieldText',
            'heroText' => 'FieldTextarea',
            'highlights' => 'FieldTextarea',
            'subjectScope' => 'FieldTextarea',
            'indexing' => 'FieldTextarea',
            'newsletterAction' => 'FieldText',
            'footerTagline' => 'FieldText',
            'social' => 'FieldTextarea',
        ];
        foreach ($text as $name => $type) {
            $this->addOption($name, $type, [
                'label' => __('plugins.themes.lumen.option.' . $name . '.label'),
                'description' => __('plugins.themes.lumen.option.' . $name . '.description'),
                'default' => '',
            ]);
        }
    }

    /**
     * Assign the `$lumen` array used by the header, footer and homepage.
     *
     * @param string $hookName
     * @param array $args [TemplateManager, &template, &output]
     */
    public function loadTemplateData($hookName, $args)
    {
        $templateMgr = $args[0];
        $request = Application::get()->getRequest();
        $context = $request->getContext();

        $highlights = [];
        foreach ($this->pairs($this->getOption('highlights'), 2) as [$title, $text]) {
            $highlights[] = ['title' => $title, 'text' => $text];
        }
        if (!$highlights && !$this->hasValue('highlights')) {
            for ($i = 1; $i <= 4; $i++) {
                $highlights[] = [
                    'title' => __('plugins.themes.lumen.default.highlight' . $i . '.title'),
                    'text' => __('plugins.themes.lumen.default.highlight' . $i . '.text'),
                ];
            }
        }

        $indexing = [];
        foreach ($this->pairs($this->getOption('indexing'), 3) as [$name, $url, $image]) {
            $indexing[] = ['name' => $name, 'url' => $this->safeUrl($url), 'image' => $this->safeUrl($image)];
        }

        $social = [];
        foreach ($this->pairs($this->getOption('social'), 2) as [$label, $url]) {
            if ($this->safeUrl($url) !== '') {
                $social[] = ['label' => $label, 'url' => $this->safeUrl($url)];
            }
        }

        $ojs35 = $this->isOjs35();
        $journalName = $context ? (string) $context->getLocalizedName() : '';

        $templateMgr->assign('lumen', [
            'topbarTagline' => $this->textOr('topbarTagline', 'plugins.themes.lumen.default.topbarTagline'),
            'footerTagline' => $this->textOr('footerTagline', 'plugins.themes.lumen.default.topbarTagline'),
            'heroEyebrow' => $this->textOr('heroEyebrow', 'plugins.themes.lumen.default.heroEyebrow'),
            'heroSubtitle' => $this->textOr('heroSubtitle', 'plugins.themes.lumen.default.heroSubtitle'),
            'heroText' => $this->textOr('heroText', 'plugins.themes.lumen.default.heroText'),
            'highlights' => $highlights,
            'scope' => $this->lines($this->getOption('subjectScope')),
            'indexing' => $indexing,
            'social' => $social,
            'newsletterAction' => $this->safeUrl((string) $this->getOption('newsletterAction')),
            'news' => $this->homepageAnnouncements($templateMgr),
            'heroFallbackImage' => $request->getBaseUrl() . '/' . $this->getPluginPath() . '/images/hero-default.svg',
            // OJS 3.5 renamed the editorial team page to the editorial masthead
            'editorialOp' => $ojs35 ? 'editorialMasthead' : 'editorialTeam',
            'coreHighlights' => $ojs35,
            'monogram' => $journalName !== '' ? mb_strtoupper(mb_substr($journalName, 0, 1)) : '',
        ]);

        return false;
    }

    /**
     * Announcements for the homepage as plain arrays.
     * OJS 3.4 hands the template DataObjects (getId(), getLocalizedTitle() ...);
     * OJS 3.5 hands it Eloquent models (->id, getLocalizedData('title') ...),
     * so read whichever kind arrives here, and the template never touches them.
     */
    protected function homepageAnnouncements($templateMgr): array
    {
        $announcements = $templateMgr->getTemplateVars('announcements');
        $limit = min(3, (int) $templateMgr->getTemplateVars('numAnnouncementsHomepage'));
        if ($limit < 1 || !is_iterable($announcements)) {
            return [];
        }

        $news = [];
        foreach ($announcements as $announcement) {
            if (count($news) >= $limit) {
                break;
            }
            if ($announcement instanceof \Illuminate\Database\Eloquent\Model) {
                $id = $announcement->id;
                $title = $announcement->getLocalizedData('title');
                $text = $announcement->getLocalizedData('descriptionShort');
                $posted = $announcement->datePosted;
            } else {
                $id = $announcement->getId();
                $title = $announcement->getLocalizedTitle();
                $text = $announcement->getLocalizedDescriptionShort();
                $posted = $announcement->getDatePosted();
            }
            $time = $posted instanceof \DateTimeInterface ? $posted->getTimestamp() : ($posted ? strtotime((string) $posted) : 0);
            $news[] = [
                'id' => $id,
                'title' => (string) $title,
                'text' => (string) $text,
                'time' => $time ?: 0,
            ];
        }
        return $news;
    }

    /** Option value, or the translated default when the option is empty. */
    protected function textOr(string $option, string $defaultKey): string
    {
        $value = $this->getOption($option);
        $value = is_string($value) ? trim($value) : '';
        return $value !== '' ? $value : __($defaultKey);
    }

    /** True when the admin has saved something (even a blank) for an option. */
    protected function hasValue(string $option): bool
    {
        $value = $this->getOption($option);
        return is_string($value) && trim($value) !== '';
    }

    /** Non-empty trimmed lines of a textarea. */
    protected function lines($text): array
    {
        if (!is_string($text)) {
            return [];
        }
        $out = [];
        foreach (preg_split('/\R/u', $text) as $line) {
            $line = trim($line);
            if ($line !== '') {
                $out[] = $line;
            }
        }
        return $out;
    }

    /** Lines split on "|" into exactly $parts trimmed columns. */
    protected function pairs($text, int $parts): array
    {
        $out = [];
        foreach ($this->lines($text) as $line) {
            $cols = array_map('trim', explode('|', $line, $parts));
            $out[] = array_pad($cols, $parts, '');
        }
        return $out;
    }

    /** Only allow http(s), mailto and site-relative URLs. */
    protected function safeUrl(string $url): string
    {
        $url = trim($url);
        return preg_match('~^(https?://|mailto:|/(?!/))~i', $url) ? $url : '';
    }

    /** Validate a #rgb / #rrggbb colour. */
    protected function safeColour($value, string $fallback): string
    {
        return is_string($value) && preg_match('/^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/', $value) ? $value : $fallback;
    }

    /**
     * @copydoc ThemePlugin::saveOption()
     */
    public function saveOption($name, $value, $contextId = null)
    {
        if (in_array($name, ['primaryColor', 'accentColor'], true) && !preg_match('/^#(?:[0-9a-fA-F]{3}|[0-9a-fA-F]{6})$/', (string) $value)) {
            $value = null;
        }
        parent::saveOption($name, $value, $contextId);
    }

    /**
     * @copydoc Plugin::getContextSpecificPluginSettingsFile()
     */
    public function getContextSpecificPluginSettingsFile()
    {
        return $this->getPluginPath() . '/settings.xml';
    }

    /**
     * @copydoc Plugin::getInstallSitePluginSettingsFile()
     */
    public function getInstallSitePluginSettingsFile()
    {
        return $this->getPluginPath() . '/settings.xml';
    }

    public function getDisplayName()
    {
        return __('plugins.themes.lumen.name');
    }

    public function getDescription()
    {
        return __('plugins.themes.lumen.description');
    }
}

# Lumen: an OJS 3.4 theme

An editorial, card-based journal theme modelled on the layout of the Meridian demo
(top bar, brand row with ISSNs and a Submit button, hero banner, floating highlights
strip, current-issue showcase with article cards, About + Subject Scope, announcements,
indexing logos, newsletter / submit call-to-action, four-column footer).

It is a **child of the Default theme**: the header, footer and journal homepage are
replaced, and every other page (article, issue, archive, search, login, ...) still
works, re-coloured and re-typeset to match.

Works on OJS **3.4.x and 3.5.x** (checked against the 3.4.0 and 3.5.0 source) with the Default theme present (it always ships with OJS).
On 3.5 the journal *Highlights* carousel, if you have set one up, is shown above the hero, and the footer link points to the Editorial Masthead.

## Install

1. Upload `lumen.tar.gz` under **Settings > Website > Plugins > Upload A New Plugin**
   (or unpack the `lumen` folder into `plugins/themes/` on the server).
2. **Enable the plugin.** Go to **Settings > Website > Plugins > Installed Plugins**, filter the
   category to **Theme Plugins** (or search "Lumen"), and tick the checkbox next to **Lumen Theme**.
   OJS does not enable uploaded themes automatically, and the Theme dropdown lists enabled themes only.
3. Go to **Settings > Website > Appearance > Theme**, choose **Lumen Theme**, save.
4. Clear the template cache once: Administration > Clear Template Cache
   (and Clear Data Caches), or delete `cache/t_compile/*` and `cache/*.php`.

## Set up the navigation (Settings > Website > Appearance > Navigation Menus)

Create or edit menus and assign them to these theme areas:

| Area | Where it appears | Suggested items |
|---|---|---|
| Primary | Main menu under the logo | Current, Archives, About (submenu), Submissions, Announcements |
| User | Top-right of the top bar | Register, Login (OJS fills this automatically) |
| lumenTopbar | Small links in the top bar | Editorial Team, Contact |
| lumenFooterQuick | Footer "Quick Links" | Any custom links |
| lumenFooterPolicies | Footer "Policies" | Privacy, Author Guidelines, Ethics ... |

If the two footer areas are left unassigned, sensible default links are shown.

## Appearance options (Settings > Website > Appearance > Theme)

* **Primary colour / Accent colour**: the whole theme, including inner pages, follows these.
* **Typography**: Inter + Source Serif 4 from Google Fonts (untick to use system fonts,
  which avoids any request to Google).
* **Hero** text fields, **Highlights strip** (`Title | Description`, one per line),
  **Subject scope** (one per line), **Indexing** (`Name | Link | Logo URL`),
  **Newsletter form address**, **Footer tagline**, **Footer connect links** (`Label | URL`).

Also set, as usual in OJS:

* **Homepage image** (Appearance > Setup > Homepage Image): shown inside the hero frame.
  Without one, a built-in illustration is used.
* **Journal logo / ISSNs / Description / Announcements / Current issue cover**: all appear
  on the homepage automatically; sections hide themselves when there is nothing to show.
* Announcements show on the homepage when "Number of announcements on homepage" is above 0.

## Notes

* The newsletter box posts the field `EMAIL` to the address you give (Mailchimp's embedded-form
  action works as is). Leave the address empty to hide the box.
* Option text is stored as plain text and escaped on output; link and image URLs are limited to
  http(s), mailto and site-relative addresses.
* Translations: add `locale/<locale>/locale.po` copies of `locale/en/locale.po`.
* Licence: GNU GPL v3, like OJS.

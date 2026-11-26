/**
 * Lumen theme: navigation behaviour.
 *  - mobile menu toggle
 *  - a small caret button next to every menu item that has a submenu, so
 *    touch and keyboard users can open it without following the parent link
 *  - Escape and outside-click close open submenus
 */
(function () {
	'use strict';

	var nav = document.querySelector('.lm_nav');
	var toggle = document.querySelector('.lm_nav_toggle');

	if (nav && toggle) {
		toggle.addEventListener('click', function () {
			var open = nav.classList.toggle('lm_nav--open');
			toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
		});
	}

	var label = (nav && nav.getAttribute('data-submenu-label')) || 'Show submenu';
	var items = document.querySelectorAll('.lm_menu > li, .lm_user_menu > li');

	Array.prototype.forEach.call(items, function (li) {
		var sub = null;
		for (var i = 0; i < li.children.length; i++) {
			if (li.children[i].tagName === 'UL') { sub = li.children[i]; break; }
		}
		if (!sub) { return; }

		li.classList.add('lm_has_sub');

		var btn = document.createElement('button');
		btn.type = 'button';
		btn.className = 'lm_sub_toggle';
		btn.setAttribute('aria-expanded', 'false');
		btn.setAttribute('aria-label', label);
		li.insertBefore(btn, sub);

		btn.addEventListener('click', function (event) {
			event.stopPropagation();
			var open = !li.classList.contains('lm_sub_open');
			closeAll(li);
			li.classList.remove('lm_sub_closed');
			li.classList.toggle('lm_sub_open', open);
			btn.setAttribute('aria-expanded', open ? 'true' : 'false');
		});

		// Escape sets lm_sub_closed, which beats :hover / :focus-within in the
		// stylesheet. It is cleared as soon as the pointer or focus moves away.
		// Each handler clears it only when the *other* trigger is gone too,
		// otherwise :hover or :focus-within would reopen the menu immediately.
		li.addEventListener('mouseleave', function () {
			if (!li.contains(document.activeElement)) { li.classList.remove('lm_sub_closed'); }
		});
		li.addEventListener('focusout', function (event) {
			var leaving = !event.relatedTarget || !li.contains(event.relatedTarget);
			if (leaving && !li.matches(':hover')) { li.classList.remove('lm_sub_closed'); }
		});
	});

	function closeAll(except) {
		Array.prototype.forEach.call(document.querySelectorAll('.lm_sub_open'), function (li) {
			if (li === except) { return; }
			li.classList.remove('lm_sub_open');
			var b = li.querySelector('.lm_sub_toggle');
			if (b) { b.setAttribute('aria-expanded', 'false'); }
		});
	}

	document.addEventListener('click', function (event) {
		if (!event.target.closest || !event.target.closest('.lm_has_sub')) { closeAll(); }
	});

	document.addEventListener('keydown', function (event) {
		if (event.key !== 'Escape') { return; }

		// If focus is inside a submenu, close it and hand focus back to its caret.
		var active = document.activeElement;
		var holder = active && active.closest ? active.closest('.lm_has_sub') : null;

		closeAll();

		if (holder) {
			holder.classList.add('lm_sub_closed');
			var b = holder.querySelector('.lm_sub_toggle');
			if (b) { b.focus(); }
		}
	});
})();

/**
 * Lumen theme: archive page tools.
 * Adds a "browse by year" filter and a quick search over the issues that are
 * already on the page. Without JavaScript the full list is simply shown.
 */
(function () {
	'use strict';

	var tools = document.querySelector('.lm_archive_tools');
	var sections = Array.prototype.slice.call(document.querySelectorAll('.lm_year'));
	if (!tools || !sections.length) { return; }

	var state = { year: '', query: '' };

	var years = [];
	sections.forEach(function (s) {
		var y = s.getAttribute('data-year');
		if (y && years.indexOf(y) === -1) { years.push(y); }
	});

	function el(tag, cls, text) {
		var e = document.createElement(tag);
		if (cls) { e.className = cls; }
		if (text) { e.textContent = text; }
		return e;
	}

	// ---- build the controls
	var group = el('div', 'lm_archive_years_filter');
	group.appendChild(el('span', 'lm_archive_filter_label', tools.getAttribute('data-label-year')));

	var buttons = [];
	['' ].concat(years).forEach(function (y) {
		var b = el('button', 'lm_chip', y === '' ? tools.getAttribute('data-label-all') : y);
		b.type = 'button';
		b.setAttribute('data-year', y);
		b.setAttribute('aria-pressed', y === '' ? 'true' : 'false');
		b.addEventListener('click', function () { state.year = y; apply(); });
		group.appendChild(b);
		buttons.push(b);
	});

	var searchWrap = el('label', 'lm_archive_search');
	var input = el('input');
	input.type = 'search';
	input.placeholder = tools.getAttribute('data-label-search');
	input.setAttribute('aria-label', tools.getAttribute('data-label-search'));
	input.addEventListener('input', function () { state.query = input.value.trim().toLowerCase(); apply(); });
	searchWrap.appendChild(input);

	tools.appendChild(group);
	tools.appendChild(searchWrap);
	tools.hidden = false;

	var none = el('p', 'lm_empty lm_archive_none', tools.getAttribute('data-label-none'));
	none.hidden = true;
	sections[sections.length - 1].parentNode.appendChild(none);

	// ---- filter
	function apply() {
		var shown = 0;

		buttons.forEach(function (b) {
			b.setAttribute('aria-pressed', b.getAttribute('data-year') === state.year ? 'true' : 'false');
		});

		sections.forEach(function (section) {
			var yearOk = !state.year || section.getAttribute('data-year') === state.year;
			var visible = 0;
			Array.prototype.forEach.call(section.querySelectorAll('.lm_issue_item'), function (item) {
				var ok = yearOk && (!state.query || item.textContent.toLowerCase().indexOf(state.query) !== -1);
				item.hidden = !ok;
				if (ok) { visible++; }
			});
			section.hidden = visible === 0;
			shown += visible;
		});

		none.hidden = shown !== 0;
	}
})();

/**
 * Lumen theme: collapse an empty sidebar.
 * OJS reserves a sidebar column whenever blocks are configured, even when none of
 * them has anything to show. Without this the article and archive pages would keep
 * a blank strip on the right.
 */
(function () {
	'use strict';

	var content = document.querySelector('.pkp_structure_content.has_sidebar');
	var side = content && content.querySelector(':scope > .pkp_structure_sidebar');
	if (!content) { return; }

	var empty = !side ||
		(side.textContent.replace(/\s+/g, '') === '' && !side.querySelector('img, iframe, input, select, textarea, video, canvas, svg'));
	if (empty) {
		content.classList.add('lm_no_sidebar');
	}
})();

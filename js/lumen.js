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

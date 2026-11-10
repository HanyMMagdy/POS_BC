/*
 * Shared colour-theme helper used by the register and by the theme editor.
 * A theme is { accent, accentText, background, panel, text, muted, border, danger } as #RRGGBB.
 * Applying a theme only sets CSS variables, so every colour in pos.css follows.
 */
window.POSTheme = (function () {
  'use strict';

  var DEFAULT = {
    accent: '#0B6B63', accentText: '#FFFFFF', background: '#EEF0F2', panel: '#FFFFFF',
    text: '#1A1F26', muted: '#667085', border: '#E3E6EA', danger: '#B42318'
  };

  var VARS = {
    accent: '--accent', accentText: '--accent-ink', background: '--bg', panel: '--surface',
    text: '--ink', muted: '--muted', border: '--line', danger: '--danger'
  };

  var KEYS = Object.keys(VARS);

  function normalize(hex) {
    if (typeof hex !== 'string') { return null; }
    var h = hex.trim().replace(/^#/, '').toUpperCase();
    if (/^[0-9A-F]{3}$/.test(h)) { h = h.charAt(0) + h.charAt(0) + h.charAt(1) + h.charAt(1) + h.charAt(2) + h.charAt(2); }
    return /^[0-9A-F]{6}$/.test(h) ? '#' + h : null;
  }

  // Missing or invalid colours fall back to the default so the screen can never become unreadable.
  function resolve(theme) {
    var out = {};
    KEYS.forEach(function (k) { out[k] = (theme && normalize(theme[k])) || DEFAULT[k]; });
    out.code = theme && theme.code;
    out.name = theme && theme.name;
    return out;
  }

  function luminance(hex) {
    var h = normalize(hex) || '#000000';
    var c = [1, 3, 5].map(function (i) {
      var v = parseInt(h.substr(i, 2), 16) / 255;
      return v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
    });
    return 0.2126 * c[0] + 0.7152 * c[1] + 0.0722 * c[2];
  }

  function contrast(a, b) {
    var la = luminance(a), lb = luminance(b);
    return (Math.max(la, lb) + 0.05) / (Math.min(la, lb) + 0.05);
  }

  function apply(el, theme) {
    var t = resolve(theme);
    KEYS.forEach(function (k) { el.style.setProperty(VARS[k], t[k]); });
    el.setAttribute('data-mode', luminance(t.background) < 0.2 ? 'dark' : 'light');
    return t;
  }

  return { DEFAULT: DEFAULT, KEYS: KEYS, normalize: normalize, resolve: resolve, apply: apply, luminance: luminance, contrast: contrast };
})();

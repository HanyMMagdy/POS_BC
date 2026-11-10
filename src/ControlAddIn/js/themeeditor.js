/*
 * Theme editor for the "POS Theme Editor" add-in.
 * Left: one colour picker per theme colour. Right: a miniature register drawn with the real pos.css,
 * so what you see is what the cashier gets, plus a contrast check for the pairs that matter.
 * 'input' updates the preview while dragging; 'change' (picker closed) reports the value to AL.
 */
(function () {
  'use strict';

  var FIELDS = [
    ['accent', 'Accent', 'Main buttons and highlights'],
    ['accentText', 'Text on accent', 'Writing on top of accent buttons'],
    ['background', 'Screen background', 'Behind the panels'],
    ['panel', 'Panels and cards', 'Tiles, receipt panel, dialogs'],
    ['text', 'Main text', 'Names, amounts, headings'],
    ['muted', 'Secondary text', 'Hints, prices per unit, stock'],
    ['border', 'Borders', 'Lines between rows'],
    ['danger', 'Warnings and delete', 'Discounts, errors, cancel']
  ];

  // [foreground, background, minimum ratio, label]
  var CHECKS = [
    ['accentText', 'accent', 4.5, 'Text on accent buttons'],
    ['text', 'panel', 4.5, 'Main text on panels'],
    ['text', 'background', 4.5, 'Main text on the screen background'],
    ['muted', 'panel', 3, 'Secondary text on panels'],
    ['danger', 'panel', 3, 'Warnings on panels']
  ];

  var root, preview, theme = POSTheme.resolve(null);

  function invoke(name, args) {
    try { Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(name, args); } catch (e) { /* page closed */ }
  }

  function start() {
    root = document.getElementById('controlAddIn');
    root.innerHTML =
      '<div class="te">' +
        '<div class="te-pickers">' + FIELDS.map(function (f) {
          return '<label class="te-row"><input type="color" data-k="' + f[0] + '">' +
            '<span class="te-txt"><b>' + f[1] + '</b><small>' + f[2] + '</small></span><code data-code="' + f[0] + '"></code></label>';
        }).join('') + '</div>' +
        '<div class="te-side"><div class="te-preview pos" id="te-preview">' + previewMarkup() + '</div>' +
        '<div class="te-checks" id="te-checks"></div></div>' +
      '</div>';
    preview = document.getElementById('te-preview');

    root.addEventListener('input', function (e) {
      var k = e.target.getAttribute && e.target.getAttribute('data-k');
      if (!k) { return; }
      theme[k] = e.target.value.toUpperCase();
      refresh(false);
    });
    root.addEventListener('change', function (e) {
      var k = e.target.getAttribute && e.target.getAttribute('data-k');
      if (!k) { return; }
      theme[k] = e.target.value.toUpperCase();
      invoke('ColorChanged', [k, theme[k]]);
    });

    refresh(true);
    invoke('ControlReady', []);
  }

  function setTheme(json) {
    try { theme = POSTheme.resolve(JSON.parse(json)); } catch (e) { return; }
    refresh(true);
  }

  function refresh(updatePickers) {
    POSTheme.apply(preview, theme);
    POSTheme.KEYS.forEach(function (k) {
      var code = root.querySelector('[data-code="' + k + '"]');
      if (code) { code.textContent = theme[k]; }
      if (updatePickers) {
        var input = root.querySelector('[data-k="' + k + '"]');
        if (input) { input.value = theme[k].toLowerCase(); }
      }
    });
    renderChecks();
  }

  function renderChecks() {
    var html = CHECKS.map(function (c) {
      var ratio = POSTheme.contrast(theme[c[0]], theme[c[1]]);
      var ok = ratio >= c[2];
      return '<div class="te-check ' + (ok ? 'ok' : 'bad') + '"><span class="dot"></span><span>' + c[3] +
        '</span><b>' + ratio.toFixed(1) + ' : 1</b>' + (ok ? '' : '<em>hard to read</em>') + '</div>';
    }).join('');
    document.getElementById('te-checks').innerHTML = '<h4>Readability</h4>' + html;
  }

  function previewMarkup() {
    return '' +
      '<header class="topbar"><div class="brand"><span class="logo"></span>Your store</div>' +
        '<div class="who">CASHIER - Receipt R00042</div>' +
        '<div class="top-actions"><button class="btn ghost">Held <span class="badge">2</span></button>' +
        '<button class="btn ghost danger">Cancel sale</button></div></header>' +
      '<main class="layout">' +
        '<section class="catalog">' +
          '<div class="searchbar"><input type="text" placeholder="Scan a barcode or search items" disabled></div>' +
          '<div class="chips"><button class="chip on">All</button><button class="chip">Drinks</button><button class="chip">Snacks</button></div>' +
          '<div class="grid">' +
            tile('Espresso', '2.50', '40 in stock', 24, '') +
            tile('Croissant', '3.20', '3 left', 38, ' low') +
            tile('Orange juice', '4.10', 'Out of stock', 28, ' out') +
          '</div>' +
        '</section>' +
        '<aside class="ticket">' +
          '<div class="customer"><span class="c-label">Customer</span><span class="c-name">Walk-in</span><span class="c-go">Change</span></div>' +
          '<div class="lines">' +
            line('Espresso', '2.50 / PCS', '2', '5.00', '') +
            line('Croissant', '3.20 / PCS', '1', '2.88', '<span class="disc">-10%</span>') +
          '</div>' +
          '<div class="totals"><div class="t-row"><span>Subtotal</span><span>7.88</span></div>' +
            '<div class="t-row"><span>VAT</span><span>1.10</span></div>' +
            '<div class="t-row grand"><span>Total</span><span>8.98</span></div></div>' +
          '<div class="ticket-actions"><button class="btn">Hold</button><button class="btn primary pay">Pay 8.98</button></div>' +
        '</aside>' +
      '</main>';
  }

  function tile(name, price, stock, hue, cls) {
    return '<button class="tile' + cls + '" style="--h:' + hue + '"><span class="ini">' + name.substr(0, 2).toUpperCase() +
      '</span><span class="name">' + name + '</span><span class="meta"><b>' + price + '</b><span class="stock">' + stock + '</span></span></button>';
  }

  function line(name, sub, qty, amt, extra) {
    return '<div class="line"><div class="l-main"><div class="l-desc">' + name + '</div><div class="l-sub">' + sub + ' ' + extra + '</div></div>' +
      '<div class="l-qty"><button class="sq">-</button><button class="q">' + qty + '</button><button class="sq">+</button></div>' +
      '<div class="l-amt">' + amt + '</div><div class="l-tools"></div></div>';
  }

  window.POSThemeEditor = { start: start };
  window.SetTheme = setTheme;
})();

(function () {
  'use strict';

  var outside = false;
  var saved = [];          // [{ el, css }] original inline styles, restored on exit
  var root = document.getElementById('controlAddIn');

  function frame() {
    try { return window.frameElement; } catch (e) { return null; }  // null when cross-origin
  }

  function tell(method, args) {
    Microsoft.Dynamics.NAV.InvokeExtensibilityMethod(method, args || []);
  }

  function force(el, props) {
    saved.push({ el: el, css: el.style.cssText });
    Object.keys(props).forEach(function (k) { el.style.setProperty(k, props[k], 'important'); });
  }

  // Anything that creates a containing block or a stacking context traps a fixed-position child, so those are neutralised on every ancestor.
  function freeAncestors(f) {
    var doc = f.ownerDocument, win = doc.defaultView;
    for (var el = f.parentElement; el && el !== doc.documentElement; el = el.parentElement) {
      var cs = win.getComputedStyle(el), p = {};
      if (cs.transform !== 'none') { p.transform = 'none'; }
      if (cs.filter !== 'none') { p.filter = 'none'; }
      if (cs.perspective !== 'none') { p.perspective = 'none'; }
      if (cs.contain !== 'none') { p.contain = 'none'; }
      if (cs.willChange !== 'auto') { p['will-change'] = 'auto'; }
      if (cs.overflow !== 'visible') { p.overflow = 'visible'; }
      if (cs.position !== 'static') { p['z-index'] = '2147483000'; }
      if (Object.keys(p).length) { force(el, p); }
    }
  }

  function enter() {
    var f = frame();
    if (!f) { tell('OutsideChanged', [false]); return; }   // cannot reach the page: stay inside
    if (outside) { return; }
    freeAncestors(f);
    force(f, {
      position: 'fixed', top: '0', left: '0', right: '0', bottom: '0',
      width: '100vw', height: '100vh', 'max-width': 'none', 'max-height': 'none',
      margin: '0', border: '0', 'z-index': '2147483001', background: '#fff'
    });
    outside = true;
    document.documentElement.classList.add('outside');
    try { f.ownerDocument.addEventListener('keydown', onKey, true); } catch (e) { /* ignore */ }
    tell('OutsideChanged', [true]);
  }

  function exit() {
    if (!outside) { return; }
    var f = frame();
    for (var i = saved.length - 1; i >= 0; i--) { saved[i].el.style.cssText = saved[i].css; }
    saved = [];
    outside = false;
    document.documentElement.classList.remove('outside');
    try { f.ownerDocument.removeEventListener('keydown', onKey, true); } catch (e) { /* ignore */ }
    tell('OutsideChanged', [false]);
  }

  function onKey(e) { if (e.key === 'Escape') { exit(); } }
  document.addEventListener('keydown', onKey, true);       // Esc while the focus is inside the add-in

  // Called from AL
  window.EnterOutside = enter;
  window.ExitOutside = exit;

  // ---- demo content: replace with your own UI -------------------------------------------
  root.innerHTML =
    '<div style="font:14px Segoe UI,Arial,sans-serif;padding:16px">' +
    '<h2 style="margin:0 0 8px">My control add-in</h2>' +
    '<p>This area becomes the whole window when you press the button. Esc brings it back.</p>' +
    '<button id="ov-toggle" style="padding:8px 14px;font-size:14px">Full screen</button></div>';
  document.getElementById('ov-toggle').addEventListener('click', function () { outside ? exit() : enter(); });
  root.style.height = '100%';

  tell('ControlReady');
})();
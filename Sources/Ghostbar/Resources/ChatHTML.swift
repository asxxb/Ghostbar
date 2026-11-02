import Foundation

func jsonString(_ arr: [String]) -> String {
    (try? String(data: JSONSerialization.data(withJSONObject: arr), encoding: .utf8)) ?? "[]"
}

func chatHTML() -> String { return """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<style>
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@300;400;500&display=swap');
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
:root{
  --bg:rgba(28,30,36,0.55);--surface:rgba(41,44,51,0.7);--border:rgba(255,255,255,0.08);
  --text:#d1d1d6;--muted:#6b6b7a;--accent:#4ade80;
  --user:#7dd3fc;--error:#f87171;--rec:#f87171;
  --font:'JetBrains Mono','Menlo',monospace;
}
html,body{height:100%;background:transparent;color:var(--text);
  font-family:var(--font);font-size:12.5px;line-height:1.6;
  overflow:hidden;-webkit-font-smoothing:antialiased}
#app{background:var(--bg);border-radius:12px;display:flex;flex-direction:column;height:100vh;overflow:hidden}
#header{display:flex;align-items:center;justify-content:space-between;
  padding:9px 14px;border-bottom:1px solid var(--border);
  background:var(--surface);-webkit-app-region:drag;
  user-select:none;-webkit-user-select:none;cursor:default;flex-shrink:0}
#header *{user-select:none;-webkit-user-select:none}
#dot{width:6px;height:6px;border-radius:50%;background:var(--accent);
  box-shadow:0 0 5px var(--accent);animation:pulse 2.5s ease-in-out infinite;
  pointer-events:none}
@keyframes pulse{0%,100%{opacity:1}50%{opacity:.35}}
#header-left{display:flex;align-items:center;gap:8px}
#backend-badge{font-size:9px;letter-spacing:.06em;text-transform:uppercase;
  color:var(--muted);padding:1px 5px;border:1px solid var(--border);border-radius:3px;
  pointer-events:none}
#autoscroll-btn{-webkit-appearance:none;appearance:none;background:none;
  border:1px solid var(--border);color:var(--muted);
  font-family:var(--font);font-size:12px;padding:1px 6px;border-radius:3px;
  cursor:pointer;transition:all .15s;line-height:1.4}
#autoscroll-btn.on{border-color:var(--accent);color:var(--accent)}
#autoscroll-btn:hover{border-color:var(--text);color:var(--text)}
#model-wrap{position:relative;display:flex;align-items:center;gap:6px}
#model-btn{background:transparent;border:none;color:var(--muted);
  font-family:var(--font);font-size:11.5px;cursor:pointer;outline:none;
  -webkit-app-region:no-drag;padding:2px 6px;border-radius:3px;
  display:flex;align-items:center;gap:5px;transition:color .15s}
#model-btn:hover{color:var(--text)}
#model-name{color:var(--text)}
#model-dropdown{display:none;position:fixed;top:44px;left:14px;
  background:var(--surface);border:1px solid var(--border);border-radius:6px;
  min-width:220px;z-index:999;overflow-y:auto;max-height:calc(100vh - 60px);
  box-shadow:0 8px 24px rgba(0,0,0,.15)}
#model-dropdown.open{display:block}
.model-opt{padding:8px 14px;font-size:11.5px;cursor:pointer;color:var(--text);
  font-family:var(--font);transition:background .1s;white-space:nowrap}
.model-opt:hover, .model-opt.highlighted{background:var(--border)}
.model-opt.active{color:var(--accent)}
.model-opt.highlighted{outline:1px solid var(--accent);outline-offset:-1px}
#msgs{flex:1;overflow-y:auto;padding:14px;scroll-behavior:smooth}
#msgs::-webkit-scrollbar{width:3px}
#msgs::-webkit-scrollbar-thumb{background:var(--border);border-radius:2px}
.msg{position:relative;margin-bottom:16px;animation:fadein .15s ease;background:var(--surface);padding:12px;border-radius:8px;border:1px solid var(--border);transition:all 0.3s;}
.msg.user{background:transparent;border-color:transparent;padding:4px 0px;}
@keyframes fadein{from{opacity:0;transform:translateY(3px)}to{opacity:1;transform:none}}
.lbl{font-size:10px;letter-spacing:.07em;text-transform:uppercase;margin-bottom:3px;color:var(--muted)}
.msg.user .lbl{color:var(--user)}
.msg.ai .lbl{color:var(--accent)}
.msg.err .lbl{color:var(--error)}
.body{white-space:pre-wrap;word-break:break-word}
.body.rendered{white-space:normal}
.body.rendered h1{font-size:1.15em;font-weight:600;margin:10px 0 4px;color:#e5e5ea}
.body.rendered h2{font-size:1.05em;font-weight:600;margin:8px 0 3px;color:#e5e5ea}
.body.rendered h3{font-size:1em;font-weight:600;margin:6px 0 3px;color:#e5e5ea}
.body.rendered pre{background:rgba(0,0,0,.35);border-radius:6px;padding:10px 12px;
  overflow-x:auto;margin:8px 0;white-space:pre;border:1px solid var(--border);position:relative}
.code-copy-btn{position:absolute;top:6px;right:6px;background:rgba(0,0,0,.5);
  border:1px solid var(--border);color:var(--muted);
  padding:3px 5px;border-radius:3px;line-height:0;
  cursor:pointer;opacity:0;transition:opacity .15s,color .1s,border-color .1s}
.body.rendered pre:hover .code-copy-btn{opacity:1}
.code-copy-btn:hover{color:var(--accent);border-color:var(--accent)}
.body.rendered code{background:rgba(0,0,0,.3);border-radius:3px;padding:1px 5px;font-size:.92em}
.body.rendered pre code{background:none;padding:0;font-size:.9em}
.body.rendered ul,.body.rendered ol{padding-left:18px;margin:4px 0}
.body.rendered li{margin:2px 0}
.body.rendered strong{color:#e5e5ea;font-weight:600}
.body.rendered em{font-style:italic;color:#c8c8d0}
.body.rendered hr{border:none;border-top:1px solid var(--border);margin:10px 0}
.body.rendered del{text-decoration:line-through;color:var(--muted)}
.body.rendered a{color:var(--accent);text-decoration:none}
.body.rendered a:hover{text-decoration:underline}
.msg.user .body{color:var(--user)}
.msg.err .body{color:var(--error)}
.cursor::after{content:'▋';color:var(--accent);animation:blink .65s step-end infinite;margin-left:1px}
@keyframes blink{0%,100%{opacity:1}50%{opacity:0}}
.copy-btn{position:absolute;top:8px;right:8px;background:none;
  border:1px solid var(--border);color:var(--muted);
  padding:3px 5px;border-radius:3px;line-height:0;
  cursor:pointer;opacity:0;transition:opacity .15s, color .1s, border-color .1s}
.msg:hover .copy-btn{opacity:1}
.copy-btn:hover{color:var(--accent);border-color:var(--accent)}
.retry-btn{display:inline-block;margin-top:8px;background:none;
  border:1px solid var(--error);color:var(--error);
  font-family:var(--font);font-size:11px;padding:3px 10px;border-radius:3px;
  cursor:pointer;transition:all .15s}
.retry-btn:hover{background:var(--error);color:#1a1a1a}
#bottom{border-top:1px solid var(--border);background:var(--surface);
  padding:9px 14px;display:flex;align-items:flex-end;gap:6px;flex-shrink:0}
#inp{flex:1;background:transparent;border:none;color:var(--text);
  font-family:var(--font);font-size:12.5px;outline:none;resize:none;
  line-height:1.5;max-height:72px;overflow-y:auto;caret-color:var(--accent)}
#inp::placeholder{color:var(--muted)}
.action-btn{background:none;border:1px solid var(--border);color:var(--muted);
  font-family:var(--font);font-size:13px;padding:3px 8px;border-radius:4px;
  cursor:pointer;transition:all .15s;flex-shrink:0;margin-bottom:1px;line-height:1}
.action-btn:hover{border-color:var(--accent);color:var(--accent)}
#mic-btn{font-size:14px;padding:3px 7px}
#mic-btn.recording{border-color:var(--rec);color:var(--rec);animation:recpulse 1s ease-in-out infinite}
#mic-btn.transcribing{border-color:var(--muted);color:var(--muted);cursor:default}
@keyframes recpulse{0%,100%{box-shadow:0 0 0 0 rgba(248,113,113,.4)}50%{box-shadow:0 0 0 4px rgba(248,113,113,0)}}
#btn.stopping{border-color:var(--error);color:var(--error)}
#screenshot-btn{padding:5px 8px;line-height:0;font-size:13px}
#screenshot-btn.captured{border-color:var(--accent);color:var(--accent)}
#screenshot-indicator{display:none;font-size:10px;color:var(--accent);padding:3px 14px 0;
  letter-spacing:.03em;cursor:pointer}
#screenshot-indicator:hover{color:var(--error)}
#hint{font-size:10px;color:var(--muted);padding:4px 14px 0;display:none;letter-spacing:.03em}
#hint.visible{display:block}
#close-btn{-webkit-appearance:none;appearance:none;background:none;border:none;
  color:var(--muted);font-size:16px;line-height:1;
  cursor:pointer;padding:0 4px;transition:color .15s;-webkit-app-region:no-drag}
#close-btn:hover{color:var(--error)}
#settings-btn{-webkit-appearance:none;appearance:none;background:none;border:none;
  color:var(--muted);line-height:0;padding:0 4px;cursor:pointer;
  transition:color .15s,transform .3s;-webkit-app-region:no-drag}
#settings-btn:hover{color:var(--text);transform:rotate(45deg)}

#phone-btn{-webkit-appearance:none;appearance:none;background:none;
  border:1px solid var(--border);color:var(--muted);
  font-family:var(--font);font-size:12px;padding:1px 5px;border-radius:3px;
  cursor:pointer;transition:all .15s;line-height:1.4}
#phone-btn:hover{border-color:var(--text);color:var(--text)}
#phone-btn.active{border-color:var(--accent);color:var(--accent)}

#phone-modal{display:none;position:fixed;top:0;left:0;right:0;bottom:0;
  background:rgba(18,20,24,0.75);backdrop-filter:blur(6px);-webkit-backdrop-filter:blur(6px);
  z-index:1000;align-items:center;justify-content:center}
#phone-modal.open{display:flex}
#phone-card{background:var(--surface);border:1px solid var(--border);border-radius:10px;
  padding:16px;width:280px;box-shadow:0 12px 32px rgba(0,0,0,.5);
  display:flex;flex-direction:column;align-items:center;text-align:center;gap:10px}
#phone-card-header{width:100%;display:flex;align-items:center;justify-content:space-between;
  color:var(--text);border-bottom:1px solid var(--border);padding-bottom:8px}
#phone-close-btn{background:none;border:none;color:var(--muted);font-size:16px;cursor:pointer;line-height:1}
#phone-close-btn:hover{color:var(--error)}
#qr-wrap{background:#ffffff;padding:8px;border-radius:8px;display:flex;align-items:center;justify-content:center}
#qr-img{width:150px;height:150px;image-rendering:pixelated;display:block}
#phone-url-box{display:flex;align-items:center;gap:6px;background:rgba(0,0,0,0.3);
  border:1px solid var(--border);border-radius:5px;padding:4px 8px;width:100%}
#phone-url-text{flex:1;font-size:11px;color:var(--accent);font-family:var(--font);
  overflow:hidden;text-overflow:ellipsis;white-space:nowrap;user-select:all}
#phone-copy-btn{background:none;border:none;color:var(--muted);cursor:pointer;font-size:12px;padding:2px 4px}
#phone-copy-btn:hover{color:var(--text)}
#phone-card-hint{font-size:10px;color:var(--muted);line-height:1.4}
</style>
</head>
<body>
<div id="app">
  <div id="header">
    <div id="header-left">
      <div id="dot"></div>
      <div id="model-wrap">
        <button id="model-btn">
          <span id="model-name">loading…</span>
          <span style="color:var(--muted);font-size:9px">▾</span>
        </button>
        <div id="model-dropdown"></div>
      </div>
      <span id="backend-badge">ollama</span>
    </div>
    <div style="display:flex;align-items:center;gap:4px;-webkit-app-region:no-drag">
      <button id="phone-btn" title="Phone Remote Keyboard (⌘P)">📱</button>
      <button id="autoscroll-btn" title="Auto-scroll">↓</button>
      <button id="settings-btn" title="Settings"><svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg></button>
      <button id="close-btn" title="Close">×</button>
    </div>
  </div>
  <div id="phone-modal">
    <div id="phone-card">
      <div id="phone-card-header">
        <div style="display:flex;align-items:center;gap:6px">
          <span style="font-size:14px">📱</span>
          <span style="font-weight:600;font-size:11.5px">Phone Remote Keyboard</span>
        </div>
        <button id="phone-close-btn" title="Close">×</button>
      </div>
      <div id="qr-wrap">
        <img id="qr-img" src="" alt="Scan QR code" />
      </div>
      <div id="phone-url-box">
        <span id="phone-url-text">Loading…</span>
        <button id="phone-copy-btn" title="Copy URL">📋</button>
      </div>
      <div id="phone-card-hint">
        Scan with your phone's camera (iPhone or Android) to type directly into Ghostbar.
      </div>
    </div>
  </div>
  <div id="msgs"></div>
  <div id="hint"></div>
  <div id="screenshot-indicator" title="Screenshot attached — click to remove">📎 screenshot attached</div>
  <div id="bottom">
    <textarea id="inp" placeholder="Message… (Enter to send)" rows="1"></textarea>
    <button id="screenshot-btn" class="action-btn" title="Capture screen"><svg width="16" height="14" viewBox="0 0 16 14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="square"><path d="M1 4V1h4M11 1h4v3M15 10v3h-4M5 13H1v-3"/></svg></button>
    <button id="mic-btn" class="action-btn" title="Record">🎙</button>
    <button id="btn" class="action-btn">↵</button>
  </div>
</div>
<script>
let model = '', busy = false, currentBody = null;
let screenshotPrompt = null;
function setScreenshotPrompt(p) { screenshotPrompt = p; }
let micState = 'idle', streaming = false;
let autoScroll = true;
let hasScreenshot = false;
let messages = [];
const CTX_WINDOW = 20;
let lastUserText = '';
let lastScreenshot = null;
let _messagesLenBeforeLastUser = 0;
let streamStartTime = 0, tokenCount = 0;

function setSavedModel(m) { window.savedModel = m; }

window.webkit.messageHandlers.loadModels.postMessage({});
window.webkit.messageHandlers.checkWhisper.postMessage({});
window.webkit.messageHandlers.initModel.postMessage({});

// ── Markdown ──────────────────────────────────────────────────────────────────
function inlineMd(text) {
  let s = text.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  s = s.replace(/`([^`]+)`/g, '<code>$1</code>');
  s = s.replace(/\\*\\*\\*(.+?)\\*\\*\\*/g, '<strong><em>$1</em></strong>');
  s = s.replace(/\\*\\*(.+?)\\*\\*/g, '<strong>$1</strong>');
  s = s.replace(/\\*([^\\s*][^*]*)\\*/g, '<em>$1</em>');
  s = s.replace(/~~(.+?)~~/g, '<del>$1</del>');
  return s;
}

function renderMarkdown(src) {
  const parts = src.split(/(```[\\s\\S]*?```)/);
  let out = '';
  for (let pi = 0; pi < parts.length; pi++) {
    const part = parts[pi];
    if (part.startsWith('```')) {
      const m = part.match(/```(\\w*)\\n?([\\s\\S]*?)```/);
      if (m) {
        const code = m[2].replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
        out += '<pre><code>' + code + '</code></pre>';
      } else {
        out += part.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
      }
      continue;
    }
    const lines = part.split('\\n');
    let i = 0;
    while (i < lines.length) {
      const line = lines[i];
      const hm = line.match(/^(#{1,3})\\s+(.+)$/);
      if (hm) { out += '<h' + hm[1].length + '>' + inlineMd(hm[2]) + '</h' + hm[1].length + '>'; i++; continue; }
      if (/^[-*]{3,}$/.test(line.trim())) { out += '<hr>'; i++; continue; }
      if (/^[\\s]*[-*+]\\s/.test(line)) {
        out += '<ul>';
        while (i < lines.length && /^[\\s]*[-*+]\\s/.test(lines[i])) {
          out += '<li>' + inlineMd(lines[i].replace(/^[\\s]*[-*+]\\s+/, '')) + '</li>';
          i++;
        }
        out += '</ul>';
        continue;
      }
      if (/^[\\s]*\\d+\\.\\s/.test(line)) {
        out += '<ol>';
        while (i < lines.length && /^[\\s]*\\d+\\.\\s/.test(lines[i])) {
          out += '<li>' + inlineMd(lines[i].replace(/^[\\s]*\\d+\\.\\s+/, '')) + '</li>';
          i++;
        }
        out += '</ol>';
        continue;
      }
      if (!line.trim()) { out += '<br>'; i++; continue; }
      out += inlineMd(line) + '<br>';
      i++;
    }
  }
  return out;
}

// ── Copy icon SVGs ────────────────────────────────────────────────────────────
const COPY_ICON = '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>';
const CHECK_ICON = '<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>';

// ── Code copy buttons ─────────────────────────────────────────────────────────
function addCodeCopyButtons(container) {
  container.querySelectorAll('pre').forEach(pre => {
    if (pre.querySelector('.code-copy-btn')) return;
    const cb = document.createElement('button');
    cb.className = 'code-copy-btn';
    cb.innerHTML = COPY_ICON;
    cb.addEventListener('click', e => {
      e.stopPropagation();
      const code = pre.querySelector('code');
      const text = (code ? code.textContent : pre.textContent);
      navigator.clipboard.writeText(text).then(() => {
        cb.innerHTML = CHECK_ICON;
        cb.style.color = 'var(--accent)';
        setTimeout(() => { cb.innerHTML = COPY_ICON; cb.style.color = ''; }, 1500);
      });
    });
    pre.appendChild(cb);
  });
}

// ── Model dropdown ────────────────────────────────────────────────────────────
const modelBtn      = document.getElementById('model-btn');
const modelName     = document.getElementById('model-name');
const modelDropdown = document.getElementById('model-dropdown');
const backendBadge  = document.getElementById('backend-badge');

let highlightedModelIndex = -1;

function openModelDropdown() {
  modelDropdown.classList.add('open');
  const opts = modelDropdown.querySelectorAll('.model-opt');
  highlightedModelIndex = Array.from(opts).findIndex(el => el.classList.contains('active'));
  if (highlightedModelIndex === -1 && opts.length > 0) highlightedModelIndex = 0;
  updateModelHighlight();
}

function closeModelDropdown() {
  modelDropdown.classList.remove('open');
  highlightedModelIndex = -1;
  const opts = modelDropdown.querySelectorAll('.model-opt');
  opts.forEach(el => el.classList.remove('highlighted'));
}

function updateModelHighlight() {
  const opts = modelDropdown.querySelectorAll('.model-opt');
  opts.forEach((el, idx) => {
    el.classList.toggle('highlighted', idx === highlightedModelIndex);
    if (idx === highlightedModelIndex) {
      el.scrollIntoView({ block: 'nearest' });
    }
  });
}

function selectModelAtIndex(idx) {
  const opts = modelDropdown.querySelectorAll('.model-opt');
  if (idx >= 0 && idx < opts.length) {
    opts[idx].click();
  }
}

modelBtn.addEventListener('click', e => {
  e.stopPropagation();
  if (modelDropdown.classList.contains('open')) closeModelDropdown();
  else openModelDropdown();
});
document.addEventListener('click', () => closeModelDropdown());

document.getElementById('close-btn').addEventListener('click', () => {
  window.webkit.messageHandlers.closeWindow.postMessage({});
});
document.getElementById('settings-btn').addEventListener('click', () => {
  window.webkit.messageHandlers.openSettings.postMessage({});
});

// ── Phone Remote ──────────────────────────────────────────────────────────────
function setPhoneQR(url, qrB64) {
  const urlText = document.getElementById('phone-url-text');
  const qrImg = document.getElementById('qr-img');
  if (urlText) urlText.textContent = url;
  if (qrImg) qrImg.src = qrB64;
}

function togglePhoneModal(open) {
  const modal = document.getElementById('phone-modal');
  const btn = document.getElementById('phone-btn');
  const willOpen = open !== undefined ? open : !modal.classList.contains('open');
  modal.classList.toggle('open', willOpen);
  if (btn) btn.classList.toggle('active', willOpen);
  if (willOpen) {
    window.webkit.messageHandlers.getPhoneQR.postMessage({});
  }
}

document.getElementById('phone-btn').addEventListener('click', e => {
  e.stopPropagation();
  togglePhoneModal();
});
document.getElementById('phone-close-btn').addEventListener('click', () => togglePhoneModal(false));
document.getElementById('phone-modal').addEventListener('click', e => {
  if (e.target.id === 'phone-modal') togglePhoneModal(false);
});
document.getElementById('phone-copy-btn').addEventListener('click', () => {
  const u = document.getElementById('phone-url-text').textContent;
  if (u && u !== 'Loading…') {
    navigator.clipboard.writeText(u);
    const b = document.getElementById('phone-copy-btn');
    b.textContent = '✓';
    setTimeout(() => { b.textContent = '📋'; }, 1500);
  }
});

function sendFromRemote(text, withScreenshot) {
  const inp = document.getElementById('inp');
  inp.value = text;
  inp.style.height = 'auto';
  inp.style.height = Math.min(inp.scrollHeight, 72) + 'px';
  if (withScreenshot) {
    sendText(text, true);
  } else {
    send();
  }
}

function typeFromRemote(text) {
  const inp = document.getElementById('inp');
  if (inp) {
    inp.value = text;
    inp.style.height = 'auto';
    inp.style.height = Math.min(inp.scrollHeight, 72) + 'px';
  }
}

// ── Focus & Scroll helpers ────────────────────────────────────────────────────
function focusInput() {
  const inp = document.getElementById('inp');
  if (inp) { inp.focus(); }
}
window.focusInput = focusInput;
window.addEventListener('focus', () => { focusInput(); });
setTimeout(focusInput, 80);

function scrollMessages(delta) {
  const msgs = document.getElementById('msgs');
  if (msgs) msgs.scrollBy({ top: delta, behavior: 'smooth' });
}

function scrollMessagesTo(pos) {
  const msgs = document.getElementById('msgs');
  if (!msgs) return;
  if (pos === 'top') msgs.scrollTo({ top: 0, behavior: 'smooth' });
  else if (pos === 'bottom') msgs.scrollTo({ top: msgs.scrollHeight, behavior: 'smooth' });
}

// ── Auto-scroll toggle ────────────────────────────────────────────────────────
const autoscrollBtn = document.getElementById('autoscroll-btn');
autoscrollBtn.classList.toggle('on', autoScroll);

autoscrollBtn.addEventListener('click', e => {
  e.stopPropagation();
  autoScroll = !autoScroll;
  autoscrollBtn.classList.toggle('on', autoScroll);
  autoscrollBtn.title = autoScroll ? 'Auto-scroll: on' : 'Auto-scroll: off';
  if (autoScroll) {
    const msgs = document.getElementById('msgs');
    msgs.scrollTop = msgs.scrollHeight;
  }
});

document.getElementById('msgs').addEventListener('scroll', () => {
  const msgs = document.getElementById('msgs');
  const atBottom = msgs.scrollHeight - msgs.scrollTop - msgs.clientHeight < 40;
  if (!atBottom && streaming) {
    autoScroll = false;
    autoscrollBtn.classList.remove('on');
  }
});

function receiveModels(models, backend) {
  backendBadge.textContent = backend;
  if (!models.length) { modelName.textContent = 'no models'; return; }
  const saved = window.savedModel; window.savedModel = null;
  if (saved) {
    const match = models.find(m => m === saved || m.startsWith(saved.split(':')[0]));
    if (match) model = match;
  }
  if (!model) model = models[0];
  const match = models.find(m => m === model || m.startsWith(model.split(':')[0]));
  model = match || models[0];
  modelName.textContent = model.split(':')[0];
  modelDropdown.innerHTML = '';
  models.forEach(m => {
    const div = document.createElement('div');
    div.className = 'model-opt' + (m === model ? ' active' : '');
    div.textContent = m;
    div.addEventListener('click', e => {
      e.stopPropagation(); model = m;
      modelName.textContent = m.split(':')[0];
      modelDropdown.querySelectorAll('.model-opt').forEach(el => el.classList.toggle('active', el.textContent === m));
      modelDropdown.classList.remove('open');
    });
    modelDropdown.appendChild(div);
  });
}

// ── Voice Status ──────────────────────────────────────────────────────────────
function onVoiceStatus(hasSpeech, hasBin, hasModel) {
  const hint = document.getElementById('hint');
  if (hasSpeech || (hasBin && hasModel)) {
    hint.classList.remove('visible');
    return;
  }
  if (!hasBin) {
    hint.textContent = '⚠ Voice input: enable Apple Speech in System Settings or install whisper-cpp';
    hint.classList.add('visible');
  } else if (!hasModel) {
    hint.textContent = '⚠ Whisper model not found. Download ggml-base.bin to /opt/homebrew/share/whisper-cpp/';
    hint.classList.add('visible');
  }
}

function onWhisperStatus(hasBin, hasModel) {
  onVoiceStatus(true, hasBin, hasModel);
}

// ── Mic ───────────────────────────────────────────────────────────────────────
const micBtn = document.getElementById('mic-btn');
const btn    = document.getElementById('btn');

function shortcutLabel() {
  let s = '';
  if (shortcut.ctrl)  s += '⌃';
  if (shortcut.opt)   s += '⌥';
  if (shortcut.shift) s += '⇧';
  if (shortcut.cmd)   s += '⌘';
  s += shortcut.key.toUpperCase();
  return s || '—';
}

function toggleMic() {
  if (micState === 'idle') {
    micState = 'recording';
    micBtn.classList.add('recording');
    micBtn.title = 'Stop (' + shortcutLabel() + ')';
    window.webkit.messageHandlers.startRecording.postMessage({});
  } else if (micState === 'recording') {
    micBtn.classList.remove('recording');
    micBtn.title = 'Record (' + shortcutLabel() + ')';
    window.webkit.messageHandlers.stopRecording.postMessage({});
  }
}

micBtn.addEventListener('click', e => { e.preventDefault(); toggleMic(); });

let shortcut = {cmd:true, opt:true, ctrl:false, shift:false, key:''};
function setShortcut(s) { shortcut = s; }
let captureShortcut = {cmd:true, opt:true, ctrl:false, shift:false, key:'c'};
function setCaptureShortcut(s) { captureShortcut = s; }

const MOD_KEYS = new Set(['Meta','Alt','Control','Shift']);
let _scArmed = false, _scCapArmed = false;

function triggerCapture() {
  if (!hasScreenshot && !screenshotBtn.disabled) {
    screenshotBtn.innerHTML = '⏳';
    screenshotBtn.disabled = true;
    window.webkit.messageHandlers.captureScreen.postMessage({});
  }
}

function stopStreaming() {
  if (!streaming) return;
  window.webkit.messageHandlers.stopStream.postMessage({});
  streaming = false; busy = false;
  if (currentBody) {
    const raw = currentBody.textContent;
    currentBody.classList.remove('cursor');
    if (raw) {
      currentBody.setAttribute('data-raw', raw);
      currentBody.innerHTML = renderMarkdown(raw);
      currentBody.classList.add('rendered');
      addCodeCopyButtons(currentBody);
      messages.push({role: 'assistant', content: raw});
    } else {
      messages.length = _messagesLenBeforeLastUser;
    }
    showStreamStats();
  }
  currentBody = null;
  btn.textContent = '↵'; btn.classList.remove('stopping');
}

function clearConversation() {
  if (streaming) stopStreaming();
  messages = [];
  document.getElementById('msgs').innerHTML = '';
  clearScreenshotUI();
  focusInput();
}

function copyLastResponse() {
  const aiMsgs = document.querySelectorAll('.msg.ai');
  if (!aiMsgs.length) return;
  const last = aiMsgs[aiMsgs.length - 1];
  const body = last.querySelector('.body');
  if (!body) return;
  const text = body.getAttribute('data-raw') || body.textContent;
  if (!text) return;
  navigator.clipboard.writeText(text).then(() => {
    const copyBtn = last.querySelector('.copy-btn');
    if (copyBtn) {
      copyBtn.innerHTML = CHECK_ICON;
      copyBtn.style.color = 'var(--accent)';
      setTimeout(() => { copyBtn.innerHTML = COPY_ICON; copyBtn.style.color = ''; }, 1500);
    }
  });
}

document.addEventListener('keydown', e => {
  if (captureShortcut.key &&
      e.metaKey===captureShortcut.cmd && e.altKey===captureShortcut.opt &&
      e.ctrlKey===captureShortcut.ctrl && e.shiftKey===captureShortcut.shift &&
      (e.key.toLowerCase()===captureShortcut.key ||
       e.code.toLowerCase()==='key'+captureShortcut.key)) {
    e.preventDefault(); _scArmed = false; _scCapArmed = false;
    triggerCapture(); return;
  }
  if (shortcut.key) {
    if (e.metaKey===shortcut.cmd && e.altKey===shortcut.opt &&
        e.ctrlKey===shortcut.ctrl && e.shiftKey===shortcut.shift &&
        (e.key.toLowerCase()===shortcut.key ||
         e.code.toLowerCase()==='key'+shortcut.key)) {
      e.preventDefault(); toggleMic();
    }
    return;
  }
  const micMatch = e.metaKey===shortcut.cmd && e.altKey===shortcut.opt &&
                   e.ctrlKey===shortcut.ctrl && e.shiftKey===shortcut.shift;
  const capMatch = e.metaKey===captureShortcut.cmd && e.altKey===captureShortcut.opt &&
                   e.ctrlKey===captureShortcut.ctrl && e.shiftKey===captureShortcut.shift;
  if (MOD_KEYS.has(e.key)) {
    if (!shortcut.key)        _scArmed    = micMatch;
    if (!captureShortcut.key) _scCapArmed = capMatch;
  } else {
    _scArmed = false; _scCapArmed = false;
  }

  // Model dropdown navigation
  if (modelDropdown.classList.contains('open')) {
    const opts = modelDropdown.querySelectorAll('.model-opt');
    if (e.key === 'ArrowDown') {
      e.preventDefault();
      if (opts.length > 0) {
        highlightedModelIndex = (highlightedModelIndex + 1) % opts.length;
        updateModelHighlight();
      }
      return;
    }
    if (e.key === 'ArrowUp') {
      e.preventDefault();
      if (opts.length > 0) {
        highlightedModelIndex = (highlightedModelIndex - 1 + opts.length) % opts.length;
        updateModelHighlight();
      }
      return;
    }
    if (e.key === 'Enter') {
      e.preventDefault();
      selectModelAtIndex(highlightedModelIndex);
      closeModelDropdown();
      focusInput();
      return;
    }
    if (e.key === 'Escape') {
      e.preventDefault();
      closeModelDropdown();
      focusInput();
      return;
    }
  }

  // Escape key: close phone modal -> close dropdown -> stop streaming -> clear input -> close window
  if (e.key === 'Escape') {
    e.preventDefault();
    const phoneModal = document.getElementById('phone-modal');
    if (phoneModal && phoneModal.classList.contains('open')) {
      togglePhoneModal(false);
      focusInput();
      return;
    }
    if (modelDropdown.classList.contains('open')) {
      closeModelDropdown();
      focusInput();
      return;
    }
    if (streaming) {
      stopStreaming();
      focusInput();
      return;
    }
    const inp = document.getElementById('inp');
    if (document.activeElement === inp && inp.value.length > 0) {
      inp.value = '';
      inp.style.height = 'auto';
      return;
    }
    window.webkit.messageHandlers.closeWindow.postMessage({});
    return;
  }

  // Cmd+P : toggle phone remote keyboard modal
  if (e.metaKey && !e.shiftKey && e.key.toLowerCase() === 'p') {
    e.preventDefault();
    togglePhoneModal();
    return;
  }

  // Cmd+. : stop streaming
  if (e.metaKey && e.key === '.') {
    if (streaming) {
      e.preventDefault();
      stopStreaming();
      focusInput();
      return;
    }
  }

  // Cmd+W : close window
  if (e.metaKey && !e.shiftKey && e.key.toLowerCase() === 'w') {
    e.preventDefault();
    window.webkit.messageHandlers.closeWindow.postMessage({});
    return;
  }

  // Cmd+, : open settings
  if (e.metaKey && e.key === ',') {
    e.preventDefault();
    window.webkit.messageHandlers.openSettings.postMessage({});
    return;
  }

  // Cmd+M : toggle model dropdown
  if (e.metaKey && !e.shiftKey && e.key.toLowerCase() === 'm') {
    e.preventDefault();
    if (modelDropdown.classList.contains('open')) closeModelDropdown();
    else openModelDropdown();
    return;
  }

  // Cmd+K : clear chat
  if (e.metaKey && e.key.toLowerCase() === 'k') {
    e.preventDefault();
    clearConversation();
    return;
  }

  // Cmd+L : focus input and select text
  if (e.metaKey && !e.shiftKey && e.key.toLowerCase() === 'l') {
    e.preventDefault();
    focusInput();
    const inp = document.getElementById('inp');
    if (inp) inp.select();
    return;
  }

  // / key : focus input if not currently typing in input
  if (e.key === '/' && document.activeElement !== document.getElementById('inp')) {
    e.preventDefault();
    focusInput();
    return;
  }

  // Cmd+Shift+C : copy last response
  if (e.metaKey && e.shiftKey && e.key.toLowerCase() === 'c') {
    e.preventDefault();
    copyLastResponse();
    return;
  }

  // Scrolling chat history without mouse
  if (e.key === 'PageUp') {
    e.preventDefault();
    scrollMessages(-220);
    return;
  }
  if (e.key === 'PageDown') {
    e.preventDefault();
    scrollMessages(220);
    return;
  }
  if (e.key === 'Home' && (document.activeElement !== document.getElementById('inp') || e.metaKey)) {
    e.preventDefault();
    scrollMessagesTo('top');
    return;
  }
  if (e.key === 'End' && (document.activeElement !== document.getElementById('inp') || e.metaKey)) {
    e.preventDefault();
    scrollMessagesTo('bottom');
    return;
  }
  if (e.metaKey && e.key === '[') {
    e.preventDefault();
    scrollMessages(-220);
    return;
  }
  if (e.metaKey && e.key === ']') {
    e.preventDefault();
    scrollMessages(220);
    return;
  }
  if (e.ctrlKey && e.key.toLowerCase() === 'u') {
    e.preventDefault();
    scrollMessages(-220);
    return;
  }
  if (e.ctrlKey && e.key.toLowerCase() === 'd') {
    e.preventDefault();
    scrollMessages(220);
    return;
  }
  if (e.altKey && !e.metaKey && !e.shiftKey && !e.ctrlKey) {
    const inp = document.getElementById('inp');
    if (e.key === 'ArrowUp' && (document.activeElement !== inp || inp.value === '')) {
      e.preventDefault();
      scrollMessages(-180);
      return;
    }
    if (e.key === 'ArrowDown' && (document.activeElement !== inp || inp.value === '')) {
      e.preventDefault();
      scrollMessages(180);
      return;
    }
  }
});

document.addEventListener('keyup', e => {
  if (!MOD_KEYS.has(e.key)) return;
  if (_scArmed)    { _scArmed = false;    toggleMic(); }
  if (_scCapArmed) { _scCapArmed = false; triggerCapture(); }
});

btn.addEventListener('click', e => {
  e.preventDefault();
  if (streaming) {
    stopStreaming();
    return;
  }
  send();
});

function onRecordingStarted() { micState = 'recording'; }

function onTranscribing() {
  micState = 'transcribing';
  micBtn.classList.remove('recording');
  micBtn.classList.add('transcribing');
  micBtn.textContent = '⏳';
}

function onTranscription(text) {
  micState = 'idle';
  micBtn.classList.remove('recording','transcribing');
  micBtn.textContent = '🎙';
  micBtn.title = 'Record (' + shortcutLabel() + ')';
  if (text && text.trim()) {
    const inp = document.getElementById('inp');
    inp.value = text.trim();
    inp.style.height = 'auto';
    inp.style.height = Math.min(inp.scrollHeight, 72) + 'px';
    inp.focus();
  }
}

function onMicError(msg) {
  micState = 'idle';
  micBtn.classList.remove('recording','transcribing');
  micBtn.textContent = '🎙';
  micBtn.title = 'Record (' + shortcutLabel() + ')';
  addMsg('err').textContent = msg;
}

// ── Chat ──────────────────────────────────────────────────────────────────────
function addMsg(role) {
  const c = document.getElementById('msgs'), d = document.createElement('div');
  d.className = 'msg ' + role;
  const L = {user:'you', ai:model.split(':')[0], err:'error'};
  d.innerHTML = '<div class="lbl">' + (L[role]||role) + '</div><div class="body"></div>';
  if (role === 'ai') {
    const copyBtn = document.createElement('button');
    copyBtn.className = 'copy-btn';
    copyBtn.title = 'Copy';
    copyBtn.innerHTML = COPY_ICON;
    copyBtn.addEventListener('click', () => {
      const body = d.querySelector('.body');
      const text = body.getAttribute('data-raw') || body.textContent;
      navigator.clipboard.writeText(text).then(() => {
        copyBtn.innerHTML = CHECK_ICON;
        copyBtn.style.color = 'var(--accent)';
        setTimeout(() => { copyBtn.innerHTML = COPY_ICON; copyBtn.style.color = ''; }, 1500);
      });
    });
    d.appendChild(copyBtn);
  }
  c.appendChild(d); c.scrollTop = c.scrollHeight;
  return d.querySelector('.body');
}

function appendToken(t) {
  if (!currentBody) return;
  tokenCount++;
  currentBody.textContent += t;
  if (autoScroll) {
    const msgs = document.getElementById('msgs');
    msgs.scrollTop = msgs.scrollHeight;
  }
}

function showStreamStats() {
  if (!currentBody || !streamStartTime) return;
  const elapsed = (Date.now() - streamStartTime) / 1000;
  if (elapsed < 0.1 || tokenCount < 2) return;
  const tps = (tokenCount / elapsed).toFixed(1);
  const lbl = currentBody.closest('.msg') && currentBody.closest('.msg').querySelector('.lbl');
  if (lbl) lbl.textContent = lbl.textContent.split('·')[0].trim() + ' · ' + tps + ' t/s';
}

function endStream(isError) {
  streaming = false; busy = false;
  btn.textContent = '↵'; btn.classList.remove('stopping');
  if (!currentBody) return;
  const raw = currentBody.textContent;
  currentBody.classList.remove('cursor');
  if (raw) {
    currentBody.setAttribute('data-raw', raw);
    currentBody.innerHTML = renderMarkdown(raw);
    currentBody.classList.add('rendered');
    addCodeCopyButtons(currentBody);
    messages.push({role: 'assistant', content: raw});
  } else {
    messages.length = _messagesLenBeforeLastUser;
  }
  showStreamStats();
  if (isError || !raw) {
    const msgDiv = currentBody.closest('.msg');
    const retryBtn = document.createElement('button');
    retryBtn.className = 'retry-btn';
    retryBtn.textContent = '↺ retry';
    retryBtn.addEventListener('click', () => {
      messages.length = _messagesLenBeforeLastUser;
      if (msgDiv) msgDiv.remove();
      sendText(lastUserText, lastScreenshot);
    });
    if (msgDiv) msgDiv.appendChild(retryBtn);
  }
  currentBody = null;
}

// ── Screenshot ────────────────────────────────────────────────────────────────
const screenshotBtn = document.getElementById('screenshot-btn');
const screenshotIndicator = document.getElementById('screenshot-indicator');
const SCREENSHOT_ICON = screenshotBtn.innerHTML;

screenshotBtn.addEventListener('click', e => {
  e.preventDefault();
  if (hasScreenshot) {
    clearScreenshotUI();
    window.webkit.messageHandlers.clearScreenshot.postMessage({});
  } else {
    screenshotBtn.innerHTML = '⏳';
    screenshotBtn.disabled = true;
    window.webkit.messageHandlers.captureScreen.postMessage({});
  }
});

screenshotIndicator.addEventListener('click', () => {
  clearScreenshotUI();
  window.webkit.messageHandlers.clearScreenshot.postMessage({});
});

function clearScreenshotUI() {
  hasScreenshot = false;
  screenshotBtn.innerHTML = SCREENSHOT_ICON;
  screenshotBtn.classList.remove('captured');
  screenshotBtn.title = 'Capture screen';
  screenshotBtn.disabled = false;
  screenshotIndicator.style.display = 'none';
}

function onScreenshotCaptured() {
  hasScreenshot = true;
  lastScreenshot = true;
  screenshotBtn.innerHTML = SCREENSHOT_ICON;
  screenshotBtn.classList.add('captured');
  screenshotBtn.title = 'Screenshot attached — click to remove';
  screenshotBtn.disabled = false;
  screenshotIndicator.style.display = 'block';
  document.getElementById('inp').focus();
}

function onScreenshotError() {
  screenshotBtn.innerHTML = SCREENSHOT_ICON;
  screenshotBtn.disabled = false;
  screenshotBtn.title = 'Screen capture failed — check System Settings > Privacy > Screen Recording';
}

let promptHistory = [];
let historyIndex = -1;
let currentDraft = '';

function sendText(text, withScreenshot) {
  if (busy || !text) return;
  modelDropdown.classList.remove('open');
  if (text && (!promptHistory.length || promptHistory[promptHistory.length - 1] !== text)) {
    promptHistory.push(text);
  }
  historyIndex = -1;
  currentDraft = '';
  const hasImg = !!(withScreenshot || hasScreenshot);
  addMsg('user').textContent = text + (hasImg ? ' 📎' : '');
  currentBody = addMsg('ai');
  currentBody.classList.add('cursor');
  busy = true; streaming = true;
  streamStartTime = Date.now(); tokenCount = 0;
  btn.textContent = '⏹'; btn.classList.add('stopping');
  lastUserText = text;
  lastScreenshot = hasImg;
  _messagesLenBeforeLastUser = messages.length;
  messages.push({role: 'user', content: text});
  if (hasScreenshot) clearScreenshotUI();
  const ctx = hasImg
    ? [messages[messages.length - 1]]
    : (messages.length > CTX_WINDOW ? messages.slice(-CTX_WINDOW) : messages);
  window.webkit.messageHandlers.sendMessage.postMessage({messages: ctx, model: model, screenshot: hasImg || null});
}

function send() {
  const inp = document.getElementById('inp');
  let text = inp.value.trim();
  if (!text && hasScreenshot) text = screenshotPrompt || 'Look at this screenshot. Find any programming problem, error, or bug and explain how to fix it.';
  if (!text) return;
  inp.value = ''; inp.style.height = 'auto';
  sendText(text);
}

const inp = document.getElementById('inp');
inp.addEventListener('keydown', e => {
  // Enter or Cmd+Enter to send
  if ((e.key === 'Enter' && !e.shiftKey) || (e.key === 'Enter' && e.metaKey)) {
    e.preventDefault();
    send();
    return;
  }

  // Prompt history navigation: ArrowUp
  if (e.key === 'ArrowUp' && !e.shiftKey && !e.metaKey && !e.altKey && !e.ctrlKey) {
    if (inp.selectionStart === 0 && inp.selectionEnd === 0 && promptHistory.length > 0) {
      e.preventDefault();
      if (historyIndex === -1) {
        currentDraft = inp.value;
        historyIndex = promptHistory.length - 1;
      } else if (historyIndex > 0) {
        historyIndex--;
      }
      inp.value = promptHistory[historyIndex];
      inp.style.height = 'auto';
      inp.style.height = Math.min(inp.scrollHeight, 72) + 'px';
      inp.setSelectionRange(inp.value.length, inp.value.length);
      return;
    }
  }

  // Prompt history navigation: ArrowDown
  if (e.key === 'ArrowDown' && !e.shiftKey && !e.metaKey && !e.altKey && !e.ctrlKey) {
    if (historyIndex !== -1) {
      e.preventDefault();
      if (historyIndex < promptHistory.length - 1) {
        historyIndex++;
        inp.value = promptHistory[historyIndex];
      } else {
        historyIndex = -1;
        inp.value = currentDraft;
      }
      inp.style.height = 'auto';
      inp.style.height = Math.min(inp.scrollHeight, 72) + 'px';
      inp.setSelectionRange(inp.value.length, inp.value.length);
      return;
    }
  }

  setTimeout(() => {
    inp.style.height = 'auto';
    inp.style.height = Math.min(inp.scrollHeight, 72) + 'px';
  }, 0);
});

</script>
</body>
</html>
""" }

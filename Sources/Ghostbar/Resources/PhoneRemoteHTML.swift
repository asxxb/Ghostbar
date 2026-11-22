import Foundation

func phoneRemoteHTML() -> String {
    return """
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="theme-color" content="#121317">
<title>Ghostbar Remote</title>
<style>
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600&family=Inter:wght@400;500;600&display=swap');
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent}
:root{
  --bg:#121317;--surface:#1a1c23;--card:#22252e;--border:rgba(255,255,255,0.08);
  --text:#d8d8e0;--muted:#727282;--accent:#4ade80;
  --user:#7dd3fc;--error:#f87171;--font-mono:'JetBrains Mono',monospace;
  --font-sans:'Inter',-apple-system,BlinkMacSystemFont,sans-serif;
}
html,body{height:100%;background:var(--bg);color:var(--text);font-family:var(--font-sans);font-size:15px;line-height:1.5;overflow:hidden}
#app{display:flex;flex-direction:column;height:100dvh;padding-top:env(safe-area-inset-top);padding-bottom:env(safe-area-inset-bottom)}

/* Header */
#header{display:flex;align-items:center;justify-content:space-between;padding:12px 16px;background:var(--surface);border-bottom:1px solid var(--border);flex-shrink:0}
#brand{display:flex;align-items:center;gap:8px;font-family:var(--font-mono);font-size:13px;font-weight:600;letter-spacing:-0.02em}
#brand .icon{color:var(--accent);font-size:15px}
#status-indicator{display:flex;align-items:center;gap:6px;font-size:11px;font-family:var(--font-mono);color:var(--muted)}
#dot{width:7px;height:7px;border-radius:50%;background:var(--accent);box-shadow:0 0 6px var(--accent)}
#dot.disconnected{background:var(--error);box-shadow:0 0 6px var(--error)}
#header-actions{display:flex;align-items:center;gap:8px}
.pill-btn{background:none;border:1px solid var(--border);color:var(--muted);font-family:var(--font-mono);font-size:11px;padding:4px 8px;border-radius:14px;cursor:pointer;display:flex;align-items:center;gap:4px;transition:all .15s}
.pill-btn.active{border-color:var(--accent);color:var(--accent);background:rgba(74,222,128,0.08)}

/* Chat history */
#msgs{flex:1;overflow-y:auto;padding:14px;scroll-behavior:smooth}
.msg{margin-bottom:12px;background:var(--card);border:1px solid var(--border);border-radius:10px;padding:10px 12px;animation:fade .15s ease}
.msg.user{background:transparent;border-color:transparent;padding:4px 0}
.lbl{font-size:10px;font-family:var(--font-mono);letter-spacing:.05em;text-transform:uppercase;color:var(--muted);margin-bottom:4px}
.msg.user .lbl{color:var(--user)}
.msg.ai .lbl{color:var(--accent)}
.msg.err .lbl{color:var(--error)}
.body{white-space:pre-wrap;word-break:break-word;font-size:14px;line-height:1.55}
.msg.user .body{color:var(--user);font-weight:500}
.msg.ai .body{font-family:var(--font-mono);font-size:13px}
.body code{background:rgba(0,0,0,.35);padding:2px 5px;border-radius:4px;font-family:var(--font-mono);font-size:0.9em}
.body pre{background:rgba(0,0,0,.5);border:1px solid var(--border);border-radius:6px;padding:8px 10px;margin:6px 0;overflow-x:auto}
.cursor::after{content:'▋';color:var(--accent);animation:blink .7s step-end infinite;margin-left:2px}
@keyframes blink{0%,100%{opacity:1}50%{opacity:0}}
@keyframes fade{from{opacity:0;transform:translateY(4px)}to{opacity:1;transform:none}}

#stealth-notice{display:none;padding:24px 16px;text-align:center;color:var(--muted);font-size:13px;font-family:var(--font-mono)}
#stealth-notice.show{display:block}

/* Input area */
#bottom{background:var(--surface);border-top:1px solid var(--border);padding:10px 14px 14px;flex-shrink:0}
#input-wrap{display:flex;flex-direction:column;gap:10px}

/* Big Voice Button */
.big-voice-btn{
  width:100%;
  padding:14px 18px;
  background:linear-gradient(135deg, rgba(74,222,128,0.16), rgba(74,222,128,0.06));
  border:1.5px solid var(--accent);
  border-radius:12px;
  color:var(--accent);
  cursor:pointer;
  display:flex;
  align-items:center;
  justify-content:center;
  gap:12px;
  transition:all .2s ease;
  user-select:none;
  -webkit-user-select:none;
  box-shadow:0 4px 16px rgba(0,0,0,0.25);
}
.big-voice-btn:active{
  transform:scale(0.98);
  opacity:0.9;
}
.big-voice-btn.recording{
  background:linear-gradient(135deg, rgba(248,113,113,0.3), rgba(248,113,113,0.12));
  border-color:var(--error);
  color:#ff9898;
  animation:voicePulse 1.2s ease-in-out infinite;
}
@keyframes voicePulse{
  0%,100%{box-shadow:0 0 0 0 rgba(248,113,113,0.45)}
  50%{box-shadow:0 0 0 10px rgba(248,113,113,0)}
}
.voice-mic-icon{
  font-size:24px;
  line-height:1;
  display:inline-block;
  transition:transform .2s;
}
.big-voice-btn.recording .voice-mic-icon{
  animation:micPop .6s ease infinite alternate;
}
@keyframes micPop{
  from{transform:scale(1)}
  to{transform:scale(1.25)}
}
.voice-text-group{
  display:flex;
  flex-direction:column;
  align-items:flex-start;
  text-align:left;
}
.voice-title{
  font-family:var(--font-mono);
  font-size:14px;
  font-weight:600;
  letter-spacing:-0.01em;
}
.voice-sub{
  font-family:var(--font-sans);
  font-size:11px;
  color:var(--muted);
  opacity:0.85;
}
.big-voice-btn.recording .voice-sub{
  color:#ffcaca;
}

#phone-inp{width:100%;background:var(--card);border:1px solid var(--border);border-radius:10px;color:var(--text);font-family:var(--font-sans);font-size:15px;line-height:1.45;padding:10px 12px;resize:none;outline:none;caret-color:var(--accent);max-height:120px;min-height:48px;-webkit-appearance:none}
#phone-inp:focus{border-color:var(--accent)}
#phone-inp::placeholder{color:var(--muted)}

#toolbar{display:flex;align-items:center;justify-content:space-between}
#toolbar-left{display:flex;align-items:center;gap:6px}
.tool-btn{background:var(--card);border:1px solid var(--border);color:var(--muted);font-family:var(--font-mono);font-size:12px;padding:7px 11px;border-radius:8px;cursor:pointer;display:inline-flex;align-items:center;gap:5px;transition:all .15s}
.tool-btn:active{transform:scale(0.96)}
.tool-btn.active{border-color:var(--accent);color:var(--accent)}
#send-btn{background:var(--accent);color:#0e1014;border:none;font-family:var(--font-mono);font-size:13px;font-weight:600;padding:8px 18px;border-radius:8px;cursor:pointer;display:inline-flex;align-items:center;gap:6px;transition:opacity .15s}
#send-btn:active{opacity:0.85;transform:scale(0.97)}
#send-btn.stopping{background:var(--error);color:#fff}
</style>
</head>
<body>
<div id="app">
  <div id="header">
    <div id="brand">
      <span class="icon">⬡</span>
      <span>Ghostbar Remote</span>
    </div>
    <div id="header-actions">
      <button id="stealth-btn" class="pill-btn" title="Toggle response display on phone">🕶 Stealth</button>
      <div id="status-indicator">
        <div id="dot"></div>
        <span id="status-text">Connected</span>
      </div>
    </div>
  </div>

  <div id="stealth-notice">
    🕶 Stealth Mode Active<br>
    <span style="font-size:11px;color:#5a5a6a">Prompts are sent directly to your Mac. Responses stay hidden on this screen.</span>
  </div>

  <div id="msgs"></div>

  <div id="bottom">
    <div id="input-wrap">
      <!-- Big Prominent Voice Control Button -->
      <button id="voice-btn" class="big-voice-btn" type="button">
        <span class="voice-mic-icon">🎙</span>
        <div class="voice-text-group">
          <span id="voice-title" class="voice-title">Tap to Speak</span>
          <span id="voice-sub" class="voice-sub">Live English Voice to Text</span>
        </div>
      </button>

      <textarea id="phone-inp" placeholder="Type prompt or tap 🎙 Speak above..." rows="2"></textarea>
      <div id="toolbar">
        <div id="toolbar-left">
          <button id="screenshot-btn" class="tool-btn">📷 Screen</button>
          <button id="clear-btn" class="tool-btn">🗑 Clear</button>
        </div>
        <button id="send-btn">↵ Send</button>
      </div>
    </div>
  </div>
</div>

<script>
let stealthMode = localStorage.getItem('ghostbar_stealth') === 'true';
let withScreenshot = false;
let streaming = false;
let currentAiBody = null;

const dot = document.getElementById('dot');
const statusText = document.getElementById('status-text');
const stealthBtn = document.getElementById('stealth-btn');
const stealthNotice = document.getElementById('stealth-notice');
const msgs = document.getElementById('msgs');
const inp = document.getElementById('phone-inp');
const sendBtn = document.getElementById('send-btn');
const screenshotBtn = document.getElementById('screenshot-btn');
const clearBtn = document.getElementById('clear-btn');
const voiceBtn = document.getElementById('voice-btn');
const voiceTitle = document.getElementById('voice-title');
const voiceSub = document.getElementById('voice-sub');
let isRecordingVoice = false;

function updateVoiceUI(recording) {
  isRecordingVoice = recording;
  voiceBtn.classList.toggle('recording', recording);
  if (recording) {
    voiceTitle.textContent = '🔴 Listening…';
    voiceSub.textContent = 'Speak in English (Tap to Finish)';
  } else {
    voiceTitle.textContent = '🎙 Tap to Speak';
    voiceSub.textContent = 'Live English Voice to Text';
  }
}

voiceBtn.addEventListener('click', () => {
  vibrate(25);
  fetch('/api/voice', {method: 'POST'}).catch(() => {});
});

function updateStealthUI() {
  stealthBtn.classList.toggle('active', stealthMode);
  stealthNotice.classList.toggle('show', stealthMode);
  msgs.style.display = stealthMode ? 'none' : 'block';
  localStorage.setItem('ghostbar_stealth', stealthMode);
}
stealthBtn.addEventListener('click', () => {
  stealthMode = !stealthMode;
  updateStealthUI();
});
updateStealthUI();

function vibrate(ms = 10) {
  if (navigator.vibrate) navigator.vibrate(ms);
}

// ── SSE Connection ────────────────────────────────────────────────────────────
let es = null;
function connectSSE() {
  if (es) es.close();
  es = new EventSource('/api/events');
  es.onopen = () => {
    dot.className = '';
    statusText.textContent = 'Connected';
  };
  es.onerror = () => {
    dot.className = 'disconnected';
    statusText.textContent = 'Reconnecting…';
  };

  es.addEventListener('user', e => {
    if (stealthMode) return;
    const d = document.createElement('div');
    d.className = 'msg user';
    d.innerHTML = '<div class="lbl">you</div><div class="body">' + escapeHtml(e.data) + '</div>';
    msgs.appendChild(d);
    msgs.scrollTop = msgs.scrollHeight;
  });

  es.addEventListener('token', e => {
    if (stealthMode) return;
    if (!currentAiBody) {
      const d = document.createElement('div');
      d.className = 'msg ai';
      d.innerHTML = '<div class="lbl">ghostbar</div><div class="body cursor"></div>';
      msgs.appendChild(d);
      currentAiBody = d.querySelector('.body');
      streaming = true;
      sendBtn.textContent = '⏹ Stop';
      sendBtn.classList.add('stopping');
    }
    currentAiBody.textContent += e.data;
    msgs.scrollTop = msgs.scrollHeight;
  });

  es.addEventListener('end', () => {
    if (currentAiBody) {
      currentAiBody.classList.remove('cursor');
      currentAiBody = null;
    }
    streaming = false;
    sendBtn.textContent = '↵ Send';
    sendBtn.classList.remove('stopping');
  });

  es.addEventListener('clear', () => {
    msgs.innerHTML = '';
    currentAiBody = null;
    streaming = false;
    sendBtn.textContent = '↵ Send';
    sendBtn.classList.remove('stopping');
  });

  let micPreText = '';
  es.addEventListener('micState', e => {
    const recording = e.data === 'true';
    if (recording) {
      micPreText = inp.value.trim();
    } else {
      micPreText = '';
    }
    updateVoiceUI(recording);
  });

  es.addEventListener('liveSpeech', e => {
    if (e.data && e.data.trim()) {
      const combined = micPreText ? (micPreText + ' ' + e.data.trim()) : e.data.trim();
      inp.value = combined;
      inp.style.height = 'auto';
      inp.style.height = Math.min(inp.scrollHeight, 120) + 'px';
    }
  });

  es.addEventListener('transcription', e => {
    if (e.data && e.data.trim()) {
      const combined = micPreText ? (micPreText + ' ' + e.data.trim()) : e.data.trim();
      inp.value = combined;
      inp.style.height = 'auto';
      inp.style.height = Math.min(inp.scrollHeight, 120) + 'px';
    }
    micPreText = '';
  });
}
connectSSE();

function escapeHtml(t) {
  return t.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
}

// ── Typing sync ───────────────────────────────────────────────────────────────
let typeTimer = null;
inp.addEventListener('input', () => {
  inp.style.height = 'auto';
  inp.style.height = Math.min(inp.scrollHeight, 120) + 'px';
  clearTimeout(typeTimer);
  typeTimer = setTimeout(() => {
    fetch('/api/type', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({text: inp.value})
    }).catch(() => {});
  }, 120);
});

// ── Send Prompt ───────────────────────────────────────────────────────────────
function sendPrompt() {
  if (streaming) {
    fetch('/api/stop', {method: 'POST'});
    streaming = false;
    sendBtn.textContent = '↵ Send';
    sendBtn.classList.remove('stopping');
    return;
  }
  const text = inp.value.trim();
  if (!text && !withScreenshot) return;
  vibrate(15);
  fetch('/api/send', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({text: text, screenshot: withScreenshot})
  }).then(() => {
    inp.value = '';
    inp.style.height = 'auto';
    withScreenshot = false;
    screenshotBtn.classList.remove('active');
  });
}

sendBtn.addEventListener('click', sendPrompt);

inp.addEventListener('keydown', e => {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault();
    sendPrompt();
  }
});

screenshotBtn.addEventListener('click', () => {
  withScreenshot = !withScreenshot;
  screenshotBtn.classList.toggle('active', withScreenshot);
  vibrate(10);
  if (withScreenshot) {
    fetch('/api/screenshot', {method: 'POST'}).catch(() => {});
  }
});

clearBtn.addEventListener('click', () => {
  vibrate(10);
  fetch('/api/clear', {method: 'POST'}).catch(() => {});
  msgs.innerHTML = '';
});
</script>
</body>
</html>
"""
}


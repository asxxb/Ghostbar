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
@import url('https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600&family=Inter:wght@400;500;600;700&display=swap');
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent}
:root{
  --bg:#121317;--surface:#1a1c23;--card:#22252e;--border:rgba(255,255,255,0.08);
  --text:#e2e2ec;--muted:#7c7c90;--accent:#4ade80;--accent-dark:#22c55e;
  --stop:#f87171;--stop-bg:rgba(248,113,113,0.14);
  --font-mono:'JetBrains Mono',monospace;
  --font-sans:'Inter',-apple-system,BlinkMacSystemFont,sans-serif;
}
html,body{height:100%;background:var(--bg);color:var(--text);font-family:var(--font-sans);font-size:15px;line-height:1.4;overflow:hidden}
#app{display:flex;flex-direction:column;height:100dvh;padding:env(safe-area-inset-top) 16px env(safe-area-inset-bottom) 16px}

/* Header */
#header{display:flex;align-items:center;justify-content:space-between;padding:14px 4px;flex-shrink:0}
#brand{display:flex;align-items:center;gap:8px;font-family:var(--font-mono);font-size:14px;font-weight:600;letter-spacing:-0.02em}
#brand .icon{color:var(--accent);font-size:16px}
#status-indicator{display:flex;align-items:center;gap:6px;font-size:12px;font-family:var(--font-mono);color:var(--muted)}
#dot{width:8px;height:8px;border-radius:50%;background:var(--accent);box-shadow:0 0 8px var(--accent);transition:all .3s}
#dot.disconnected{background:var(--stop);box-shadow:0 0 8px var(--stop)}

/* Main Controller Area */
#main-wrap{flex:1;display:flex;flex-direction:column;justify-content:center;gap:16px;max-width:440px;width:100%;margin:0 auto}

/* Text Input for Phone Keyboard */
#input-box-wrap{display:flex;flex-direction:column;gap:6px}
#phone-inp{
  width:100%;
  background:var(--card);
  border:1.5px solid var(--border);
  border-radius:14px;
  color:var(--text);
  font-family:var(--font-sans);
  font-size:16px;
  line-height:1.45;
  padding:14px 16px;
  resize:none;
  outline:none;
  caret-color:var(--accent);
  min-height:76px;
  max-height:130px;
  -webkit-appearance:none;
  transition:border-color .2s, box-shadow .2s;
}
#phone-inp:focus{
  border-color:var(--accent);
  box-shadow:0 0 0 3px rgba(74,222,128,0.12);
}
#phone-inp::placeholder{color:var(--muted);font-size:14px}

/* Buttons Stack */
#buttons-stack{display:flex;flex-direction:column;gap:12px}

/* Base Big Button Style */
.big-action-btn{
  width:100%;
  min-height:72px;
  padding:14px 20px;
  border-radius:16px;
  cursor:pointer;
  display:flex;
  align-items:center;
  gap:16px;
  transition:all .18s ease;
  user-select:none;
  -webkit-user-select:none;
  box-shadow:0 6px 20px rgba(0,0,0,0.3);
  text-align:left;
  border:none;
}
.big-action-btn:active{
  transform:scale(0.98);
  opacity:0.92;
}

.btn-icon{
  font-size:28px;
  line-height:1;
  display:flex;
  align-items:center;
  justify-content:center;
  width:38px;
  flex-shrink:0;
}
.btn-text{
  display:flex;
  flex-direction:column;
  align-items:flex-start;
  flex:1;
}
.btn-title{
  font-family:var(--font-sans);
  font-size:16px;
  font-weight:700;
  letter-spacing:-0.01em;
  line-height:1.25;
}
.btn-sub{
  font-size:12px;
  opacity:0.8;
  margin-top:2px;
  line-height:1.2;
}

/* 1. Large Audio / Voice Button */
#voice-btn{
  background:linear-gradient(135deg, rgba(74,222,128,0.16), rgba(74,222,128,0.06));
  border:1.5px solid var(--accent);
  color:var(--accent);
}
#voice-btn.recording{
  background:linear-gradient(135deg, rgba(248,113,113,0.32), rgba(248,113,113,0.14));
  border-color:var(--stop);
  color:#ff9999;
  animation:voicePulse 1.2s ease-in-out infinite;
}
#voice-btn.recording .btn-icon{
  animation:micPop .6s ease infinite alternate;
}
@keyframes voicePulse{
  0%,100%{box-shadow:0 0 0 0 rgba(248,113,113,0.5)}
  50%{box-shadow:0 0 0 12px rgba(248,113,113,0)}
}
@keyframes micPop{
  from{transform:scale(1)}
  to{transform:scale(1.25)}
}

/* 2. Large Enter / Send Button */
#send-btn{
  background:linear-gradient(135deg, var(--accent), var(--accent-dark));
  color:#0d1117;
  border:none;
}
#send-btn .btn-title{
  color:#090d14;
}
#send-btn .btn-sub{
  color:#153d23;
  font-weight:500;
}

/* 3. Large Stop Button */
#stop-btn{
  background:var(--stop-bg);
  border:1.5px solid rgba(248,113,113,0.35);
  color:var(--stop);
}
#stop-btn.streaming{
  border-color:var(--stop);
  background:linear-gradient(135deg, rgba(248,113,113,0.28), rgba(248,113,113,0.1));
  box-shadow:0 0 16px rgba(248,113,113,0.25);
  animation:stopGlow 1.4s ease-in-out infinite;
}
@keyframes stopGlow{
  0%,100%{opacity:1}
  50%{opacity:0.8}
}

/* Footer stealth note */
#footer-note{
  text-align:center;
  font-size:11px;
  font-family:var(--font-mono);
  color:var(--muted);
  opacity:0.6;
  padding:10px 0;
}
</style>
</head>
<body>
<div id="app">
  <div id="header">
    <div id="brand">
      <span class="icon">⬡</span>
      <span>Ghostbar Remote</span>
    </div>
    <div id="status-indicator">
      <div id="dot"></div>
      <span id="status-text">Connected</span>
    </div>
  </div>

  <div id="main-wrap">
    <!-- Prompt Text Input for Phone Keyboard -->
    <div id="input-box-wrap">
      <textarea id="phone-inp" placeholder="Type prompt or tap 🎙 Speak below..." rows="2"></textarea>
    </div>

    <!-- The 3 Big Buttons Only -->
    <div id="buttons-stack">
      <!-- 1. Big Audio / Voice Button -->
      <button id="voice-btn" class="big-action-btn" type="button">
        <span class="btn-icon">🎙</span>
        <div class="btn-text">
          <span id="voice-title" class="btn-title">Tap to Speak</span>
          <span id="voice-sub" class="btn-sub">Live English Voice to Text</span>
        </div>
      </button>

      <!-- 2. Big Enter / Send Button -->
      <button id="send-btn" class="big-action-btn" type="button">
        <span class="btn-icon">↵</span>
        <div class="btn-text">
          <span class="btn-title">Send / Enter</span>
          <span class="btn-sub">Submit prompt to Mac</span>
        </div>
      </button>

      <!-- 3. Big Stop Generation Button -->
      <button id="stop-btn" class="big-action-btn" type="button">
        <span class="btn-icon">⏹</span>
        <div class="btn-text">
          <span class="btn-title">Stop Generation</span>
          <span class="btn-sub">Halt AI response on Mac</span>
        </div>
      </button>
    </div>
  </div>

  <div id="footer-note">
    Stealth Controller · Output displays only on Mac
  </div>
</div>

<script>
const dot = document.getElementById('dot');
const statusText = document.getElementById('status-text');
const inp = document.getElementById('phone-inp');
const voiceBtn = document.getElementById('voice-btn');
const voiceTitle = document.getElementById('voice-title');
const voiceSub = document.getElementById('voice-sub');
const sendBtn = document.getElementById('send-btn');
const stopBtn = document.getElementById('stop-btn');

let isRecordingVoice = false;
let isStreaming = false;

function vibrate(ms = 12) {
  if (navigator.vibrate) navigator.vibrate(ms);
}

// ── Voice Button ──────────────────────────────────────────────────────────────
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
  vibrate(20);
  fetch('/api/voice', {method: 'POST'}).catch(() => {});
});

// ── Send / Enter Button ───────────────────────────────────────────────────────
function sendPrompt() {
  const text = inp.value.trim();
  if (!text) return;
  vibrate(15);
  fetch('/api/send', {
    method: 'POST',
    headers: {'Content-Type': 'application/json'},
    body: JSON.stringify({text: text, screenshot: false})
  }).then(() => {
    inp.value = '';
    inp.style.height = 'auto';
  }).catch(() => {});
}

sendBtn.addEventListener('click', sendPrompt);

inp.addEventListener('keydown', e => {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault();
    sendPrompt();
  }
});

// ── Stop Button ───────────────────────────────────────────────────────────────
stopBtn.addEventListener('click', () => {
  vibrate(25);
  fetch('/api/stop', {method: 'POST'}).catch(() => {});
  updateStreamingUI(false);
});

function updateStreamingUI(streaming) {
  isStreaming = streaming;
  stopBtn.classList.toggle('streaming', streaming);
}

// ── Typing Sync to Mac ────────────────────────────────────────────────────────
let typeTimer = null;
inp.addEventListener('input', () => {
  inp.style.height = 'auto';
  inp.style.height = Math.min(inp.scrollHeight, 130) + 'px';
  clearTimeout(typeTimer);
  typeTimer = setTimeout(() => {
    fetch('/api/type', {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({text: inp.value})
    }).catch(() => {});
  }, 120);
});

// ── SSE Connection (Status & Voice Sync Only - NO AI TEXT DISPLAYED) ──────────
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

  es.addEventListener('token', () => {
    if (!isStreaming) updateStreamingUI(true);
  });

  es.addEventListener('end', () => {
    updateStreamingUI(false);
  });

  es.addEventListener('clear', () => {
    updateStreamingUI(false);
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
      inp.style.height = Math.min(inp.scrollHeight, 130) + 'px';
    }
  });

  es.addEventListener('transcription', e => {
    if (e.data && e.data.trim()) {
      const combined = micPreText ? (micPreText + ' ' + e.data.trim()) : e.data.trim();
      inp.value = combined;
      inp.style.height = 'auto';
      inp.style.height = Math.min(inp.scrollHeight, 130) + 'px';
    }
    micPreText = '';
  });
}
connectSSE();
</script>
</body>
</html>
"""
}

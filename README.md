# Hackathon czesc
# Karol czerner sygnalisci
<!DOCTYPE html>
<html lang="pl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Hackathon event landing page with many improved mini games">
    <title>Hackathon Challenge — Mini gry (rozszerzone)</title>
    <style>
        :root {
            --bg: radial-gradient(1200px 600px at 10% 10%, rgba(124,58,237,0.12), transparent), linear-gradient(180deg, #071021 0%, #071428 100%);
            --panel: linear-gradient(180deg, rgba(255,255,255,0.02), rgba(255,255,255,0.01));
            --primary: #06b6d4;
            --accent: #7c3aed;
            --text: #e6eef8;
            --muted: #9aa8bf;
            --card: linear-gradient(180deg,#071428,#0d1b2a);
            --glass: rgba(255,255,255,0.03);
            --success: #10b981;
            --danger: #ef4444;
            --shadow: 0 10px 40px rgba(2,6,23,0.6);
        }

        body.theme-light {
            --bg: linear-gradient(180deg, #f8fafc 0%, #eef2ff 100%);
            --panel: linear-gradient(180deg,#ffffff,#f3f4f6);
            --primary: #0891b2;
            --accent: #7c3aed;
            --text: #0f172a;
            --muted: #475569;
            --card: linear-gradient(180deg,#ffffff,#f1f5f9);
            --glass: rgba(15,23,42,0.03);
            --success: #059669;
            --danger: #dc2626;
            --shadow: 0 12px 34px rgba(15,23,42,0.12);
        }

        * { box-sizing: border-box; }
        html, body { height: 100%; margin: 0; }
        body {
            font-family: Inter, Arial, sans-serif;
            background: var(--bg);
            color: var(--text);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            gap: 1rem;
            padding-bottom: 2rem;
            transition: background 300ms ease, color 250ms ease;
        }

        header { text-align: center; padding: 1.25rem 1rem; }
        header h1 { margin: 0; font-size: clamp(1.6rem, 3.4vw, 2.6rem); }
        header p { margin: .2rem 0 0; color: var(--muted); }

        .layout { width: min(1200px, calc(100% - 2rem)); margin: 0 auto; display: grid; grid-template-columns: 300px 1fr; gap: 1rem; }

        .panel { background: var(--panel); border-radius: 14px; padding: 1rem; box-shadow: var(--shadow); border: 1px solid rgba(255,255,255,0.02); }

        .games-list { display:flex; flex-direction:column; gap:0.6rem; max-height:70vh; overflow:auto; }
        .game-item { display:flex; align-items:center; gap:0.6rem; padding:0.7rem; border-radius:10px; cursor:pointer; background:var(--glass); border:1px solid rgba(255,255,255,0.02); transition: transform 120ms ease, box-shadow 120ms ease; }
        .game-item:hover { transform: translateY(-2px); }
        .game-item.active { outline: 2px solid rgba(6,182,212,0.12); box-shadow: 0 8px 20px rgba(6,182,212,0.06); }

        .game-header { display:flex; align-items:center; gap:1rem; justify-content:space-between; margin-bottom:0.8rem; }
        .scoreboard { font-weight:700; color:var(--text); }
        .controls { display:flex; gap:0.6rem; }
        button { background:var(--primary); color:#021220; border:none; padding:0.6rem 0.9rem; border-radius:10px; cursor:pointer; font-weight:700; }
        button.secondary { background:transparent; color:var(--text); border:1px solid rgba(255,255,255,0.04); }
        button.ghost { background:transparent; border:1px solid rgba(255,255,255,0.04); color:var(--muted); }

        .game-stage { min-height:520px; border-radius:12px; padding:1rem; position:relative; display:flex; align-items:center; justify-content:center; }
        .state-message { color:var(--muted); font-size:1.05rem; text-align:center; }

        .mini-board { width:100%; min-height:420px; border-radius:12px; padding:1rem; background: linear-gradient(180deg, rgba(255,255,255,0.01), rgba(255,255,255,0.02)); border:1px solid rgba(255,255,255,0.02); }
        .center { display:flex; align-items:center; justify-content:center; }

        .target { position:absolute; width:56px; height:56px; border-radius:12px; background: linear-gradient(135deg,#34d399,#059669); box-shadow:0 8px 26px rgba(6,182,212,0.08); cursor:pointer; }
        .holes { display:grid; grid-template-columns:repeat(3,92px); gap:12px; justify-content:center; }
        .hole { width:92px; height:92px; border-radius:12px; display:flex; align-items:center; justify-content:center; background:rgba(255,255,255,0.02); border:1px solid rgba(255,255,255,0.02); }
        .mole { width:70px; height:70px; border-radius:50%; background:radial-gradient(circle at 30% 30%, #fbbf24,#f59e0b,#d97706); cursor:pointer; }

        .pad { width:108px; height:108px; border-radius:12px; box-shadow: inset 0 -6px 0 rgba(0,0,0,0.15); cursor:pointer; }
        .pad.red { background:#ef4444 }
        .pad.yellow { background:#f59e0b }
        .pad.green { background:#10b981 }
        .pad.blue { background:#3b82f6 }

        .balloon { position:absolute; bottom:20px; left:50%; transform:translateX(-50%); width:90px; height:110px; border-radius:50%/60%; background:linear-gradient(180deg,#fb7185,#f43f5e); display:flex; align-items:center; justify-content:center; color:#fff; font-weight:800; cursor:pointer; }

        .dodger-area { position:relative; width:100%; height:360px; overflow:hidden; border-radius:12px; }
        .player { position:absolute; width:72px; height:26px; bottom:16px; border-radius:8px; background:linear-gradient(180deg,#06b6d4,#0ea5a4); }
        .fall { position:absolute; width:26px; height:26px; border-radius:6px; background:linear-gradient(180deg,#fb923c,#f97316); }

        .choices { display:flex; gap:8px; flex-wrap:wrap; justify-content:center; }
        .color-btn { width:70px; height:70px; border-radius:12px; border:3px solid transparent; cursor:pointer; }

        .number-grid { display:grid; grid-template-columns:repeat(3,86px); gap:12px; justify-content:center; }
        .number-item { width:86px; height:86px; border-radius:12px; background:rgba(255,255,255,0.02); display:flex; align-items:center; justify-content:center; font-weight:800; cursor:pointer; }

        .blackjack { display:flex; flex-direction:column; gap:12px; align-items:center; }
        .cards { display:flex; gap:8px; }
        .card { width:60px; height:86px; border-radius:8px; background:linear-gradient(180deg,#fff,#f2f2f2); color:#021220; display:flex; align-items:center; justify-content:center; font-weight:800; border:1px solid rgba(0,0,0,0.08); }
        .controls-inline { display:flex; gap:8px; }
        .small { font-size:0.85rem; color:var(--muted); }

        @media (max-width: 920px) {
            .layout { grid-template-columns: 1fr; }
            .game-stage { min-height: 520px; }
        }
    </style>
</head>
<body>
    <header>
        <h1>Hackathon — Mini gry (rozszerzone)</h1>
        <p>Dodano nowe gry, poprawiony motyw, Blackjack z licznikiem punktów i ulepszone mechaniki.</p>
    </header>

    <div class="layout">
        <aside class="panel">
            <h3>Wybór gry</h3>
            <div style="margin-bottom:0.6rem;display:flex;gap:0.5rem;flex-wrap:wrap;">
                <button id="toggleSound" class="secondary">Dźwięk: ON</button>
                <button id="toggleTheme" class="ghost">Motyw: Dark</button>
            </div>
            <div class="games-list" id="gamesList"></div>
            <hr style="border:none;border-top:1px solid rgba(255,255,255,0.02);margin-top:0.8rem;margin-bottom:0.6rem;">
            <div style="color:var(--muted);font-size:0.9rem">High scores (local): <div id="highScores" style="margin-top:0.4rem;color:var(--muted)"></div></div>
        </aside>

        <main class="panel">
            <div class="game-header">
                <div>
                    <div class="scoreboard">Score: <span id="score">0</span></div>
                    <div style="color:var(--muted);font-size:0.9rem">Gra: <span id="currentGameName">-</span></div>
                </div>
                <div class="controls">
                    <button id="startBtn">Start</button>
                    <button id="stopBtn" class="secondary" disabled>Stop</button>
                    <button id="resetBtn" class="ghost">Reset</button>
                </div>
            </div>

            <div class="game-stage panel" id="gameStage">
                <div class="state-message">Wybierz grę po lewej, następnie kliknij Start</div>
            </div>
        </main>
    </div>

    <script>
        const games = [
            { id: 'clickTarget', name: 'Click Target', desc: 'Klikaj ruchomy cel' },
            { id: 'rapidClick', name: 'Rapid Click', desc: 'Klikaj jak najwięcej' },
            { id: 'reaction', name: 'Reaction Test', desc: 'Test reakcji' },
            { id: 'whack', name: 'Whack-a-Mole', desc: 'Uderz kreta' },
            { id: 'math', name: 'Math Quiz', desc: 'Szybkie działania' },
            { id: 'simon', name: 'Simon Memory', desc: 'Powtarzaj sekwencję' },
            { id: 'balloon', name: 'Balloon Pop', desc: 'Przebij balon' },
            { id: 'colorMatch', name: 'Color Match', desc: 'Dopasuj kolor' },
            { id: 'numberFind', name: 'Find Numbers', desc: 'Klikaj liczby w kolejności' },
            { id: 'dodger', name: 'Dodger', desc: 'Omijaj obiekty' },
            { id: 'blackjack', name: 'Blackjack', desc: 'Zagraj przeciwko krupierowi' },
            { id: 'slots', name: 'Slots', desc: 'Prosty automat' },
            { id: 'hangman', name: 'Hangman', desc: 'Zgadnij słowo' },
            { id: 'typing', name: 'Typing Test', desc: 'Szybkie pisanie' },
            { id: 'higherLower', name: 'Higher or Lower', desc: 'Zgadnij większą liczbę' },
            { id: 'memoryPairs', name: 'Memory Pairs', desc: 'Znajdź pary kart' },
            { id: 'luckySpin', name: 'Lucky Spin', desc: 'Kręć tryb wygranej' },
            { id: 'fruitCatcher', name: 'Fruit Catcher', desc: 'Złap spadające owoce' }
        ];

        const gamesList = document.getElementById('gamesList');
        const gameStage = document.getElementById('gameStage');
        const scoreEl = document.getElementById('score');
        const startBtn = document.getElementById('startBtn');
        const stopBtn = document.getElementById('stopBtn');
        const resetBtn = document.getElementById('resetBtn');
        const currentGameName = document.getElementById('currentGameName');
        const highScoresEl = document.getElementById('highScores');
        const toggleSoundBtn = document.getElementById('toggleSound');
        const toggleThemeBtn = document.getElementById('toggleTheme');

        let currentGame = localStorage.getItem('hackathon.currentGame') || 'clickTarget';
        let gameRunning = false;
        let score = 0;
        let timer = null;
        let timeLeft = 0;
        let cleanupFns = [];
        let soundOn = localStorage.getItem('hackathon.soundOn') !== 'false';
        let darkTheme = localStorage.getItem('hackathon.darkTheme') !== 'false';

        function registerCleanup(fn) { cleanupFns.push(fn); }
        function runCleanup() { cleanupFns.forEach(fn => { try { fn(); } catch (e) {} }); cleanupFns = []; }
        function updateScore() { scoreEl.textContent = score; }
        function updateGameName() { const g = games.find(x => x.id === currentGame); currentGameName.textContent = g ? g.name : '-'; }
        function clearGlobalTimer() { if (timer) { clearInterval(timer); timer = null; } }
        function setTime(s) { timeLeft = s; renderTime(); }
        function renderTime() { const el = document.getElementById('timeDisplay'); if (el) el.textContent = timeLeft + 's'; }

        function playSound(id) { if (!soundOn) return; if (!id) return; try { const audio = new Audio(id); audio.play(); } catch (e) {} }

        function saveHighScore(gameId, value) {
            try {
                const key = 'hackathon.high.' + gameId;
                const prev = Number(localStorage.getItem(key) || 0);
                if (value > prev) {
                    localStorage.setItem(key, String(value));
                }
            } catch (e) {}
            renderHighScores();
        }

        function renderHighScores() {
            highScoresEl.innerHTML = '';
            games.forEach(g => {
                const v = Number(localStorage.getItem('hackathon.high.' + g.id) || 0);
                const row = document.createElement('div');
                row.textContent = `${g.name}: ${v}`;
                highScoresEl.appendChild(row);
            });
        }

        function renderGames() {
            gamesList.innerHTML = '';
            games.forEach(g => {
                const el = document.createElement('div');
                el.className = 'game-item' + (g.id === currentGame ? ' active' : '');
                el.innerHTML = `<div style="flex:1"><div style="font-weight:800">${g.name}</div><div class="small">${g.desc}</div></div>`;
                el.addEventListener('click', () => selectGame(g.id));
                gamesList.appendChild(el);
            });
        }

        function selectGame(id) {
            if (gameRunning) stopGame();
            currentGame = id;
            localStorage.setItem('hackathon.currentGame', id);
            renderGames();
            updateGameName();
            setGameMessage('Wybrano: ' + (games.find(x => x.id === currentGame) || {}).name);
        }

        function setGameMessage(text) {
            runCleanup();
            gameStage.innerHTML = `<div class="state-message">${text}</div>`;
        }

        function resetKeepSelection() {
            runCleanup();
            clearGlobalTimer();
            gameRunning = false;
            score = 0;
            updateScore();
            setTime(0);
            setGameMessage('Resetowane (gra pozostaje): ' + (games.find(x => x.id === currentGame) || {}).name);
            startBtn.disabled = false;
            stopBtn.disabled = true;
        }

        function stopGame() {
            if (!gameRunning) return;
            runCleanup();
            gameRunning = false;
            clearGlobalTimer();
            startBtn.disabled = false;
            stopBtn.disabled = true;
            setGameMessage('Gra zatrzymana. Wynik: ' + score);
        }

        function startClickTarget() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board" id="targetBoard"></div>';
            const board = document.getElementById('targetBoard');
            const target = document.createElement('div');
            target.className = 'target';
            target.textContent = '●';
            board.appendChild(target);

            function moveTarget() {
                const w = board.clientWidth - 56;
                const h = board.clientHeight - 56;
                target.style.left = (Math.random() * w) + 'px';
                target.style.top = (Math.random() * h) + 'px';
            }

            const moveIv = setInterval(() => { if (gameRunning) moveTarget(); }, 900);
            target.addEventListener('click', () => {
                if (!gameRunning) return;
                score += 1;
                updateScore();
                moveTarget();
            });
            registerCleanup(() => { clearInterval(moveIv); target.remove(); });
            startCountdown(20);
            moveTarget();
        }

        function startRapidClick() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board center"><button id="rapidBtn" style="padding:1rem 1.6rem;font-size:1.4rem;border-radius:12px;background:var(--accent);color:white;border:none">Klik!</button></div>';
            const btn = document.getElementById('rapidBtn');
            btn.addEventListener('click', () => {
                if (!gameRunning) return;
                score += 1;
                updateScore();
            });
            registerCleanup(() => btn.remove());
            startCountdown(10);
        }

        function startReaction() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board center"><div id="reactMsg" style="font-size:1.4rem;color:var(--muted)">Czekaj na zielone...</div></div>';
            const msg = document.getElementById('reactMsg');
            let ready = false;
            let startDelay = setTimeout(() => {
                msg.textContent = 'Kliknij teraz!';
                msg.style.color = 'var(--success)';
                ready = true;
            }, 1200 + Math.random() * 1800);

            function onStageClick() {
                if (!gameRunning) return;
                if (!ready) {
                    msg.textContent = 'Za wcześnie!';
                    msg.style.color = 'var(--danger)';
                    return;
                }
                score += 1;
                updateScore();
                msg.textContent = 'Dobrze!';
                msg.style.color = 'var(--success)';
                endRound('Reakcja OK!');
            }

            gameStage.addEventListener('click', onStageClick);
            registerCleanup(() => { clearTimeout(startDelay); gameStage.removeEventListener('click', onStageClick); });
            startCountdown(8);
        }

        function startWhack() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board"><div class="holes" id="holesGrid"></div></div>';
            const grid = document.getElementById('holesGrid');
            const holes = [];
            for (let i = 0; i < 9; i++) {
                const hole = document.createElement('div');
                hole.className = 'hole';
                grid.appendChild(hole);
                holes.push(hole);
            }

            let moleIv = setInterval(() => {
                if (!gameRunning) return;
                holes.forEach(h => h.innerHTML = '');
                const idx = Math.floor(Math.random() * holes.length);
                const mole = document.createElement('div');
                mole.className = 'mole';
                mole.addEventListener('click', () => {
                    if (!gameRunning) return;
                    score += 1;
                    updateScore();
                    mole.remove();
                });
                holes[idx].appendChild(mole);
            }, 700);
            registerCleanup(() => { clearInterval(moleIv); holes.forEach(h => h.innerHTML = ''); });
            startCountdown(20);
        }

        function startMath() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board center"><div style="max-width:420px;text-align:center"><div id="mathQ" style="font-size:1.3rem;font-weight:800"></div><input id="mathInput" type="number" style="margin-top:8px;padding:8px;border-radius:8px;border:1px solid rgba(255,255,255,0.04);width:100%"><div style="margin-top:8px"><button id="mathOk">OK</button></div></div></div>';
            const qEl = document.getElementById('mathQ');
            const inp = document.getElementById('mathInput');
            const ok = document.getElementById('mathOk');
            let correct = 0;
            function nextQ() {
                const a = Math.floor(Math.random() * 12) + 1;
                const b = Math.floor(Math.random() * 12) + 1;
                correct = a + b;
                qEl.textContent = `${a} + ${b} = ?`;
                inp.value = '';
                inp.focus();
            }
            ok.addEventListener('click', () => {
                if (!gameRunning) return;
                if (Number(inp.value) === correct) {
                    score += 1;
                    updateScore();
                    nextQ();
                } else {
                    nextQ();
                }
            });
            registerCleanup(() => ok.remove());
            startCountdown(35);
            nextQ();
        }

        function startSimon() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board"><div class="choices" id="simonPads"></div></div>';
            const padContainer = document.getElementById('simonPads');
            const colors = ['red', 'green', 'blue', 'yellow'];
            const pads = colors.map(color => {
                const p = document.createElement('div');
                p.className = 'color-btn';
                p.dataset.color = color;
                p.style.background = color;
                p.style.width = '90px';
                p.style.height = '90px';
                p.style.border = '3px solid rgba(255,255,255,0.06)';
                padContainer.appendChild(p);
                return p;
            });
            let seq = [];
            let idx = 0;
            let playingSeq = false;

            function flash(color) {
                const p = pads.find(x => x.dataset.color === color);
                if (!p) return;
                p.style.transform = 'scale(1.08)';
                setTimeout(() => p.style.transform = '', 180);
            }

            function playSeq() {
                playingSeq = true;
                seq.forEach((c, i) => setTimeout(() => flash(c), (i + 1) * 600));
                setTimeout(() => playingSeq = false, seq.length * 650);
            }

            function addStep() {
                seq.push(colors[Math.floor(Math.random() * colors.length)]);
                idx = 0;
                playSeq();
            }

            pads.forEach(p => {
                p.addEventListener('click', () => {
                    if (!gameRunning || playingSeq) return;
                    const c = p.dataset.color;
                    flash(c);
                    if (c !== seq[idx]) {
                        endRound('Błąd!');
                        return;
                    }
                    idx += 1;
                    if (idx >= seq.length) {
                        score += 1;
                        updateScore();
                        addStep();
                    }
                });
            });
            addStep();
            startCountdown(45);
            registerCleanup(() => pads.forEach(p => p.remove()));
        }

        function startBalloon() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board" id="balloonBoard"></div>';
            const board = document.getElementById('balloonBoard');
            const balloon = document.createElement('div');
            balloon.className = 'balloon';
            balloon.textContent = 'POP';
            board.appendChild(balloon);

            balloon.addEventListener('click', () => {
                if (!gameRunning) return;
                score += 3;
                updateScore();
                balloon.style.transform = 'scale(0.2)';
                balloon.style.opacity = '0';
                setTimeout(() => balloon.remove(), 220);
            });
            registerCleanup(() => balloon.remove());
            startCountdown(20);
        }

        function startColorMatch() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board center"><div><div id="colorText" style="font-weight:800;font-size:1.4rem;margin-bottom:8px"></div><div class="choices" id="colorChoices"></div></div></div>';
            const colorText = document.getElementById('colorText');
            const choices = document.getElementById('colorChoices');
            const colors = ['red', 'green', 'blue', 'yellow'];
            let correct = '';

            function round() {
                const label = colors[Math.floor(Math.random() * colors.length)];
                correct = label;
                colorText.textContent = label.toUpperCase();
                choices.innerHTML = '';
                const options = [...colors].sort(() => Math.random() - 0.5);
                options.forEach(color => {
                    const btn = document.createElement('div');
                    btn.className = 'color-btn';
                    btn.style.background = color;
                    btn.style.width = '70px';
                    btn.style.height = '70px';
                    btn.addEventListener('click', () => {
                        if (!gameRunning) return;
                        if (color === correct) {
                            score += 1;
                            updateScore();
                        }
                        round();
                    });
                    choices.appendChild(btn);
                });
            }

            round();
            startCountdown(25);
        }

        function startNumberFind() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board"><div class="number-grid" id="numGrid"></div></div>';
            const grid = document.getElementById('numGrid');
            const values = Array.from({ length: 9 }, (_, i) => i + 1).sort(() => Math.random() - 0.5);
            values.forEach(n => {
                const cell = document.createElement('div');
                cell.className = 'number-item';
                cell.textContent = n;
                cell.addEventListener('click', () => {
                    if (!gameRunning) return;
                    if (n === 1) {
                        score += 1;
                        updateScore();
                    }
                });
                grid.appendChild(cell);
            });
            startCountdown(30);
        }

        function startDodger() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board"><div class="dodger-area" id="dodgerArea" tabindex="0"></div></div>';
            const area = document.getElementById('dodgerArea');
            const player = document.createElement('div');
            player.className = 'player';
            area.appendChild(player);
            let px = (area.clientWidth - 72) / 2;
            player.style.left = px + 'px';
            const falls = [];

            function keyHandler(e) {
                if (!gameRunning) return;
                if (e.key === 'ArrowLeft') px = Math.max(0, px - 30);
                if (e.key === 'ArrowRight') px = Math.min(area.clientWidth - 72, px + 30);
                player.style.left = px + 'px';
            }
            area.addEventListener('keydown', keyHandler);
            area.focus();

            const spawnIv = setInterval(() => {
                if (!gameRunning) return;
                const f = document.createElement('div');
                f.className = 'fall';
                f.style.left = (Math.random() * (area.clientWidth - 26)) + 'px';
                f.style.top = '-26px';
                area.appendChild(f);
                falls.push(f);
            }, 700);

            const stepIv = setInterval(() => {
                if (!gameRunning) return;
                for (let i = falls.length - 1; i >= 0; i--) {
                    const f = falls[i];
                    const top = parseFloat(f.style.top || '0') + 6;
                    f.style.top = top + 'px';
                    const left = parseFloat(f.style.left || '0');
                    if (top > area.clientHeight - 26 && left > px - 20 && left < px + 72) {
                        endRound('Trafiony!');
                        return;
                    }
                    if (top > area.clientHeight + 20) {
                        f.remove();
                        falls.splice(i, 1);
                    }
                }
            }, 50);

            registerCleanup(() => {
                clearInterval(spawnIv);
                clearInterval(stepIv);
                area.removeEventListener('keydown', keyHandler);
                falls.forEach(x => x.remove());
                player.remove();
            });
            startCountdown(35);
        }

        function startBlackjack() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board center blackjack" id="bjBoard"><div style="width:100%;display:flex;justify-content:space-between"><div><div style="font-weight:800">Dealer</div><div class="cards" id="dealerCards"></div><div class="small" id="dealerVal"></div></div><div><div style="font-weight:800">Player</div><div class="cards" id="playerCards"></div><div class="small" id="playerVal"></div></div></div><div id="bjStatus" class="small"></div><div id="bjControls" class="controls-inline" style="margin-top:12px"></div></div>';

            const dealerCardsEl = document.getElementById('dealerCards');
            const playerCardsEl = document.getElementById('playerCards');
            const dealerValEl = document.getElementById('dealerVal');
            const playerValEl = document.getElementById('playerVal');
            const bjStatus = document.getElementById('bjStatus');
            const controls = document.getElementById('bjControls');
            let deck = buildDeck();
            shuffle(deck);
            let playerHand = [];
            let dealerHand = [];

            function drawCard() { return deck.pop(); }
            function cardValue(card) {
                if (['J', 'Q', 'K'].includes(card.rank)) return 10;
                if (card.rank === 'A') return 11;
                return Number(card.rank);
            }
            function handValue(hand) {
                let val = hand.reduce((sum, c) => sum + cardValue(c), 0);
                let aces = hand.filter(c => c.rank === 'A').length;
                while (val > 21 && aces > 0) {
                    val -= 10;
                    aces -= 1;
                }
                return val;
            }

            function renderHands(showDealer = false) {
                dealerCardsEl.innerHTML = '';
                playerCardsEl.innerHTML = '';
                dealerHand.forEach((card, i) => {
                    const el = document.createElement('div');
                    el.className = 'card';
                    el.textContent = (i === 0 && !showDealer) ? '❓' : `${card.rank}${card.suit}`;
                    dealerCardsEl.appendChild(el);
                });
                playerHand.forEach(card => {
                    const el = document.createElement('div');
                    el.className = 'card';
                    el.textContent = `${card.rank}${card.suit}`;
                    playerCardsEl.appendChild(el);
                });
                playerValEl.textContent = 'Player: ' + handValue(playerHand);
                dealerValEl.textContent = showDealer ? 'Dealer: ' + handValue(dealerHand) : 'Dealer: ?';
            }

            function endRoundBJ(msg, result) {
                renderHands(true);
                if (result === 'win') {
                    score += 2;
                    bjStatus.textContent = 'Punkty rundy: +2 (wygrana)';
                } else if (result === 'draw') {
                    bjStatus.textContent = 'Punkty rundy: remis';
                } else {
                    score = Math.max(0, score - 1);
                    bjStatus.textContent = 'Punkty rundy: -1 (przegrana)';
                }
                updateScore();
                setTimeout(() => endRound(msg), 200);
            }

            function startDeal() {
                playerHand.push(drawCard());
                dealerHand.push(drawCard());
                playerHand.push(drawCard());
                dealerHand.push(drawCard());
                renderHands();
            }

            function onHit() {
                playerHand.push(drawCard());
                renderHands();
                if (handValue(playerHand) > 21) {
                    endRoundBJ('Przegrałeś (bust)', 'lose');
                }
            }

            function onStand() {
                while (handValue(dealerHand) < 17) {
                    dealerHand.push(drawCard());
                }
                const pv = handValue(playerHand);
                const dv = handValue(dealerHand);
                if (dv > 21 || pv > dv) {
                    endRoundBJ('Wygrałeś!', 'win');
                } else if (pv === dv) {
                    endRoundBJ('Remis', 'draw');
                } else {
                    endRoundBJ('Przegrałeś', 'lose');
                }
            }

            const hitBtn = document.createElement('button');
            hitBtn.textContent = 'Hit';
            const standBtn = document.createElement('button');
            standBtn.textContent = 'Stand';
            const newBtn = document.createElement('button');
            newBtn.textContent = 'Nowa talia';
            controls.appendChild(hitBtn);
            controls.appendChild(standBtn);
            controls.appendChild(newBtn);

            hitBtn.addEventListener('click', () => { if (gameRunning) onHit(); });
            standBtn.addEventListener('click', () => { if (gameRunning) onStand(); });
            newBtn.addEventListener('click', () => {
                if (!gameRunning) return;
                deck = buildDeck();
                shuffle(deck);
                playerHand = [];
                dealerHand = [];
                startDeal();
            });

            registerCleanup(() => {
                hitBtn.remove();
                standBtn.remove();
                newBtn.remove();
            });

            deck = buildDeck();
            shuffle(deck);
            playerHand = [];
            dealerHand = [];
            startDeal();
            startCountdown(60);
            bjStatus.textContent = 'Licznik punktów: ' + score;

            function buildDeck() {
                const suits = ['♠', '♥', '♦', '♣'];
                const ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];
                const d = [];
                suits.forEach(suit => ranks.forEach(rank => d.push({ suit, rank })));
                return d;
            }

            function shuffle(array) {
                for (let i = array.length - 1; i > 0; i--) {
                    const j = Math.floor(Math.random() * (i + 1));
                    [array[i], array[j]] = [array[j], array[i]];
                }
            }
        }

        function startSlots() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board center"><div id="slotReel" style="display:flex;gap:12px;font-size:2.2rem"></div><div style="margin-top:12px"><button id="spinBtn">Spin</button></div></div>';
            const reel = document.getElementById('slotReel');
            const spinBtn = document.getElementById('spinBtn');
            function spinOnce() {
                reel.innerHTML = '';
                const icons = ['🍒', '🍋', '🔔', '⭐', '7'];
                const result = [];
                for (let i = 0; i < 3; i++) {
                    const icon = icons[Math.floor(Math.random() * icons.length)];
                    result.push(icon);
                    const el = document.createElement('div');
                    el.textContent = icon;
                    reel.appendChild(el);
                }
                if (result[0] === result[1] && result[1] === result[2]) {
                    score += 5;
                    updateScore();
                }
            }
            spinBtn.addEventListener('click', () => { if (gameRunning) spinOnce(); });
            registerCleanup(() => spinBtn.remove());
            startCountdown(30);
        }

        function startHangman() {
            runCleanup();
            const words = ['JAVASCRIPT', 'HACKATHON', 'KOMPILATOR', 'GIT', 'HTML'];
            const word = words[Math.floor(Math.random() * words.length)];
            let guessed = new Set();
            let lives = 6;
            gameStage.innerHTML = '<div class="mini-board center"><div style="text-align:center"><div id="hangWord" style="font-size:1.4rem;letter-spacing:6px"></div><div id="hangLives" style="margin-top:8px;color:var(--muted)"></div><div id="hangLetters" style="margin-top:12px"></div></div></div>';
            const hangWord = document.getElementById('hangWord');
            const hangLives = document.getElementById('hangLives');
            const hangLetters = document.getElementById('hangLetters');

            function render() {
                hangWord.textContent = word.split('').map(ch => guessed.has(ch) ? ch : '_').join(' ');
                hangLives.textContent = 'Życia: ' + lives;
                hangLetters.innerHTML = '';
                'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('').forEach(ch => {
                    const btn = document.createElement('button');
                    btn.textContent = ch;
                    btn.style.margin = '2px';
                    btn.disabled = guessed.has(ch) || !gameRunning;
                    btn.addEventListener('click', () => {
                        if (!gameRunning) return;
                        if (word.includes(ch)) {
                            guessed.add(ch);
                            if (!hangWord.textContent.includes('_')) {
                                score += 3;
                                updateScore();
                                endRound('Wygrałeś!');
                                return;
                            }
                        } else {
                            lives -= 1;
                            if (lives <= 0) {
                                endRound('Przegrałeś!');
                                return;
                            }
                        }
                        render();
                    });
                    hangLetters.appendChild(btn);
                });
            }
            render();
            startCountdown(45);
        }

        function startTyping() {
            runCleanup();
            const sample = 'Szybkie programowanie na hackathonie to frajda.';
            gameStage.innerHTML = '<div class="mini-board center"><div style="max-width:700px;text-align:left"><div style="font-weight:800;margin-bottom:8px">Przepisz ten tekst:</div><div style="margin-bottom:8px">' + sample + '</div><textarea id="typeArea" style="width:100%;height:120px;border-radius:8px;padding:8px"></textarea><div style="margin-top:8px"><button id="typeOk">Sprawdź</button></div></div></div>';
            const ta = document.getElementById('typeArea');
            const ok = document.getElementById('typeOk');
            ok.addEventListener('click', () => {
                if (!gameRunning) return;
                if (ta.value.trim() === sample) {
                    score += 5;
                    updateScore();
                    endRound('Świetnie!');
                } else {
                    endRound('Błędny tekst!');
                }
            });
            startCountdown(40);
            registerCleanup(() => ok.remove());
        }

        function startHigherLower() {
            runCleanup();
            let current = Math.floor(Math.random() * 100) + 1;
            gameStage.innerHTML = '<div class="mini-board center"><div style="font-size:2rem;font-weight:800" id="curNum">' + current + '</div><div class="controls-inline" style="margin-top:12px"><button id="higherBtn">Wyżej</button><button id="lowerBtn">Niżej</button></div></div>';
            const curEl = document.getElementById('curNum');
            const higherBtn = document.getElementById('higherBtn');
            const lowerBtn = document.getElementById('lowerBtn');

            function nextRound(choice) {
                const next = Math.floor(Math.random() * 100) + 1;
                const correct = (choice === 'higher' && next > current) || (choice === 'lower' && next < current);
                current = next;
                curEl.textContent = current;
                if (correct) {
                    score += 1;
                    updateScore();
                }
            }

            higherBtn.addEventListener('click', () => { if (gameRunning) nextRound('higher'); });
            lowerBtn.addEventListener('click', () => { if (gameRunning) nextRound('lower'); });
            registerCleanup(() => { higherBtn.remove(); lowerBtn.remove(); });
            startCountdown(25);
        }

        function startMemoryPairs() {
            runCleanup();
            const icons = ['🍎', '🍌', '🍇', '🍉', '🍓', '🍒'];
            const deck = [...icons, ...icons].sort(() => Math.random() - 0.5);
            gameStage.innerHTML = '<div class="mini-board"><div style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px" id="memoryGrid"></div></div>';
            const grid = document.getElementById('memoryGrid');
            let first = null;

            deck.forEach(icon => {
                const btn = document.createElement('div');
                btn.className = 'number-item';
                btn.textContent = '?';
                btn.addEventListener('click', () => {
                    if (!gameRunning) return;
                    btn.textContent = icon;
                    if (!first) {
                        first = { btn, icon };
                        return;
                    }
                    if (first.icon === icon) {
                        score += 1;
                        updateScore();
                        first = null;
                    } else {
                        const prev = first.btn;
                        setTimeout(() => {
                            btn.textContent = '?';
                            prev.textContent = '?';
                            first = null;
                        }, 500);
                    }
                });
                grid.appendChild(btn);
            });
            startCountdown(50);
        }

        function startLuckySpin() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board center"><div style="font-size:2rem" id="spinVal">?</div><div style="margin-top:12px"><button id="doSpin">Spin</button></div></div>';
            const val = document.getElementById('spinVal');
            const btn = document.getElementById('doSpin');
            btn.addEventListener('click', () => {
                if (!gameRunning) return;
                const n = Math.floor(Math.random() * 100) + 1;
                val.textContent = n;
                if (n > 90) {
                    score += 10;
                    updateScore();
                }
            });
            registerCleanup(() => btn.remove());
            startCountdown(20);
        }

        function startFruitCatcher() {
            runCleanup();
            gameStage.innerHTML = '<div class="mini-board"><div class="dodger-area" id="fruitArea" tabindex="0"></div></div>';
            const area = document.getElementById('fruitArea');
            const basket = document.createElement('div');
            basket.className = 'player';
            basket.style.width = '72px';
            basket.style.height = '26px';
            basket.style.left = 'calc(50% - 36px)';
            area.appendChild(basket);
            let bx = (area.clientWidth - 72) / 2;
            basket.style.left = bx + 'px';
            const fruits = [];

            function keyHandler(e) {
                if (!gameRunning) return;
                if (e.key === 'ArrowLeft') bx = Math.max(0, bx - 30);
                if (e.key === 'ArrowRight') bx = Math.min(area.clientWidth - 72, bx + 30);
                basket.style.left = bx + 'px';
            }
            area.addEventListener('keydown', keyHandler);
            area.focus();

            const spawnIv = setInterval(() => {
                if (!gameRunning) return;
                const fruit = document.createElement('div');
                fruit.className = 'fall';
                fruit.style.left = (Math.random() * (area.clientWidth - 26)) + 'px';
                fruit.style.top = '-26px';
                fruit.style.background = 'linear-gradient(180deg,#fbbf24,#f59e0b)';
                area.appendChild(fruit);
                fruits.push(fruit);
            }, 600);

            const stepIv = setInterval(() => {
                if (!gameRunning) return;
                for (let i = fruits.length - 1; i >= 0; i--) {
                    const f = fruits[i];
                    const top = parseFloat(f.style.top || '0') + 6;
                    f.style.top = top + 'px';
                    const left = parseFloat(f.style.left || '0');
                    if (top > area.clientHeight - 26 && left > bx - 20 && left < bx + 72) {
                        score += 1;
                        updateScore();
                        f.remove();
                        fruits.splice(i, 1);
                    } else if (top > area.clientHeight + 20) {
                        f.remove();
                        fruits.splice(i, 1);
                    }
                }
            }, 60);

            registerCleanup(() => {
                clearInterval(spawnIv);
                clearInterval(stepIv);
                area.removeEventListener('keydown', keyHandler);
                fruits.forEach(f => f.remove());
                basket.remove();
            });
            startCountdown(30);
        }

        function startCountdown(seconds) {
            clearGlobalTimer();
            setTime(seconds);
            gameRunning = true;
            startBtn.disabled = true;
            stopBtn.disabled = false;
            timer = setInterval(() => {
                if (!gameRunning) return;
                timeLeft -= 1;
                renderTime();
                if (timeLeft <= 0) {
                    clearInterval(timer);
                    timer = null;
                    endRound('Czas minął!');
                }
            }, 1000);
            registerCleanup(() => { clearInterval(timer); timer = null; });
        }

        function endRound(msg) {
            saveHighScore(currentGame, score);
            runCleanup();
            clearGlobalTimer();
            gameRunning = false;
            startBtn.disabled = false;
            stopBtn.disabled = true;
            setGameMessage(msg + ' Wynik: ' + score);
        }

        function startGame() {
            if (gameRunning) return;
            score = 0;
            updateScore();
            updateGameName();
            switch (currentGame) {
                case 'clickTarget': startClickTarget(); break;
                case 'rapidClick': startRapidClick(); break;
                case 'reaction': startReaction(); break;
                case 'whack': startWhack(); break;
                case 'math': startMath(); break;
                case 'simon': startSimon(); break;
                case 'balloon': startBalloon(); break;
                case 'colorMatch': startColorMatch(); break;
                case 'numberFind': startNumberFind(); break;
                case 'dodger': startDodger(); break;
                case 'blackjack': startBlackjack(); break;
                case 'slots': startSlots(); break;
                case 'hangman': startHangman(); break;
                case 'typing': startTyping(); break;
                case 'higherLower': startHigherLower(); break;
                case 'memoryPairs': startMemoryPairs(); break;
                case 'luckySpin': startLuckySpin(); break;
                case 'fruitCatcher': startFruitCatcher(); break;
                default: setGameMessage('Brak gry');
            }
        }

        function applyTheme() {
            document.body.classList.toggle('theme-light', !darkTheme);
            toggleThemeBtn.textContent = darkTheme ? 'Motyw: Dark' : 'Motyw: Light';
            localStorage.setItem('hackathon.darkTheme', darkTheme ? 'true' : 'false');
        }

        startBtn.addEventListener('click', startGame);
        stopBtn.addEventListener('click', () => stopGame());
        resetBtn.addEventListener('click', resetKeepSelection);

        toggleSoundBtn.addEventListener('click', () => {
            soundOn = !soundOn;
            localStorage.setItem('hackathon.soundOn', soundOn ? 'true' : 'false');
            toggleSoundBtn.textContent = 'Dźwięk: ' + (soundOn ? 'ON' : 'OFF');
        });

        toggleThemeBtn.addEventListener('click', () => {
            darkTheme = !darkTheme;
            applyTheme();
        });

        renderGames();
        updateGameName();
        renderHighScores();
        updateScore();
        toggleSoundBtn.textContent = 'Dźwięk: ' + (soundOn ? 'ON' : 'OFF');
        applyTheme();
    </script>
</body>
</html>

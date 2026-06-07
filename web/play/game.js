(() => {
  'use strict';

  const canvas = document.getElementById('gameCanvas');
  const ctx = canvas.getContext('2d');
  const titleScreen = document.getElementById('titleScreen');
  const startButton = document.getElementById('startButton');
  const hpValue = document.getElementById('hpValue');
  const scoreValue = document.getElementById('scoreValue');
  const objectiveValue = document.getElementById('objectiveValue');
  const stateValue = document.getElementById('stateValue');

  const WIDTH = canvas.width;
  const HEIGHT = canvas.height;
  const FLOOR_Y = 622;
  const GRAVITY = 1750;

  const keys = new Set();
  const mobile = { left: false, right: false, jump: false, attack: false };

  const keyMap = new Map([
    ['ArrowLeft', 'left'], ['KeyA', 'left'],
    ['ArrowRight', 'right'], ['KeyD', 'right'],
    ['ArrowUp', 'jump'], ['KeyW', 'jump'], ['Space', 'jump'],
    ['KeyJ', 'attack'], ['KeyK', 'attack']
  ]);

  const game = {
    state: 'title',
    score: 0,
    message: 'Defeat the Gargomel Scout, then reach the gate.',
    lastTime: 0,
    shake: 0
  };

  const player = {
    x: 165, y: FLOOR_Y - 92, width: 48, height: 92,
    vx: 0, vy: 0, facing: 1, hp: 100,
    grounded: true, attackTimer: 0, attackCooldown: 0, invulnerable: 0
  };

  const enemy = {
    x: 780, y: FLOOR_Y - 72, width: 58, height: 72,
    vx: 80, hp: 3, alive: true, hurtTimer: 0, patrolMin: 700, patrolMax: 990
  };

  const gate = { x: 1120, y: FLOOR_Y - 128, width: 74, height: 128 };
  const platforms = [{ x: 455, y: 500, width: 260, height: 24 }];

  function startGame() {
    Object.assign(game, {
      state: 'playing', score: 0,
      message: 'Defeat the Gargomel Scout, then reach the gate.',
      lastTime: performance.now(), shake: 0
    });
    Object.assign(player, {
      x: 165, y: FLOOR_Y - 92, vx: 0, vy: 0, facing: 1,
      hp: 100, grounded: true, attackTimer: 0, attackCooldown: 0, invulnerable: 0
    });
    Object.assign(enemy, {
      x: 780, y: FLOOR_Y - 72, vx: 80, hp: 3, alive: true, hurtTimer: 0
    });
    titleScreen.classList.add('hidden');
    updateHud();
  }

  function axis() {
    const left = keys.has('left') || mobile.left;
    const right = keys.has('right') || mobile.right;
    return (right ? 1 : 0) - (left ? 1 : 0);
  }

  function pressed(action) {
    return keys.has(action) || mobile[action];
  }

  function rectsOverlap(a, b) {
    return a.x < b.x + b.width && a.x + a.width > b.x && a.y < b.y + b.height && a.y + a.height > b.y;
  }

  function playerRect() {
    return { x: player.x - player.width / 2, y: player.y, width: player.width, height: player.height };
  }

  function enemyRect() {
    return { x: enemy.x - enemy.width / 2, y: enemy.y, width: enemy.width, height: enemy.height };
  }

  function attackRect() {
    return {
      x: player.x + player.facing * 18 + (player.facing > 0 ? 0 : -78),
      y: player.y + 24,
      width: 78,
      height: 42
    };
  }

  function update(dt) {
    if (game.state !== 'playing') return;

    updatePlayer(dt);
    updateEnemy(dt);
    updateCombat(dt);
    checkWinLose();
    game.shake = Math.max(0, game.shake - dt);
    updateHud();
  }

  function updatePlayer(dt) {
    const move = axis();
    const speed = 335;
    const accel = player.grounded ? 2400 : 1450;
    const friction = player.grounded ? 2600 : 650;

    if (move !== 0) {
      player.vx = moveToward(player.vx, move * speed, accel * dt);
      player.facing = move;
    } else {
      player.vx = moveToward(player.vx, 0, friction * dt);
    }

    if (pressed('jump') && player.grounded) {
      player.vy = -660;
      player.grounded = false;
    }

    if (pressed('attack') && player.attackCooldown <= 0) {
      player.attackTimer = 0.18;
      player.attackCooldown = 0.38;
    }

    player.attackTimer = Math.max(0, player.attackTimer - dt);
    player.attackCooldown = Math.max(0, player.attackCooldown - dt);
    player.invulnerable = Math.max(0, player.invulnerable - dt);
    player.vy += GRAVITY * dt;
    player.x += player.vx * dt;
    player.y += player.vy * dt;

    collideWithWorld();
    player.x = Math.max(32, Math.min(WIDTH - 32, player.x));
  }

  function collideWithWorld() {
    player.grounded = false;
    if (player.y + player.height >= FLOOR_Y) {
      player.y = FLOOR_Y - player.height;
      player.vy = 0;
      player.grounded = true;
    }

    for (const platform of platforms) {
      const wasAbove = player.y + player.height - player.vy / 60 <= platform.y;
      const withinX = player.x + player.width / 2 > platform.x && player.x - player.width / 2 < platform.x + platform.width;
      if (withinX && wasAbove && player.y + player.height >= platform.y && player.y + player.height <= platform.y + platform.height + 18) {
        player.y = platform.y - player.height;
        player.vy = 0;
        player.grounded = true;
      }
    }
  }

  function updateEnemy(dt) {
    if (!enemy.alive) return;
    enemy.x += enemy.vx * dt;
    if (enemy.x < enemy.patrolMin || enemy.x > enemy.patrolMax) {
      enemy.vx *= -1;
      enemy.x = Math.max(enemy.patrolMin, Math.min(enemy.patrolMax, enemy.x));
    }
    enemy.hurtTimer = Math.max(0, enemy.hurtTimer - dt);
  }

  function updateCombat(dt) {
    void dt;
    if (enemy.alive && player.attackTimer > 0 && enemy.hurtTimer <= 0 && rectsOverlap(attackRect(), enemyRect())) {
      enemy.hp -= 1;
      enemy.hurtTimer = 0.28;
      game.shake = 0.12;
      game.score += 150;
      game.message = enemy.hp > 0 ? 'Gargomel hit! Keep pressure.' : 'Scout defeated. Reach the outpost gate!';
      if (enemy.hp <= 0) {
        enemy.alive = false;
        game.score += 500;
      }
    }

    if (enemy.alive && player.invulnerable <= 0 && rectsOverlap(playerRect(), enemyRect())) {
      player.hp = Math.max(0, player.hp - 15);
      player.invulnerable = 0.85;
      player.vx = Math.sign(player.x - enemy.x || 1) * 360;
      player.vy = -300;
      game.shake = 0.18;
      game.message = 'The Gargomel clawed your armor!';
    }
  }

  function checkWinLose() {
    if (player.hp <= 0) {
      game.state = 'gameover';
      game.message = 'Game over. Press Start Game to retry.';
      titleScreen.classList.remove('hidden');
      startButton.textContent = 'Retry Game';
    }

    if (!enemy.alive && rectsOverlap(playerRect(), gate)) {
      game.state = 'victory';
      game.score += 1000;
      game.message = 'Victory! Bright Vale gate secured.';
      titleScreen.classList.remove('hidden');
      startButton.textContent = 'Play Again';
    }
  }

  function moveToward(value, target, amount) {
    if (Math.abs(target - value) <= amount) return target;
    return value + Math.sign(target - value) * amount;
  }

  function drawBackground() {
    const gradient = ctx.createLinearGradient(0, 0, WIDTH, HEIGHT);
    gradient.addColorStop(0, '#07091f');
    gradient.addColorStop(0.55, '#151044');
    gradient.addColorStop(1, '#2b0a38');
    ctx.fillStyle = gradient;
    ctx.fillRect(0, 0, WIDTH, HEIGHT);

    ctx.fillStyle = 'rgba(54,245,255,0.12)';
    ctx.beginPath();
    ctx.arc(350, 230, 230, 0, Math.PI * 2);
    ctx.fill();

    mountain('#111b3c', 470, 390, 670, 520, 850, 390, 1040, 535);
    mountain('#091225', 0, 555, 180, 470, 360, 575, 520, 520);
    mountain('#13051f', 820, 555, 1000, 430, 1280, 535, 1280, 720);
  }

  function mountain(color, ...points) {
    ctx.fillStyle = color;
    ctx.beginPath();
    ctx.moveTo(points[0], points[1]);
    for (let i = 2; i < points.length; i += 2) ctx.lineTo(points[i], points[i + 1]);
    ctx.lineTo(WIDTH, HEIGHT);
    ctx.lineTo(0, HEIGHT);
    ctx.closePath();
    ctx.fill();
  }

  function drawPlatforms() {
    ctx.fillStyle = '#102d38';
    ctx.fillRect(0, FLOOR_Y, WIDTH, HEIGHT - FLOOR_Y);
    ctx.fillStyle = '#36f5ff';
    ctx.globalAlpha = 0.35;
    ctx.fillRect(0, FLOOR_Y, WIDTH, 4);
    ctx.globalAlpha = 1;

    for (const platform of platforms) {
      ctx.fillStyle = '#173f46';
      ctx.fillRect(platform.x, platform.y, platform.width, platform.height);
      ctx.fillStyle = '#f6c453';
      ctx.fillRect(platform.x, platform.y, platform.width, 3);
    }
  }

  function drawGate() {
    ctx.fillStyle = '#17071f';
    ctx.fillRect(gate.x, gate.y, gate.width, gate.height);
    ctx.strokeStyle = enemy.alive ? '#ff2bd6' : '#36f5ff';
    ctx.lineWidth = 6;
    ctx.strokeRect(gate.x + 8, gate.y + 8, gate.width - 16, gate.height - 8);
    ctx.fillStyle = enemy.alive ? '#ff2bd6' : '#f6c453';
    ctx.fillRect(gate.x + 31, gate.y + 58, 12, 12);
  }

  function drawPlayer() {
    const alpha = player.invulnerable > 0 && Math.floor(performance.now() / 80) % 2 === 0 ? 0.45 : 1;
    ctx.save();
    ctx.globalAlpha = alpha;
    ctx.translate(player.x, player.y + player.height);
    ctx.scale(player.facing, 1);

    polygon([[-30, -64], [-12, -78], [-8, 4], [-34, 8]], 'rgba(54,245,255,0.32)');
    polygon([[-22, -74], [22, -74], [26, -14], [15, 0], [-15, 0], [-26, -14]], '#2852a6');
    polygon([[-18, -96], [18, -96], [23, -78], [13, -66], [-13, -66], [-23, -78]], '#a7c8ef');
    polygon([[-5, -102], [5, -102], [7, -66], [-7, -66]], '#f6c453');
    polygon([[-44, -58], [-16, -64], [-8, -38], [-17, -12], [-40, -18], [-50, -40]], '#36f5ff');
    polygon([[-36, -51], [-24, -39], [-36, -24], [-47, -39]], '#f6c453');
    polygon([[31, -90], [40, -34], [35, -5], [27, -5], [22, -34]], '#edf8ff');
    polygon([[15, -8], [47, -8], [47, 0], [15, 0]], '#f6c453');

    if (player.attackTimer > 0) {
      ctx.fillStyle = 'rgba(246,196,83,0.55)';
      ctx.beginPath();
      ctx.ellipse(72, -42, 58, 22, -0.2, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.restore();
  }

  function drawEnemy() {
    if (!enemy.alive) return;
    ctx.save();
    ctx.translate(enemy.x, enemy.y + enemy.height);
    ctx.scale(enemy.vx >= 0 ? 1 : -1, 1);
    const body = enemy.hurtTimer > 0 ? '#6e1b86' : '#281034';
    polygon([[-30, -12], [-18, -58], [8, -72], [34, -45], [25, -8]], body);
    polygon([[-24, -54], [-6, -84], [18, -62]], '#3a174a');
    polygon([[14, -42], [46, -30], [20, -22]], '#5a206d');
    ctx.fillStyle = '#ff2bd6';
    ctx.fillRect(-4, -55, 8, 8);
    ctx.fillRect(14, -52, 8, 8);
    ctx.fillStyle = '#f7fbff';
    ctx.font = '700 18px system-ui';
    ctx.fillText(`HP ${enemy.hp}`, -30, -92);
    ctx.restore();
  }

  function drawForeground() {
    ctx.fillStyle = '#05101d';
    for (let x = 0; x < WIDTH; x += 88) {
      ctx.beginPath();
      ctx.moveTo(x, HEIGHT);
      ctx.lineTo(x + 28, FLOOR_Y - 20);
      ctx.lineTo(x + 58, HEIGHT);
      ctx.fill();
    }
  }

  function polygon(points, fillStyle) {
    ctx.fillStyle = fillStyle;
    ctx.beginPath();
    ctx.moveTo(points[0][0], points[0][1]);
    for (let i = 1; i < points.length; i += 1) ctx.lineTo(points[i][0], points[i][1]);
    ctx.closePath();
    ctx.fill();
  }

  function updateHud() {
    hpValue.textContent = String(player.hp);
    scoreValue.textContent = String(game.score);
    objectiveValue.textContent = game.message;
    stateValue.textContent = game.state === 'playing' ? 'Playing' : game.state;
  }

  function loop(time) {
    const dt = Math.min(0.033, (time - game.lastTime) / 1000 || 0);
    game.lastTime = time;
    update(dt);
    drawFrameOnly();
    requestAnimationFrame(loop);
  }

  function drawFrameOnly() {
    ctx.save();
    if (game.shake > 0) ctx.translate((Math.random() - 0.5) * 8, (Math.random() - 0.5) * 5);
    drawBackground();
    drawGate();
    drawPlatforms();
    drawPlayer();
    drawEnemy();
    drawForeground();
    ctx.restore();
  }

  function bindInput() {
    window.addEventListener('keydown', (event) => {
      const action = keyMap.get(event.code);
      if (!action) return;
      event.preventDefault();
      keys.add(action);
    });

    window.addEventListener('keyup', (event) => {
      const action = keyMap.get(event.code);
      if (!action) return;
      event.preventDefault();
      keys.delete(action);
    });

    for (const button of document.querySelectorAll('[data-action]')) {
      const action = button.dataset.action;
      const set = (value) => { mobile[action] = value; };
      button.addEventListener('pointerdown', () => set(true));
      button.addEventListener('pointerup', () => set(false));
      button.addEventListener('pointerleave', () => set(false));
      button.addEventListener('pointercancel', () => set(false));
    }

    startButton.addEventListener('click', startGame);
  }

  bindInput();
  updateHud();
  game.lastTime = performance.now();
  drawFrameOnly();
  requestAnimationFrame(loop);
})();

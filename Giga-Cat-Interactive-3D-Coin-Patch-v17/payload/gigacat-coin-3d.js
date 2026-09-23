(() => {
  'use strict';

  const stage = document.getElementById('gigaCoin3d');
  if (!stage) return;

  const object = stage.querySelector('.giga-coin3d-object');
  if (!object) return;

  const reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  // Build physical depth from many local layers. This keeps the module fully
  // self-contained and avoids an external WebGL/Three.js dependency.
  const layerCount = 15;
  const zMax = 6.4;
  for (let i = 0; i < layerCount; i++) {
    const layer = document.createElement('span');
    layer.className = 'giga-coin3d-edge-layer';
    const t = layerCount === 1 ? 0 : i / (layerCount - 1);
    const z = -zMax + t * zMax * 2;
    const shade = 0.78 + Math.sin(t * Math.PI) * 0.24;
    layer.style.transform = `translateZ(${z.toFixed(2)}px)`;
    layer.style.filter = `brightness(${shade.toFixed(3)})`;
    layer.setAttribute('aria-hidden', 'true');
    object.insertBefore(layer, object.firstChild);
  }

  let rotX = -8;
  let rotY = -18;
  let velocityX = 0;
  let velocityY = 0;
  let dragging = false;
  let pointerId = null;
  let lastX = 0;
  let lastY = 0;
  let lastTime = performance.now();
  let frameTime = performance.now();
  let lastInteraction = performance.now();
  let visible = true;

  const clamp = (n, min, max) => Math.min(max, Math.max(min, n));

  function paint() {
    object.style.transform = `rotateX(${rotX.toFixed(3)}deg) rotateY(${rotY.toFixed(3)}deg)`;

    // Move the highlight across the metal as the coin turns.
    const normalized = (Math.sin(rotY * Math.PI / 180) + 1) * 0.5;
    const shineX = 18 + normalized * 64;
    stage.style.setProperty('--giga-shine-x', `${shineX.toFixed(1)}%`);
  }

  function animate(now) {
    const dt = clamp((now - frameTime) / 16.6667, 0.25, 2.2);
    frameTime = now;

    if (!dragging && visible) {
      if (Math.abs(velocityY) > 0.006 || Math.abs(velocityX) > 0.004) {
        rotY += velocityY * dt;
        rotX = clamp(rotX + velocityX * dt, -28, 28);
        velocityY *= Math.pow(0.915, dt);
        velocityX *= Math.pow(0.900, dt);
      } else if (!reduceMotion && now - lastInteraction > 1050) {
        // Slow premium idle turn; full front/back remain reachable by touch.
        rotY += 0.075 * dt;
      }
    }

    paint();
    requestAnimationFrame(animate);
  }

  function begin(e) {
    if (pointerId !== null) return;
    pointerId = e.pointerId;
    dragging = true;
    lastX = e.clientX;
    lastY = e.clientY;
    lastTime = performance.now();
    velocityX = 0;
    velocityY = 0;
    lastInteraction = lastTime;
    stage.classList.add('is-dragging');
    try { stage.setPointerCapture(e.pointerId); } catch (_) {}
    e.preventDefault();
  }

  function move(e) {
    if (!dragging || e.pointerId !== pointerId) return;

    const now = performance.now();
    const elapsed = Math.max(8, now - lastTime);
    const dx = e.clientX - lastX;
    const dy = e.clientY - lastY;

    rotY += dx * 0.62;
    rotX = clamp(rotX - dy * 0.28, -28, 28);

    // Inertial velocity is normalized to roughly one 60 Hz frame.
    const frameScale = 16.6667 / elapsed;
    velocityY = dx * 0.34 * frameScale;
    velocityX = -dy * 0.16 * frameScale;

    lastX = e.clientX;
    lastY = e.clientY;
    lastTime = now;
    lastInteraction = now;
    paint();
    e.preventDefault();
  }

  function end(e) {
    if (e && pointerId !== null && e.pointerId !== pointerId) return;
    if (pointerId !== null) {
      try { stage.releasePointerCapture(pointerId); } catch (_) {}
    }
    pointerId = null;
    dragging = false;
    lastInteraction = performance.now();
    stage.classList.remove('is-dragging');
  }

  stage.addEventListener('pointerdown', begin, { passive: false });
  stage.addEventListener('pointermove', move, { passive: false });
  stage.addEventListener('pointerup', end, { passive: false });
  stage.addEventListener('pointercancel', end, { passive: false });
  stage.addEventListener('lostpointercapture', end);

  stage.addEventListener('keydown', (e) => {
    let handled = true;
    if (e.key === 'ArrowLeft') rotY -= 14;
    else if (e.key === 'ArrowRight') rotY += 14;
    else if (e.key === 'ArrowUp') rotX = clamp(rotX - 7, -28, 28);
    else if (e.key === 'ArrowDown') rotX = clamp(rotX + 7, -28, 28);
    else if (e.key === ' ' || e.key === 'Enter') rotY += 180;
    else handled = false;

    if (handled) {
      velocityX = 0;
      velocityY = 0;
      lastInteraction = performance.now();
      paint();
      e.preventDefault();
    }
  });

  if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver((entries) => {
      visible = !!entries[0]?.isIntersecting;
    }, { threshold: 0.02 });
    observer.observe(stage);
  }

  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      visible = false;
    } else {
      visible = true;
      frameTime = performance.now();
      lastInteraction = performance.now();
    }
  });

  paint();
  requestAnimationFrame(animate);
})();

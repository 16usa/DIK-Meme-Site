(() => {
  const cfg = window.DIK_CONFIG || {};
  const $ = (id) => document.getElementById(id);
  const isPlaceholder = (value) => !value || /PASTE_|YOUR_|HERE/i.test(value);

  document.title = cfg.tokenName || 'GIGA CAT';
  $('heroTagline').textContent = cfg.heroTagline || 'Small cat. Big power.';
  $('heroSubline').textContent = cfg.heroSubline || 'Meet GIGA CAT — built different and impossible to ignore.';
  $('year').textContent = `© ${new Date().getFullYear()} GIGA CAT`;

  const contract = cfg.contractAddress || '';
  $('contractValue').textContent = isPlaceholder(contract) ? 'PASTE CONTRACT ADDRESS' : contract;

  function bindExternal(id, url) {
    const el = $(id);
    if (!el) return;
    if (isPlaceholder(url)) {
      el.classList.add('disabled');
      el.setAttribute('aria-disabled', 'true');
      el.addEventListener('click', (e) => e.preventDefault());
      return;
    }
    el.href = url;
    el.target = '_blank';
    el.rel = 'noopener noreferrer';
  }

  bindExternal('pumpButton', cfg.pumpUrl);
  bindExternal('pumpButtonBottom', cfg.pumpUrl);
  bindExternal('topBuy', cfg.pumpUrl);
  bindExternal('xLink', cfg.xUrl);
  bindExternal('dexLink', cfg.dexUrl);

  const toast = $('toast');
  let toastTimer;
  function showToast(message) {
    toast.textContent = message;
    toast.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => toast.classList.remove('show'), 1500);
  }

  async function copyContract() {
    if (isPlaceholder(contract)) {
      showToast('Add contract in config.js');
      return;
    }
    try {
      await navigator.clipboard.writeText(contract);
      showToast('Contract copied');
    } catch {
      const area = document.createElement('textarea');
      area.value = contract;
      document.body.appendChild(area);
      area.select();
      document.execCommand('copy');
      area.remove();
      showToast('Contract copied');
    }
  }

  $('copyButton').addEventListener('click', copyContract);
  $('contractButton').addEventListener('click', copyContract);

  const topbar = $('topbar');
  const heroMedia = document.querySelector('.hero-media');
  let raf = null;
  function onScroll() {
    if (raf) return;
    raf = requestAnimationFrame(() => {
      const y = window.scrollY;
      topbar.classList.toggle('scrolled', y > 20);
      if (heroMedia && y < window.innerHeight * 1.05) {
        heroMedia.style.transform = `scale(1.015) translateY(${y * 0.09}px)`;
      }
      raf = null;
    });
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  const io = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('visible');
        io.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });
  document.querySelectorAll('.reveal').forEach((el) => io.observe(el));

  const tilt = document.querySelector('.tilt-card');
  if (tilt && matchMedia('(pointer:fine)').matches) {
    tilt.addEventListener('mousemove', (e) => {
      const r = tilt.getBoundingClientRect();
      const x = (e.clientX - r.left) / r.width - .5;
      const y = (e.clientY - r.top) / r.height - .5;
      tilt.style.transform = `perspective(1100px) rotateY(${x * 4}deg) rotateX(${-y * 4}deg)`;
    });
    tilt.addEventListener('mouseleave', () => tilt.style.transform = '');
  }
})();

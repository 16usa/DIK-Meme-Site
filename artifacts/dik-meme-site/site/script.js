(() => {
  const cfg = window.DIK_CONFIG || {};
  const $ = (id) => document.getElementById(id);
  const isPlaceholder = (value) => !value || /PASTE_|YOUR_|HERE/i.test(value);

  document.title = cfg.tokenName || 'DIK';
  if ($('heroTagline')) $('heroTagline').textContent = cfg.heroTagline || 'Purple. Unbothered. Everywhere.';
  if ($('heroSubline')) $('heroSubline').textContent = cfg.heroSubline || 'Meet DIK — one eggplant, too many situations.';
  if ($('year')) $('year').textContent = `© ${new Date().getFullYear()} DIK`;

  const contract = cfg.contractAddress || '';
  if ($('contractValue')) $('contractValue').textContent = isPlaceholder(contract) ? 'PASTE CONTRACT ADDRESS' : contract;

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
  bindExternal('telegramLink', cfg.telegramUrl);

  const toast = $('toast');
  let toastTimer;
  function showToast(message) {
    if (!toast) return;
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

  if ($('copyButton')) $('copyButton').addEventListener('click', copyContract);
  if ($('contractButton')) $('contractButton').addEventListener('click', copyContract);

  const topbar = $('topbar');
  const rail = $('slideRail');
  const current = $('slideCurrent');
  const slides = Array.from(document.querySelectorAll('.slide[data-slide]'));
  const dots = rail ? Array.from(rail.querySelectorAll('a')) : [];
  let activeIndex = 0;

  function setActiveSlide(index) {
    if (index < 0 || index >= slides.length || index === activeIndex && document.documentElement.dataset.slideReady) return;
    activeIndex = index;
    document.documentElement.dataset.slideReady = '1';
    const slide = slides[index];
    const onLight = slide.dataset.theme === 'light';

    dots.forEach((dot, i) => {
      dot.classList.toggle('active', i === index);
      if (i === index) dot.setAttribute('aria-current', 'true');
      else dot.removeAttribute('aria-current');
    });

    if (current) current.textContent = String(index + 1).padStart(2, '0');
    if (topbar) {
      topbar.classList.toggle('on-light', onLight);
      topbar.classList.toggle('scrolled', index !== 0 || window.scrollY > 18);
    }
    if (rail) rail.classList.toggle('on-light', onLight);

    const theme = document.querySelector('meta[name="theme-color"]');
    if (theme) theme.setAttribute('content', onLight ? '#f0f0ec' : '#070707');
  }

  setActiveSlide(0);

  const slideObserver = new IntersectionObserver((entries) => {
    const visible = entries
      .filter((entry) => entry.isIntersecting)
      .sort((a, b) => b.intersectionRatio - a.intersectionRatio)[0];
    if (!visible || visible.intersectionRatio < 0.45) return;
    const index = slides.indexOf(visible.target);
    if (index !== -1) setActiveSlide(index);
  }, { threshold: [0.45, 0.6, 0.75] });

  slides.forEach((slide) => slideObserver.observe(slide));

  let scrollRaf = null;
  function onScroll() {
    if (scrollRaf) return;
    scrollRaf = requestAnimationFrame(() => {
      if (topbar && activeIndex === 0) topbar.classList.toggle('scrolled', window.scrollY > 18);
      scrollRaf = null;
    });
  }
  window.addEventListener('scroll', onScroll, { passive: true });

  const revealObserver = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) entry.target.classList.add('visible');
    });
  }, { threshold: 0.16 });
  document.querySelectorAll('.reveal').forEach((el) => revealObserver.observe(el));

  const tilt = document.querySelector('.tilt-card');
  if (tilt && matchMedia('(pointer:fine)').matches) {
    tilt.addEventListener('mousemove', (e) => {
      const r = tilt.getBoundingClientRect();
      const x = (e.clientX - r.left) / r.width - .5;
      const y = (e.clientY - r.top) / r.height - .5;
      tilt.style.transform = `perspective(1100px) rotateY(${x * 4}deg) rotateX(${-y * 4}deg)`;
    });
    tilt.addEventListener('mouseleave', () => { tilt.style.transform = ''; });
  }

  window.addEventListener('keydown', (e) => {
    if (e.key !== 'ArrowDown' && e.key !== 'ArrowUp' && e.key !== 'PageDown' && e.key !== 'PageUp') return;
    if (document.activeElement && /INPUT|TEXTAREA|SELECT/.test(document.activeElement.tagName)) return;
    const direction = e.key === 'ArrowUp' || e.key === 'PageUp' ? -1 : 1;
    const next = Math.max(0, Math.min(slides.length - 1, activeIndex + direction));
    if (next === activeIndex) return;
    e.preventDefault();
    slides[next].scrollIntoView({ behavior: 'smooth', block: 'start' });
  });
})();

(() => {
  'use strict';

  function run() {
    const coin = document.querySelector('.coin-mark');
    const title = document.querySelector('.buy-panel h2, .buy h2');
    if (!coin || !title) return;

    const parent = title.parentElement;
    if (!parent) return;

    if (coin !== parent.firstElementChild || coin.compareDocumentPosition(title) & Node.DOCUMENT_POSITION_FOLLOWING) {
      parent.insertBefore(coin, title);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', run, { once: true });
  } else {
    run();
  }
})();

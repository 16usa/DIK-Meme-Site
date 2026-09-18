import type { ReactNode } from 'react';

import { motion } from 'framer-motion';

const BASE = `${import.meta.env.BASE_URL}assets/`;

export type PromoScene =
  | 'drive'
  | 'casino'
  | 'penthouse'
  | 'gym'
  | 'beach'
  | 'montage'
  | 'final';

interface SceneProps {
  kind: PromoScene;
  sceneNumber: string;
}

const ease = [0.16, 1, 0.3, 1] as const;

const IMAGE_MAP: Record<Exclude<PromoScene, 'montage' | 'final'>, string> = {
  drive: `${BASE}dik-drive.png`,
  casino: `${BASE}dik-casino.png`,
  penthouse: `${BASE}dik-penthouse.png`,
  gym: `${BASE}dik-gym.png`,
  beach: `${BASE}dik-beach.png`,
};

function FrameImage({
  src,
  position = 'center',
  className = '',
}: {
  src: string;
  position?: string;
  className?: string;
}) {
  return (
    <motion.img
      className={`video-image ${className}`}
      src={src}
      alt=""
      style={{ objectPosition: position }}
      initial={{ scale: 1.18, x: '4%', filter: 'saturate(.82) contrast(.95)' }}
      animate={{ scale: 1.03, x: '0%', filter: 'saturate(1.06) contrast(1.02)' }}
      exit={{ scale: 1.1, x: '-4%', filter: 'saturate(.8)' }}
      transition={{ duration: 3.8, ease }}
    />
  );
}

function SceneShell({
  children,
  className = '',
}: {
  children: ReactNode;
  className?: string;
}) {
  return (
    <motion.section
      className={`absolute inset-0 overflow-hidden ${className}`}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
      exit={{ opacity: 0 }}
      transition={{ duration: 0.42, ease: 'easeOut' }}
    >
      {children}
    </motion.section>
  );
}

function SceneMeta({
  sceneNumber,
  label,
  subline,
}: {
  sceneNumber: string;
  label: string;
  subline: string;
}) {
  return (
    <div className="absolute left-[8%] right-[8%] top-[9%] z-10 flex items-start justify-between">
      <div className="mono-font text-[2.2vw] tracking-[0.28em] text-[#f4c86b]">{sceneNumber}</div>
      <div className="mono-font text-right text-[1.8vw] tracking-[0.18em] text-[#f6e9d4]/70">
        {label}
        <br />
        <span className="text-[#f4c86b]">{subline}</span>
      </div>
    </div>
  );
}

export function PromoSceneFrame({ kind, sceneNumber }: SceneProps) {
  if (kind === 'drive') {
    return (
      <SceneShell className="bg-[#21132d]">
        <div className="absolute inset-0">
          <FrameImage src={IMAGE_MAP.drive} position="53% center" />
          <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(11,7,16,.08)_30%,rgba(11,7,16,.36)_62%,rgba(11,7,16,.96)_100%)]" />
          <div className="absolute inset-0 bg-[linear-gradient(90deg,rgba(11,7,16,.48),transparent_56%)]" />
        </div>
        <SceneMeta sceneNumber={sceneNumber} label="COASTAL UNIT" subline="01 / 07" />
        <div className="scene-copy absolute left-[8%] right-[8%] top-[54%] z-10">
          <motion.div
            initial={{ width: 0, opacity: 0 }}
            animate={{ width: '42%', opacity: 1 }}
            transition={{ delay: 0.22, duration: 0.55, ease }}
            className="editorial-rule mb-[3.5vh]"
          />
          <motion.p
            className="mono-font mb-[1.4vh] text-[2.4vw] tracking-[0.28em] text-[#f4c86b]"
            initial={{ opacity: 0, y: 12 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.36, duration: 0.44, ease }}
          >
            THE PURPLE MAIN CHARACTER
          </motion.p>
          <motion.h1
            className="display-font text-[31vw] leading-[0.74] text-[#f6e9d4]"
            initial={{ opacity: 0, y: 34, letterSpacing: '0.12em' }}
            animate={{ opacity: 1, y: 0, letterSpacing: '-0.015em' }}
            transition={{ delay: 0.26, duration: 0.86, ease }}
          >
            DIK
          </motion.h1>
          <motion.p
            className="mt-[3.5vh] max-w-[70%] text-[5.4vw] font-medium leading-[0.98] tracking-[-0.05em] text-[#f6e9d4]"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.72, duration: 0.72, ease }}
          >
            Purple. Unbothered.
            <br />
            <span className="text-[#f4c86b]">Everywhere.</span>
          </motion.p>
        </div>
        <motion.div
          className="absolute bottom-[9%] right-[8%] z-10 mono-font text-[1.9vw] tracking-[0.16em] text-[#f6e9d4]/65"
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          transition={{ delay: 1.1, duration: 0.55, ease }}
        >
          911 / NO BRAKES
        </motion.div>
      </SceneShell>
    );
  }

  if (kind === 'casino') {
    return (
      <SceneShell className="bg-[#130b1b]">
        <div className="absolute left-[7%] right-[7%] top-[16%] h-[55%] overflow-hidden border border-[#f4c86b]/70 bg-[#291034] shadow-[0_2vh_8vh_rgba(109,44,255,.28)]">
          <FrameImage src={IMAGE_MAP.casino} position="48% center" />
          <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(25,7,33,.04),rgba(11,7,16,.58))]" />
          <motion.div
            className="absolute right-[5%] top-[5%] mono-font text-[2vw] tracking-[.25em] text-[#f4c86b]"
            initial={{ opacity: 0, scale: 0.7 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.4, duration: 0.35, ease }}
          >
            777
          </motion.div>
        </div>
        <SceneMeta sceneNumber={sceneNumber} label="ROYAL SPADES" subline="02 / 07" />
        <div className="scene-copy absolute bottom-[10%] left-[8%] right-[8%] z-10">
          <motion.p
            className="mono-font text-[2.2vw] tracking-[0.28em] text-[#f4c86b]"
            initial={{ opacity: 0, x: -18 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.26, duration: 0.45, ease }}
          >
            THE ODDS WERE PERSONAL
          </motion.p>
          <motion.h2
            className="display-font mt-[1.5vh] text-[17vw] leading-[0.82] text-[#f6e9d4]"
            initial={{ opacity: 0, scale: 0.84, rotate: -2 }}
            animate={{ opacity: 1, scale: 1, rotate: 0 }}
            transition={{ delay: 0.4, duration: 0.75, ease }}
          >
            JACKPOT?
          </motion.h2>
          <motion.div
            className="mt-[2.5vh] flex items-center gap-3 text-[3.2vw] font-bold text-[#c7b6c9]"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.86, duration: 0.35 }}
          >
            <span className="h-[1px] w-[13vw] bg-[#f4c86b]" />
            <span>SHOCKED. STILL RICH.</span>
          </motion.div>
        </div>
      </SceneShell>
    );
  }

  if (kind === 'penthouse') {
    return (
      <SceneShell className="bg-[#1b1021]">
        <div className="absolute inset-0">
          <FrameImage src={IMAGE_MAP.penthouse} position="48% center" />
          <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(11,7,16,.2),rgba(11,7,16,.18)_42%,rgba(11,7,16,.93)_88%)]" />
        </div>
        <SceneMeta sceneNumber={sceneNumber} label="PENTHOUSE HOURS" subline="03 / 07" />
        <motion.div
          className="absolute left-[8%] top-[22%] z-10 max-w-[76%]"
          initial={{ opacity: 0, y: 22 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3, duration: 0.7, ease }}
        >
          <div className="display-font text-[21vw] leading-[0.77] text-[#f6e9d4]">
            RICH
            <br />
            <span className="letter-outline">IN</span>
            <br />
            PEACE.
          </div>
        </motion.div>
        <motion.div
          className="absolute bottom-[10%] left-[8%] right-[8%] z-10 flex items-end justify-between border-t border-[#f4c86b]/60 pt-[1.6vh]"
          initial={{ opacity: 0, y: 14 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.9, duration: 0.5, ease }}
        >
          <span className="mono-font text-[2.3vw] tracking-[0.18em] text-[#f4c86b]">MORNING DIK</span>
          <span className="text-right text-[2.7vw] leading-[1.1] text-[#c7b6c9]">No alarms.<br />No apologies.</span>
        </motion.div>
      </SceneShell>
    );
  }

  if (kind === 'gym') {
    return (
      <SceneShell className="bg-[#151019]">
        <div className="absolute inset-0">
          <FrameImage src={IMAGE_MAP.gym} position="53% center" />
          <div className="absolute inset-0 bg-[linear-gradient(90deg,rgba(11,7,16,.78),rgba(11,7,16,.05)_70%)]" />
          <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(11,7,16,.1),rgba(11,7,16,.55))]" />
        </div>
        <SceneMeta sceneNumber={sceneNumber} label="DISCIPLINE DEPT." subline="04 / 07" />
        <div className="absolute left-[8%] top-[31%] z-10">
          <motion.p
            className="mono-font mb-[2vh] text-[2.3vw] tracking-[0.3em] text-[#f4c86b]"
            initial={{ opacity: 0, x: -18 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.22, duration: 0.42, ease }}
          >
            NO DAYS OFF
          </motion.p>
          <motion.h2
            className="display-font text-[26vw] leading-[0.75] text-[#f6e9d4]"
            initial={{ opacity: 0, x: -35, rotate: -3 }}
            animate={{ opacity: 1, x: 0, rotate: 0 }}
            transition={{ delay: 0.36, duration: 0.68, ease }}
          >
            LOCKED
            <br />
            IN.
          </motion.h2>
        </div>
        <motion.div
          className="absolute bottom-[10%] left-[8%] right-[8%] z-10 flex items-center gap-3"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.86, duration: 0.4 }}
        >
          <span className="h-[1px] w-[20vw] bg-[#f4c86b]" />
          <span className="mono-font text-[2vw] tracking-[0.15em] text-[#f6e9d4]/75">BUILT DIFFERENT / 04</span>
        </motion.div>
      </SceneShell>
    );
  }

  if (kind === 'beach') {
    return (
      <SceneShell className="bg-[#27152b]">
        <div className="absolute inset-0">
          <FrameImage src={IMAGE_MAP.beach} position="48% center" />
          <div className="absolute inset-0 bg-[linear-gradient(180deg,rgba(11,7,16,.1),rgba(11,7,16,.2)_48%,rgba(11,7,16,.95)_96%)]" />
        </div>
        <SceneMeta sceneNumber={sceneNumber} label="COASTAL OFFICE" subline="05 / 07" />
        <motion.div
          className="absolute bottom-[17%] left-[8%] right-[8%] z-10"
          initial={{ opacity: 0, y: 30, scale: 0.95 }}
          animate={{ opacity: 1, y: 0, scale: 1 }}
          transition={{ delay: 0.25, duration: 0.8, ease }}
        >
          <div className="display-font text-[24vw] leading-[0.75] text-[#f6e9d4]">UNBOTHERED.</div>
          <div className="mt-[2.8vh] flex items-center gap-3">
            <span className="h-[1px] w-[17vw] bg-[#f4c86b]" />
            <span className="mono-font text-[2.15vw] tracking-[0.18em] text-[#f4c86b]">SUNSET / SIPS / ZERO NOTES</span>
          </div>
        </motion.div>
        <motion.div
          className="absolute right-[8%] top-[41%] z-10 rounded-full border border-[#f4c86b]/70 px-[2.2vw] py-[1vw] mono-font text-[1.85vw] tracking-[0.2em] text-[#f4c86b]"
          initial={{ opacity: 0, rotate: 12, scale: 0.6 }}
          animate={{ opacity: 1, rotate: 3, scale: 1 }}
          transition={{ delay: 0.68, duration: 0.55, ease }}
        >
          VACATION MODE
        </motion.div>
      </SceneShell>
    );
  }

  if (kind === 'montage') {
    const tiles = [
      { src: `${BASE}dik-original.png`, label: 'ORIGINAL', className: 'left-[8%] top-[19%] h-[30%] w-[36%] rotate-[-5deg]' },
      { src: `${BASE}dik-morning.png`, label: 'MORNING', className: 'right-[9%] top-[14%] h-[31%] w-[39%] rotate-[5deg]' },
      { src: `${BASE}dik-gym.png`, label: 'GYM', className: 'left-[11%] top-[52%] h-[30%] w-[37%] rotate-[4deg]' },
      { src: `${BASE}dik-penthouse.png`, label: 'PENTHOUSE', className: 'right-[7%] top-[51%] h-[31%] w-[39%] rotate-[-4deg]' },
    ];
    return (
      <SceneShell className="bg-[#120b17]">
        <SceneMeta sceneNumber={sceneNumber} label="MANY LIVES" subline="06 / 07" />
        <motion.div
          className="absolute left-[8%] top-[35%] z-20"
          initial={{ opacity: 0, scale: 0.7, rotate: -8 }}
          animate={{ opacity: 1, scale: 1, rotate: -4 }}
          transition={{ delay: 0.35, duration: 0.75, ease }}
        >
          <div className="display-font text-[19vw] leading-[0.73] text-[#f6e9d4]">ONE DIK.</div>
          <div className="display-font text-[14vw] leading-[0.78] text-[#f4c86b]">MANY LIVES.</div>
        </motion.div>
        {tiles.map((tile, index) => (
          <motion.div
            key={tile.label}
            className={`absolute overflow-hidden border border-[#f6e9d4]/70 bg-[#2b1835] shadow-[0_1.5vh_4vh_rgba(11,7,16,.55)] ${tile.className}`}
            initial={{ opacity: 0, scale: 0.55, y: index % 2 ? -30 : 30 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            transition={{ delay: 0.18 + index * 0.1, duration: 0.58, ease }}
          >
            <img className="video-image" src={tile.src} alt="" />
            <span className="absolute bottom-[4%] left-[6%] mono-font text-[1.65vw] tracking-[0.18em] text-[#f4c86b]">{tile.label}</span>
          </motion.div>
        ))}
        <motion.p
          className="absolute bottom-[9%] left-[8%] z-20 mono-font text-[2.2vw] tracking-[0.16em] text-[#c7b6c9]"
          initial={{ opacity: 0, y: 12 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.92, duration: 0.45, ease }}
        >
          CARS / CASINOS / BEACHES / MONDAYS
        </motion.p>
      </SceneShell>
    );
  }

  return (
    <SceneShell className="bg-[#0b0710]">
      <div className="absolute inset-0">
        <motion.img
          className="video-image opacity-25"
          src={`${BASE}dik-original.png`}
          alt=""
          initial={{ scale: 1.1, opacity: 0 }}
          animate={{ scale: 1, opacity: 0.25 }}
          exit={{ opacity: 0 }}
          transition={{ duration: 1.1, ease }}
          style={{ objectPosition: 'center' }}
        />
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_50%_38%,rgba(109,44,255,.36),transparent_48%),linear-gradient(180deg,rgba(11,7,16,.72),#0b0710_88%)]" />
      </div>
      <SceneMeta sceneNumber={sceneNumber} label="THE LOCKUP" subline="07 / 07" />
      <div className="absolute inset-x-[8%] top-[25%] z-10 text-center">
        <motion.div
          className="mono-font mb-[2vh] text-[2.15vw] tracking-[0.32em] text-[#f4c86b]"
          initial={{ opacity: 0, y: 16 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2, duration: 0.45, ease }}
        >
          PURPLE. UNBOTHERED. EVERYWHERE.
        </motion.div>
        <motion.h2
          className="display-font shine text-[45vw] leading-[0.72]"
          initial={{ opacity: 0, scale: 0.74, letterSpacing: '0.08em' }}
          animate={{ opacity: 1, scale: 1, letterSpacing: '-0.02em' }}
          transition={{ delay: 0.3, duration: 1.05, ease }}
        >
          DIK
        </motion.h2>
        <motion.div
          className="mx-auto mt-[5vh] h-[1px] w-[48%] bg-[#f4c86b]"
          initial={{ scaleX: 0, opacity: 0 }}
          animate={{ scaleX: 1, opacity: 1 }}
          transition={{ delay: 0.84, duration: 0.65, ease }}
        />
        <motion.p
          className="mono-font mt-[2.5vh] text-[5.1vw] tracking-[0.12em] text-[#f6e9d4]"
          initial={{ opacity: 0, y: 18 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.95, duration: 0.62, ease }}
        >
          dik.wtf
        </motion.p>
      </div>
      <motion.div
        className="absolute bottom-[8%] left-0 right-0 z-10 text-center text-[2.1vw] tracking-[0.16em] text-[#c7b6c9]"
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ delay: 1.25, duration: 0.5 }}
      >
        ONE EGGPLANT. TOO MANY SITUATIONS.
      </motion.div>
    </SceneShell>
  );
}

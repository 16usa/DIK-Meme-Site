import {
  SafeFrame,
  VideoCanvas,
  VideoPausedContext,
  type VideoAspectRatio,
  useVideoPlayer,
} from '@/lib/video';
import { AnimatePresence, motion } from 'framer-motion';
import { useEffect, useRef } from 'react';

import { PromoSceneFrame, type PromoScene } from './video_scenes/Scene';

export const SCENE_DURATIONS = {
  drive: 3600,
  casino: 1800,
  penthouse: 1900,
  gym: 1800,
  beach: 1800,
  montage: 1900,
  final: 1800,
};

const VIDEO_ASPECT_RATIO: VideoAspectRatio = '9:16';

const SCENES: PromoScene[] = ['drive', 'casino', 'penthouse', 'gym', 'beach', 'montage', 'final'];

const SCENE_COLORS = ['#21132d', '#130b1b', '#1b1021', '#151019', '#27152b', '#120b17', '#0b0710'];
const EASE = [0.16, 1, 0.3, 1] as const;
const AUDIO_SEEK_EPSILON_SEC = 0.18;

const SCENE_START_SEC: Record<string, number> = (() => {
  const offsets: Record<string, number> = {};
  let cumulativeMs = 0;
  for (const [key, duration] of Object.entries(SCENE_DURATIONS)) {
    offsets[key] = cumulativeMs / 1000;
    cumulativeMs += duration;
  }
  return offsets;
})();

export default function VideoTemplate({
  durations = SCENE_DURATIONS,
  loop = true,
  paused = false,
  muted = false,
  onSceneChange,
}: {
  durations?: Record<string, number>;
  loop?: boolean;
  paused?: boolean;
  muted?: boolean;
  onSceneChange?: (sceneKey: string) => void;
} = {}) {
  const { currentSceneKey } = useVideoPlayer({
    durations,
    loop,
    paused,
  });
  const baseSceneKey = currentSceneKey.replace(/_r[12]$/, '');
  const sceneIndex = Math.max(0, SCENES.indexOf(baseSceneKey as PromoScene));
  const activeScene = SCENES[sceneIndex] ?? 'drive';
  const audioRef = useRef<HTMLAudioElement | null>(null);
  const lastSceneKeyRef = useRef<string | null>(null);

  useEffect(() => {
    onSceneChange?.(currentSceneKey);
  }, [currentSceneKey, onSceneChange]);

  useEffect(() => {
    const audio = audioRef.current;
    if (!audio) return;

    audio.volume = 0.45;
    if (paused) {
      audio.pause();
      return;
    }

    if (lastSceneKeyRef.current !== currentSceneKey) {
      lastSceneKeyRef.current = currentSceneKey;
      const targetTime = SCENE_START_SEC[baseSceneKey] ?? 0;
      if (
        Math.abs(audio.currentTime - targetTime) > AUDIO_SEEK_EPSILON_SEC
      ) {
        audio.currentTime = targetTime;
      }
    }
    audio.play().catch(() => {});
  }, [currentSceneKey, baseSceneKey, muted, paused]);

  return (
    <VideoPausedContext.Provider value={paused}>
      <VideoCanvas
        className="dik-video"
        aspectRatio={VIDEO_ASPECT_RATIO}
        style={{ backgroundColor: SCENE_COLORS[sceneIndex] ?? SCENE_COLORS[0] }}
      >
      <motion.div
        className="absolute -left-[24vw] top-[14%] z-[2] h-[34vw] w-[34vw] rounded-full bg-[#6d2cff]/20 blur-[4vw]"
        animate={{
          x: [`0vw`, sceneIndex % 2 ? '34vw' : '-4vw', '0vw'],
          y: [`0vh`, sceneIndex % 3 ? '-8vh' : '12vh', '0vh'],
          scale: sceneIndex === 5 ? 1.7 : 1,
          backgroundColor: sceneIndex === 4 ? 'rgba(244,200,107,.18)' : 'rgba(109,44,255,.2)',
        }}
        transition={{ duration: 5.5, ease: 'easeInOut' }}
      />
      <motion.div
        className="absolute -right-[26vw] bottom-[8%] z-[2] h-[44vw] w-[44vw] rounded-full bg-[#f4c86b]/10 blur-[5vw]"
        animate={{
          x: sceneIndex % 2 ? '-8vw' : '5vw',
          y: sceneIndex === 0 ? '5vh' : '-6vh',
          scale: sceneIndex === 6 ? 1.2 : 0.9,
        }}
          transition={{ duration: 1.8, ease: EASE }}
      />
      <div className="video-vignette" />
      <SafeFrame className="z-10">
        <div className="frame-corner tl" />
        <div className="frame-corner tr" />
        <div className="frame-corner bl" />
        <div className="frame-corner br" />
        <motion.div
          className="absolute left-[8%] top-[4.5%] z-40 display-font text-[7vw] leading-none text-[#f6e9d4]"
          animate={{ scale: sceneIndex === 0 ? 1 : 0.78, originX: 0, originY: 0 }}
          transition={{ duration: 0.8, ease: EASE }}
        >
          DIK<span className="text-[#f4c86b]">.</span>
        </motion.div>
        <motion.div
          className="absolute right-[8%] top-[5.1%] z-40 mono-font text-[1.75vw] tracking-[0.16em] text-[#f6e9d4]/65"
          animate={{ opacity: sceneIndex === 6 ? 1 : 0.62 }}
        >
          <span className="text-[#f4c86b]">●</span> MEME LUXURY
        </motion.div>
        <motion.div
          className="absolute bottom-[4.4%] left-[8%] z-40 mono-font text-[1.7vw] tracking-[0.18em] text-[#f6e9d4]/60"
          animate={{ opacity: sceneIndex === 6 ? 1 : 0.5 }}
        >
          SOLANA / 2025
        </motion.div>
        <motion.div
          className="absolute bottom-[4.4%] right-[8%] z-40 mono-font text-[1.7vw] tracking-[0.18em] text-[#f4c86b]"
          animate={{ opacity: sceneIndex === 0 ? 0 : 1 }}
          transition={{ duration: 0.4 }}
        >
          0{Math.min(sceneIndex + 1, 7)} / 07
        </motion.div>
        <div className="absolute bottom-[4.8%] left-1/2 z-40 h-[1px] w-[32%] -translate-x-1/2 overflow-hidden bg-[#f6e9d4]/20">
          <motion.div
            className="h-full origin-left bg-[#f4c86b]"
            animate={{ scaleX: (sceneIndex + 1) / 7 }}
            transition={{ duration: 0.65, ease: EASE }}
          />
        </div>
        <AnimatePresence mode="sync" initial={false}>
          <PromoSceneFrame key={currentSceneKey} kind={activeScene} sceneNumber={`0${sceneIndex + 1}`} />
        </AnimatePresence>
      </SafeFrame>
        <audio
          ref={audioRef}
          src={`${import.meta.env.BASE_URL}audio/bg_music.mp3`}
          preload="auto"
          autoPlay
          muted={muted}
        />
      </VideoCanvas>
    </VideoPausedContext.Provider>
  );
}

import {
  SafeFrame,
  VideoCanvas,
  type VideoAspectRatio,
  useVideoPlayer,
} from '@/lib/video';
import { AnimatePresence, motion } from 'framer-motion';

import { PromoSceneFrame, type PromoScene } from './video_scenes/Scene';

const SCENE_DURATIONS = {
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

export default function VideoTemplate() {
  const { currentScene } = useVideoPlayer({
    durations: SCENE_DURATIONS,
  });
  const activeScene = SCENES[currentScene] ?? 'drive';

  return (
    <VideoCanvas
      className="dik-video"
      aspectRatio={VIDEO_ASPECT_RATIO}
      style={{ backgroundColor: SCENE_COLORS[currentScene] ?? SCENE_COLORS[0] }}
    >
      <motion.div
        className="absolute -left-[24vw] top-[14%] z-[2] h-[34vw] w-[34vw] rounded-full bg-[#6d2cff]/20 blur-[4vw]"
        animate={{
          x: [`0vw`, currentScene % 2 ? '34vw' : '-4vw', '0vw'],
          y: [`0vh`, currentScene % 3 ? '-8vh' : '12vh', '0vh'],
          scale: currentScene === 5 ? 1.7 : 1,
          backgroundColor: currentScene === 4 ? 'rgba(244,200,107,.18)' : 'rgba(109,44,255,.2)',
        }}
        transition={{ duration: 5.5, ease: 'easeInOut' }}
      />
      <motion.div
        className="absolute -right-[26vw] bottom-[8%] z-[2] h-[44vw] w-[44vw] rounded-full bg-[#f4c86b]/10 blur-[5vw]"
        animate={{
          x: currentScene % 2 ? '-8vw' : '5vw',
          y: currentScene === 0 ? '5vh' : '-6vh',
          scale: currentScene === 6 ? 1.2 : 0.9,
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
          animate={{ scale: currentScene === 0 ? 1 : 0.78, originX: 0, originY: 0 }}
          transition={{ duration: 0.8, ease: EASE }}
        >
          DIK<span className="text-[#f4c86b]">.</span>
        </motion.div>
        <motion.div
          className="absolute right-[8%] top-[5.1%] z-40 mono-font text-[1.75vw] tracking-[0.16em] text-[#f6e9d4]/65"
          animate={{ opacity: currentScene === 6 ? 1 : 0.62 }}
        >
          <span className="text-[#f4c86b]">●</span> MEME LUXURY
        </motion.div>
        <motion.div
          className="absolute bottom-[4.4%] left-[8%] z-40 mono-font text-[1.7vw] tracking-[0.18em] text-[#f6e9d4]/60"
          animate={{ opacity: currentScene === 6 ? 1 : 0.5 }}
        >
          SOLANA / 2025
        </motion.div>
        <motion.div
          className="absolute bottom-[4.4%] right-[8%] z-40 mono-font text-[1.7vw] tracking-[0.18em] text-[#f4c86b]"
          animate={{ opacity: currentScene === 0 ? 0 : 1 }}
          transition={{ duration: 0.4 }}
        >
          0{Math.min(currentScene + 1, 7)} / 07
        </motion.div>
        <div className="absolute bottom-[4.8%] left-1/2 z-40 h-[1px] w-[32%] -translate-x-1/2 overflow-hidden bg-[#f6e9d4]/20">
          <motion.div
            className="h-full origin-left bg-[#f4c86b]"
            animate={{ scaleX: (currentScene + 1) / 7 }}
            transition={{ duration: 0.65, ease: EASE }}
          />
        </div>
        <AnimatePresence mode="sync" initial={false}>
          <PromoSceneFrame key={activeScene} kind={activeScene} sceneNumber={`0${currentScene + 1}`} />
        </AnimatePresence>
      </SafeFrame>
    </VideoCanvas>
  );
}

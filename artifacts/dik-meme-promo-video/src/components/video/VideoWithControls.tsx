import {
  ChevronDown,
  ChevronUp,
  Pause,
  Play,
  Repeat,
  Volume2,
  VolumeX,
} from 'lucide-react';
import {
  useCallback,
  useEffect,
  useRef,
  useState,
  type PointerEvent as ReactPointerEvent,
  type ReactNode,
} from 'react';

import { SCENE_DETAILS } from './sceneMeta';
import VideoTemplate, { SCENE_DURATIONS } from './VideoTemplate';
import { useSceneControls } from './useSceneControls';

const PROGRESS_TICK_MS = 60;

function announceSceneSelection(index: number, sceneKeys: string[]) {
  const key = sceneKeys[index];
  const details = SCENE_DETAILS[key];
  if (!details?.filePath) return;

  window.parent.postMessage(
    {
      type: 'REPLIT_VIDEO_SCENE_SELECTED',
      payload: {
        sceneIndex: index,
        sceneCount: sceneKeys.length,
        sceneTitle: details.title || key,
        filePath: details.filePath,
        lineNumber: 1,
      },
    },
    '*',
  );
}

function formatPlaybackTime(durationMs: number): string {
  const totalSeconds = Math.max(0, Math.floor(durationMs / 1000));
  const minutes = Math.floor(totalSeconds / 60);
  const seconds = totalSeconds % 60;
  return `${minutes}:${seconds.toString().padStart(2, '0')}`;
}

function PlaybackStatus({
  sceneKeys,
  activeIndex,
  activeDuration,
  activeStartTime,
  totalDuration,
  tick,
  paused,
  onJumpTo,
}: {
  sceneKeys: string[];
  activeIndex: number;
  activeDuration: number;
  activeStartTime: number;
  totalDuration: number;
  tick: number;
  paused: boolean;
  onJumpTo: (index: number) => void;
}) {
  const [elapsed, setElapsed] = useState(0);
  const elapsedBaseRef = useRef(0);

  useEffect(() => {
    setElapsed(0);
    elapsedBaseRef.current = 0;
  }, [tick]);

  useEffect(() => {
    if (paused) return;

    const start = performance.now();
    const timer = window.setInterval(() => {
      setElapsed(elapsedBaseRef.current + (performance.now() - start));
    }, PROGRESS_TICK_MS);

    return () => {
      window.clearInterval(timer);
      elapsedBaseRef.current += performance.now() - start;
    };
  }, [tick, paused]);

  const progress =
    activeDuration > 0 ? Math.min(1, elapsed / activeDuration) : 0;
  const totalElapsed = Math.min(
    totalDuration,
    activeStartTime + Math.min(elapsed, activeDuration),
  );

  return (
    <>
      <div className="flex flex-1 items-center gap-1">
        {sceneKeys.map((key, index) => {
          const isActive = index === activeIndex;
          const fill = isActive ? progress * 100 : 0;
          return (
            <button
              key={key}
              type="button"
              onClick={() => onJumpTo(index)}
              className="relative h-2 min-h-2 flex-1 cursor-pointer overflow-hidden rounded-full bg-white/20 transition-all hover:h-3 hover:bg-white/30"
              aria-label={`Jump to scene ${index + 1}: ${SCENE_DETAILS[key]?.title ?? key}`}
              aria-current={isActive ? 'true' : undefined}
            >
              <span
                className="absolute inset-y-0 left-0 rounded-full bg-[#f4c86b] transition-[width] duration-100"
                style={{ width: `${fill}%` }}
              />
            </button>
          );
        })}
      </div>
      <div className="shrink-0 font-mono text-[10px] tabular-nums text-white/60">
        {activeIndex + 1}/{sceneKeys.length}
      </div>
      <div
        className="min-w-[8ch] shrink-0 text-right font-mono text-[10px] tabular-nums text-white/80"
        role="timer"
        aria-label={`Playback time ${formatPlaybackTime(totalElapsed)} of ${formatPlaybackTime(totalDuration)}`}
      >
        {formatPlaybackTime(totalElapsed)} / {formatPlaybackTime(totalDuration)}
      </div>
    </>
  );
}

function IconButton({
  label,
  active = false,
  onClick,
  children,
}: {
  label: string;
  active?: boolean;
  onClick: () => void;
  children: ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-md transition-colors ${
        active
          ? 'bg-white/15 text-white'
          : 'text-white/60 hover:bg-white/10 hover:text-white'
      }`}
      title={label}
      aria-label={label}
      aria-pressed={active}
    >
      {children}
    </button>
  );
}

export default function VideoWithControls() {
  const isIframed =
    typeof window !== 'undefined' && window.self !== window.top;
  const sensorRef = useRef<HTMLDivElement | null>(null);
  const [collapsed, setCollapsed] = useState(false);
  const [hovering, setHovering] = useState(false);
  const [tapPinned, setTapPinned] = useState(false);
  const [muted, setMuted] = useState(false);

  const {
    sceneKeys,
    activeIndex,
    locked,
    paused,
    mountKey,
    tick,
    durations,
    activeDuration,
    activeStartTime,
    totalDuration,
    onSceneChange,
    jumpTo,
    toggleLock,
    togglePause,
  } = useSceneControls(SCENE_DURATIONS);

  const handleJumpTo = useCallback(
    (index: number) => {
      jumpTo(index);
      announceSceneSelection(index, sceneKeys);
    },
    [jumpTo, sceneKeys],
  );

  useEffect(() => {
    if (!paused) return;
    const frozen = document
      .getAnimations()
      .filter((animation) => animation.playState === 'running');
    frozen.forEach((animation) => animation.pause());
    return () => frozen.forEach((animation) => animation.play());
  }, [paused]);

  const handlePointerEnter = useCallback(
    (event: ReactPointerEvent<HTMLDivElement>) => {
      if (event.pointerType === 'mouse') setHovering(true);
    },
    [],
  );

  const handlePointerLeave = useCallback(
    (event: ReactPointerEvent<HTMLDivElement>) => {
      if (event.pointerType === 'mouse') setHovering(false);
    },
    [],
  );

  const handlePointerDown = useCallback(
    (event: ReactPointerEvent<HTMLDivElement>) => {
      if (event.pointerType !== 'mouse' && collapsed) setTapPinned(true);
    },
    [collapsed],
  );

  const handleToggleCollapsed = useCallback(() => {
    setCollapsed((value) => {
      if (!value) {
        setHovering(false);
        setTapPinned(false);
      }
      return !value;
    });
  }, []);

  useEffect(() => {
    if (!(collapsed && tapPinned)) return;

    const handleDocumentPointerDown = (event: PointerEvent) => {
      if (event.pointerType === 'mouse') return;
      const sensor = sensorRef.current;
      if (sensor && !sensor.contains(event.target as Node)) {
        setTapPinned(false);
      }
    };

    document.addEventListener('pointerdown', handleDocumentPointerDown);
    return () =>
      document.removeEventListener('pointerdown', handleDocumentPointerDown);
  }, [collapsed, tapPinned]);

  if (!isIframed) return <VideoTemplate />;

  const barVisible = !collapsed || hovering || tapPinned;

  return (
    <div className="relative h-screen w-full">
      <VideoTemplate
        key={mountKey}
        durations={durations}
        loop
        paused={paused}
        muted={muted}
        onSceneChange={onSceneChange}
      />
      <div
        ref={sensorRef}
        className="absolute bottom-0 left-0 right-0 z-50 flex h-[24%] flex-col justify-end"
        onPointerEnter={handlePointerEnter}
        onPointerLeave={handlePointerLeave}
        onPointerDown={handlePointerDown}
      >
        <div className="flex-1" aria-hidden="true" />
        <div
          className={`flex items-center gap-1.5 border-t border-white/10 bg-black/60 px-2 py-2 backdrop-blur-md transition-all duration-200 ${
            barVisible
              ? 'translate-y-0 opacity-100'
              : 'pointer-events-none translate-y-full opacity-0'
          }`}
          aria-hidden={!barVisible}
        >
          <IconButton
            label={paused ? 'Play' : 'Pause'}
            active={paused}
            onClick={togglePause}
          >
            {paused ? <Play size={16} /> : <Pause size={16} />}
          </IconButton>
          <IconButton
            label={
              locked ? 'Loop current scene: on' : 'Loop current scene: off'
            }
            active={locked}
            onClick={toggleLock}
          >
            <Repeat size={16} />
          </IconButton>
          <IconButton
            label={muted ? 'Unmute' : 'Mute'}
            active={muted}
            onClick={() => setMuted((value) => !value)}
          >
            {muted ? <VolumeX size={16} /> : <Volume2 size={16} />}
          </IconButton>
          <div className="h-6 w-px shrink-0 bg-white/15" aria-hidden="true" />
          <PlaybackStatus
            sceneKeys={sceneKeys}
            activeIndex={activeIndex}
            activeDuration={activeDuration}
            activeStartTime={activeStartTime}
            totalDuration={totalDuration}
            tick={tick}
            paused={paused}
            onJumpTo={handleJumpTo}
          />
          <IconButton
            label={collapsed ? 'Show controls' : 'Hide controls'}
            active={collapsed}
            onClick={handleToggleCollapsed}
          >
            {collapsed ? <ChevronUp size={18} /> : <ChevronDown size={18} />}
          </IconButton>
        </div>
      </div>
    </div>
  );
}
// Optional scene metadata for Replit workspace integrations. When the
// workspace's scene controls are enabled for this project, a viewer's click on
// a scene segment scopes their next chat request to that scene's source file.
// Fill one entry per SCENE_DURATIONS key in VideoTemplate.tsx only when a
// skill reference asks for it; otherwise leave the map empty. Scenes missing
// from the map still play and can be jumped to.
//
// Example:
//   export const SCENE_DETAILS: Record<string, SceneDetails> = {
//     open: { title: 'Intro', filePath: 'src/components/video/video_scenes/Scene1.tsx' },
//   };

export interface SceneDetails {
  title: string;
  filePath: string;
}

export const SCENE_DETAILS: Record<string, SceneDetails> = {
  drive: { title: 'Coastal Unit', filePath: 'src/components/video/video_scenes/Scene.tsx' },
  casino: { title: 'Jackpot?', filePath: 'src/components/video/video_scenes/Scene.tsx' },
  penthouse: { title: 'Rich in Peace', filePath: 'src/components/video/video_scenes/Scene.tsx' },
  gym: { title: 'Locked In', filePath: 'src/components/video/video_scenes/Scene.tsx' },
  beach: { title: 'Unbothered', filePath: 'src/components/video/video_scenes/Scene.tsx' },
  montage: { title: 'Many Lives', filePath: 'src/components/video/video_scenes/Scene.tsx' },
  final: { title: 'The Lockup', filePath: 'src/components/video/video_scenes/Scene.tsx' },
};

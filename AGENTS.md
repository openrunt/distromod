# AGENTS.md — Wyrmbound Vale

## Project identity
Wyrmbound Vale is a browser-playable 2D neon fantasy arcade action game about a Knight, Wizard, and spectral Dragon Protector cleansing corrupted realms.

## Delivery target
- Public target: `/web/play/index.html` must be directly playable in a browser with no build step.
- Source track: keep `/game/godot/` as the future premium Godot 4.x project and eventual Web export source.
- Hosting track: keep `/web/play/` focused on the current public browser demo or later Godot Web export output.

## Core rules
- Do not expose players to Godot source files, scripts, docs, or PR artifacts.
- Do not add Three.js or boss work until the playable web slice is solid.
- Keep code modular, readable, and asset-path friendly.
- Preserve readable silhouettes, HUD clarity, clear objectives, and responsive controls.

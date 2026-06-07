# AGENTS.md — Wyrmbound Vale

## Project identity
Wyrmbound Vale is a Godot-first 2D neon fantasy arcade action game about a Knight, Wizard, and spectral Dragon Protector cleansing corrupted realms.

## Core rules
- Godot 4.x is the source of truth for gameplay.
- Keep gameplay in reusable Godot scenes and focused GDScript files.
- Do not build core gameplay in raw browser canvas or Three.js.
- Do not collapse systems into one giant script.
- Prefer typed GDScript, signals, exported tuning variables, and data-driven content where practical.

## Quality bar
Accept work that improves readable silhouettes, scene structure, combat feel, hitboxes/hurtboxes, tile/platform clarity, HUD readability, and asset-pipeline compatibility.
Reject unreadable HUD text, blob characters, unclear objectives, missing scene/script references, and boss/prototype work before player feel lands.

## Current milestone
Milestone 1: Boot loads MainMenu, MainMenu starts BrightValeChasm, and the player controls a readable placeholder Knight that can move left/right and jump on simple ground. No boss, no Three.js, no unrelated files.

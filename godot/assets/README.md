# Sluggers – Assets Placeholder

This directory is reserved for Sluggers' game assets in the Godot rewrite.

## Expected contents

| Subdirectory   | Contents                                               |
|----------------|--------------------------------------------------------|
| `sprites/`     | Player, enemy, block, diamond, background sprites      |
| `sounds/`      | Sound-effect audio files (`.ogg` or `.wav`)            |
| `music/`       | Background music tracks (`.ogg`)                       |
| `fonts/`       | Bitmap / pixel fonts                                   |

## Sprite list (to be ported from the GameMaker project)

- `s_player` – idle standing sprite
- `s_player_right` – walking animation
- `s_player_jump` – airborne sprite
- `s_player_slide` – wall-slide sprite
- `s_player_attack` – attack animation
- `s_enemy` – enemy sprite
- `s_solid` – static terrain tile
- `s_diamond` – collectible gem sprite
- `s_hitbox` – debug hitbox overlay
- `s_room_warp` – warp zone indicator
- `s_creation_block` – player-placed solid block
- `s_bg` / `s_bg_sky` / `s_bg_clouds_behind` / `s_bg_clouds_front` – parallax layers
- `s_fg` / `s_mg` / `s_mg_city` / `s_mg_silhoette` – foreground / midground layers

Some scenes may still use simple `ColorRect` placeholder visuals where sprites
have not yet been imported or wired up.

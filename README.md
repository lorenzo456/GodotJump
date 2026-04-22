# Godot Jump

A browser-based endless side-scroller built with Godot 4 and exported to WebAssembly. Dodge obstacles, survive as long as possible, and spend your Ludo Health points on power-ups.

## Gameplay

- Obstacles scroll toward the player from the right at increasing difficulty
- Jump by pressing **Space**, clicking, or tapping the screen (mobile-friendly)
- Your score is the number of obstacles you clear — beat your personal best to set a new high score
- Each run consumes one use of your equipped item (if any)

## Shop & Ludo Health Points

Items in the shop are purchased using points earned through the [Ludo Health](https://ludohealth.com) platform. By completing real-world health activities — such as workouts, steps, or other wellness challenges — you accumulate points in the Ludo Health app. Sign in to your Ludo Health account in-game and your points balance is automatically synced as your in-game currency, letting you spend the rewards of your healthy lifestyle on power-ups.

### Available items

| Item | Cost | Effect |
|---|---|---|
| Shortened Jump | 30 pts | Reduces jump height for more precise control |
| Double Lives | 75 pts | Start each run with an extra life and a brief invincibility window on hit |
| Movement Speed | 50 pts | Increases scroll speed for a harder challenge |

## Ludo Health Integration

- **Sign in** from the main menu using your Ludo Health email and password
- Your points balance is fetched from the Ludo Health API and used as your in-game currency
- Purchasing an item posts the spend back to Ludo Health as an activity, keeping your balance in sync
- Sign out at any time from the main menu

## Project Structure

```
scripts/
  playermovement.gd     # Physics, jumping, lives, invincibility
  obstacle.gd           # Individual obstacle setup
  obstacle_spawner.gd   # Spawning, scrolling, scoring
  gameplay.gd           # In-game HUD (equipped item display)
  game_over_screen.gd   # End-of-run screen, high score update
  main_menu.gd          # Menu, auth status, Ludo Health score fetch
  login.gd              # Ludo Health sign-in flow
  shop.gd               # Item browsing, purchasing, equipping
  save_data.gd          # Local persistence (coins, high score, items, auth)
scenes/                 # Godot scene files
build/                  # Exported WebAssembly build
```

## Building & Deploying

The game is exported as a web build. The `build/` directory contains the compiled output and can be served as a static site.

Run `deploy.bat` to push the latest build.

## Backend

All API calls point at the Ludo Health backend hosted on Railway. No backend setup is required to play — just sign in with an existing Ludo Health account.

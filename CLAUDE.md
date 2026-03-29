# GamingLibrary — Project Brief

## What This Is
A Flutter package containing a library of mini-games with shared leaderboards.
Built as a POC by the PM, intended to be integrated into the main mobile app.
Claude acts as Senior Fullstack Developer. PM provides requirements, Claude builds.

## Role
- **PM (Harold):** Provides requirements, approves work, manages JIRA tickets
- **Claude:** Senior Fullstack Developer — designs, builds, opens PRs
- **Tech Team:** Code review + merge to develop/main
- **QA:** Tests features before merge

## Tech Stack
- Flutter (Dart) — package structure
- Supabase (Postgres) — same project as Statboard
- Riverpod — state management
- shared_preferences — local nickname cache
- google_fonts — typography
- go_router — navigation

## Supabase
- Project URL: https://detqfthnqyxibbliqmce.supabase.co
- Anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRldHFmdGhucXl4aWJibGlxbWNlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2NjY4MDIsImV4cCI6MjA5MDI0MjgwMn0.rRgnvcdm5vLVQfZlnUx3ahGobmW9BtRkQNzwQSJvrb4
- Tables: player_profiles, leaderboard

## Database Schema
```sql
player_profiles (user_id uuid PK, nickname text UNIQUE, created_at timestamptz)
leaderboard (id uuid PK, user_id uuid FK, game_id text, score int, metadata jsonb, created_at timestamptz)
```

## Design Tokens
- Background: #112756 (navy blue)
- Primary accent: #5078FF (blue)
- Success/correct: #39B402 (green)
- Warning/partial: #FFC10A (amber)
- Error/wrong: #FF325F (red)
- Theme: Dark arcade aesthetic
- Fonts/logo assets to be provided later

## Project Structure
```
gaming_library/
├── lib/
│   ├── gaming_library.dart         ← public entry point (GamingLibrary.launch)
│   └── src/
│       ├── core/
│       │   ├── theme/app_theme.dart
│       │   ├── models/             ← player.dart, score_entry.dart
│       │   └── services/           ← supabase_service.dart, nickname_service.dart, providers.dart
│       ├── screens/
│       │   ├── games_hub_screen.dart
│       │   ├── nickname_screen.dart
│       │   └── leaderboard_screen.dart
│       └── games/
│           ├── wordle/             ← wordle_screen.dart, wordle_game.dart, word_list.dart
│           └── memory/             ← (phase 2)
└── example/                        ← demo app with dummy homepage
    └── lib/main.dart
```

## Integration with Main App
```dart
// In main app's pubspec.yaml
gaming_library:
  path: ../gaming_library  // local, or git URL for team

// In homepage widget
GamingLibrary.launch(context, userId: currentUser.id);
```

## Games
### 1. CRYPTODLE (Wordle) — BUILT ✓
- 5-letter crypto/trading words
- 6 attempts, skill-based scoring (6pts for 1 guess → 1pt for 6)
- Daily word rotates based on date

### 2. Memory Grid — PHASE 2
- 4x4 grid, tiles flash, user recalls positions
- Gets harder each level (bigger grid, more tiles)

## Nickname System
- Set once on first launch, stored in player_profiles
- Changeable by user (edit button in Games Hub app bar)
- Validated: 3-20 chars, alphanumeric + underscore only
- Restricted word list TODO (see pending items)
- Cached locally via shared_preferences

## Scoring
- Wordle: 6pts (1 guess) → 5pts (2) → 4pts (3) → 3pts (4) → 2pts (5) → 1pt (6)
- Leaderboard: top 10 per game, nickname displayed (not real identity)

## GitHub
- Repo: https://github.com/hngadianpdax/GamingLibrary
- Branches: main (protected), develop (protected), feature/xxx (Claude works here)
- Workflow: Claude opens PR → tech team reviews → QA tests → tech team merges

## Branch Rules
- Claude NEVER pushes directly to main or develop
- All work goes on feature branches
- PRs always target develop first, then develop → main

## Pending Items
- [ ] Restricted nickname word list
- [ ] Brand logo and design assets
- [ ] Memory Grid game (phase 2)
- [ ] Wire real auth token from main app (currently uses userId only)
- [ ] Tighten Supabase RLS policies once real auth is integrated

## Running the Demo App
```bash
cd example && ~/flutter/bin/flutter run -d chrome     # browser
cd example && ~/flutter/bin/flutter run -d android    # Android emulator/device
cd example && ~/flutter/bin/flutter run -d ios        # iOS (needs Xcode)
```

## Notes
- RLS policies are currently open (allow all) for POC testing
- Demo uses fake userId: 00000000-0000-0000-0000-000000000001
- Flutter SDK at ~/flutter/bin/flutter (not on system PATH yet)

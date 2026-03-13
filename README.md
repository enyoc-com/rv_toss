# RV TOSS 🎲🚐

RV TOSS is a score‑keeping web app built with Flutter for a custom dice game inspired by PIG, using two physically modeled Class A RV dice.

The app is designed to be simple, readable, and hack‑friendly while accurately reflecting the real‑world behavior and rules of the game.

---

## What is RV TOSS?

RV TOSS is a push‑your‑luck dice game played with two custom, weighted RV‑shaped dice.

Each die represents a Class A motorhome and can land on:
- Wheels (upright)
- Roof
- Driver side
- Passenger side
- Ladder (rear)
- Windshield (front)

The game uses real‑world roll data gathered from physical dice to weight outcomes.

---

## Game Rules (Summary)

### Scoring
| Result | Points |
|------|--------|
| Wheels (upright) | 5 |
| Roof | 0 (turn ends) |
| Driver or passenger side | 1 |
| Ladder | 10 |
| Windshield | 10 |

### Bonuses
- **Double wheels**: +5 bonus points
- **Jackknife** (ladder + windshield): +10 bonus points

### Road Hazards
- **Hail‑storm** (double windshield): total score resets to 0
- **Roll‑over** (double roof): lose points for the current turn

### Winning
- When a player banks **100 or more points**, a final “fair‑ups” round begins
- All other players get **one final turn** to beat the leader
- Highest total score wins

---

## Features

- 2‑player prototype (designed to scale to 2–8 players)
- Editable player names
- Persistent player names between sessions
- Accurate weighted dice rolls based on physical testing
- Final fair‑ups round with visual indicators
- Reset confirmation dialog
- Built as a Flutter web app

---

## Tech Stack

- **Flutter** (web)
- **Dart**
- `shared_preferences` for local persistence
- Git + GitHub for version control

---

## Project Status

🚧 **Active prototype**

This project is under active development and is intentionally kept simple to support learning Flutter fundamentals and experimenting with game logic.

Future improvements may include:
- Player count selection (2–8 players)
- Dice graphics
- Animations
- Mobile builds
- Statistics / game history

---

## Running the App Locally

```bash
flutter pub get
flutter run -d chrome

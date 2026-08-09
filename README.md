# BurgerBandit

A fast food heist game where you play as a burglar sneaking into restaurants, stealing all the food you can carry -- and getting hilariously fat in the process. Designed by an 8-year-old, built with SpriteKit.

## The Story

You're a masked burglar in a green hoodie. Your mission: break into four fast food restaurants and steal as much food as possible. There's just one problem -- the more you eat, the fatter you get. And the fatter you get, the slower you move. Eventually you're so stuffed that the security guards can easily catch you. Greed is your greatest enemy.

## Restaurants

Each restaurant has its own unique layout, color scheme, food specialties, and security team:

| Restaurant | Inspired By | Colors | Specialty | Tagline |
|---|---|---|---|---|
| **Burger Barn** | McDonald's | Yellow / Red | Burgers & patties | *"Billions and Billions Stolen"* |
| **Queen Burger** | Burger King | Orange / Brown | Burgers & chicken | *"Have It Your (Stolen) Way"* |
| **Freckle's** | Wendy's | Red / White | Square burgers & drinks | *"Quality Is Our Recipe... For Theft"* |
| **Papa Rooster's** | Popeyes | Purple / Orange | Chicken & fries | *"Love That Chicken From Rooster's"* |

Restaurants are connected by side doors, so you can sneak between them during a heist.

## Gameplay

- **Virtual joystick** controls -- touch anywhere to move your burglar around the kitchen
- **Grab food** by running into it. Raw ingredients (patties, buns, condiments) are worth less. Finished food (burgers, fries, chicken, drinks) is worth more -- but makes you fatter faster
- **Dodge the guards** -- they patrol the kitchen and will chase you if you get too close. Getting caught deals health damage. Lose all your health and you lose a life. Lose all three lives and it's game over: **arrested**
- **Veggies** are super rare but heal you and give a big speed boost (the burglar does NOT want to eat vegetables, but sometimes you gotta)
- **Fat stages** -- as you eat, you grow through 4 stages of fatness. Your character visually expands, belly rolls appear, and your speed drops from full sprint to a sad waddle. At the final fat stage, an 8-second timer starts -- escape or get caught!

## Features

- **3 difficulty levels** (Easy / Medium / Hard) -- more guards, faster guards, bigger chase radius, and you get fat quicker
- **4 unique restaurant layouts** with themed kitchens, counters, and serving areas
- **Fat physics** -- your character literally grows bigger, with a larger collision radius and slower movement at each stage
- **Eating animations** with food crumbs flying everywhere and a satisfying squish-squash
- **Guard AI** -- guards patrol set routes and switch to chase mode when they spot you, with an alert indicator
- **Health system** -- guards deal damage on contact, eating food costs health (it's stolen, not exactly hygienic), veggies restore health
- **Speed boost** from rare veggie pickups, complete with a green glow effect
- **Damage feedback** -- red flash and blinking when guards hit you, plus invincibility frames
- **High score tracking**
- **Background music** with dynamic chase music when guards are after you

## Food Items

| Food | Points | Health | Rarity |
|---|---|---|---|
| Chicken | 30 | -10 | Uncommon |
| Burger | 25 | -15 | Uncommon |
| Fries | 20 | -12 | Uncommon |
| Drink | 15 | -8 | Uncommon |
| Raw Patty | 5 | -5 | Common |
| Bun | 3 | -3 | Common |
| Condiment | 2 | -2 | Common |
| VEGGIE??? | 50 | +12 | Extremely Rare |

## Tech

- **Platform:** iOS 17+, iPhone and iPad (landscape only)
- **Engine:** SpriteKit (pure Swift, no external dependencies)
- **Architecture:** Scene-based (MainMenu, Game, GameOver, HighScore) with singleton GameState
- **Build:** XcodeGen (`project.yml`)
- **Version:** 0.3.0

## Things to Try

1. **Launch the game and start a heist at Burger Barn** — use the virtual joystick to run into burgers and watch your character's belly grow visually between each fat stage; the collision radius expands as you get fatter.
2. **Keep eating until you reach the final fat stage** — an 8-second countdown timer appears on screen; sprint for the exit door before it hits zero or the guards will catch you instantly.
3. **Find a rare veggie pickup (green glow)** — your burglar flashes green, gets a big speed boost, and a portion of health refills; worth hunting even though the burglar hates vegetables.
4. **Let a guard spot you and trigger chase mode** — dynamic music switches to the chase track, the guard's alert indicator appears above their head, and they path toward you; outrun them back past the patrol boundary to end the chase.
5. **Pick a different restaurant from the main menu and compare** — each of the four is playable from the start, with its own kitchen layout, guard patrol pattern, food specialty, and color scheme; compare high scores across difficulty levels.

## Building

```bash
# Generate the Xcode project
xcodegen generate

# Open in Xcode
open BurgerBandit.xcodeproj
```

Build and run on an iOS 17+ device or simulator in landscape orientation.

## Support

If you like seeing this kind of thing get built and shared, [donations are always welcome](https://www.alexcoulombepresents.com/support) — they buy hardware, render time, and the freedom to keep giving most of this away.

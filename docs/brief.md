# Monone: Product Brief (draft v1)

Drafted 2026-10-16 from the product request and what the code does today. Anything marked TODO is not decided. Edit freely; this file is the source of truth.

## One-liner
An iOS social map for discovering and sharing organic local "spots": places people recommend, rate and photograph, seen on one shared map. Built by two people.

## Core structure (decided; don't change without discussion)
One map is the main screen. Each tab is a filter on that map:
- **Home**: all spots
- **Trending**: trending spots
- **Friends**: spots from people I follow, with their profile pictures as the pins
- **Profile**: my spots

## What exists today (from the code)
- Email and password sign-up with an optional username and profile picture (Firebase Auth)
- Create a spot: name, address, comment, star rating, photos, coordinates, and an activity type
- Activity types today: Smoke, Date, Photography, Train Station
- Map screen showing a pin for every spot, plus a button that toggles between all spots and my spots
- Photos stored in Firebase Storage; spots and users in Firestore

## Not built yet
- Following and the Friends filter
- Trending
- Ratings and comments from people other than the poster (ratings are stored, but there is no UI for it that I've confirmed)
- Moderation: report, block, content filtering
- Account deletion

## Target user
TODO: who is this for first? (one specific group and city, not "everyone")

## Core loop
TODO: how someone finds a spot, goes there, posts it, and why a friend then opens the app.

## Competitor: Corner
TODO: what Corner does well, and what we do differently.

## Open ideas (honest opinion wanted)
- Group hangout chat: MVP or later?
- Spotify song-per-spot playlists: cohesive or distracting?

## Spot categories
TODO: the original "smoke spots" category. Keep, rename, or cut before App Store submission? (App Review risk; see Phase 2.)

## Launch target
TODO: target month and hours per week for each of the two of you.

## Open questions for Phase 3
- What counts as "trending" (time window, saves, ratings)?
- Are spots public by default, or friends-only?
- Is visit verification (proving someone actually went) in the MVP?
- Is the Prism camera feature part of the MVP?

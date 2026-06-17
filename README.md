# RailRadar

A live train tracker for Indian Railways, built with Flutter. Search any train,
follow its running status station by station, check a PNR, find trains between two
stations, and read a live arrival/departure board for any station.

## Features

- **Live running status** — station-by-station timeline with delay, ETA and a journey progress bar that updates while you watch.
- **Train search** — by number or name, with recent searches.
- **PNR status** — coach/berth, booking vs current status, chart-prepared state.
- **Trains between stations** — direct trains with segment timings and classes.
- **Station board** — arrivals and departures with live delays and platforms.
- **Saved trains** — star a train for one-tap access.
- Light / dark / system theme.

## Running it

```
flutter pub get
flutter run
```

Requires Flutter 3.32+ (Dart 3.12).

## Data

The app ships with a sample timetable (real trains and stations) and a simulated
live-tracking engine so every screen is usable without a backend. All data access
goes through a single class, `RailRepository` (`lib/data/repository.dart`). To go
live, replace its method bodies with calls to a real source (NTES / IRCTC partner
API) — the screens depend only on the model types in `lib/models.dart`, so nothing
else has to change.

## Layout

```
lib/
  main.dart            app + theme wiring
  root_shell.dart      bottom navigation
  models.dart          domain types
  data/                seed timetable + repository (the swap point)
  state/               favorites, recents, theme (persisted)
  screens/             home, search, detail, pnr, between, board, saved, settings
  widgets/             shared cards, chips, pickers
```

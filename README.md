# Recipe Search Mobile

Android-first mobile recipe search app for large local recipe datasets.

The project goal is simple: connect a recipe dataset, search recipes by title and ingredients, exclude unwanted ingredients, show the first results quickly, and open a clean recipe view.

## Current milestone

This first skeleton includes:

- Flutter app source code.
- Android-first UI flow.
- Demo dataset embedded in the app.
- Dataset connection screen.
- Search by title/text.
- Required ingredient chips.
- Excluded ingredient chips.
- Paginated results: 10 recipes per page.
- Recipe detail screen with ingredients and numbered instructions.

The next milestone will add real dataset selection and local import:

```text
Choose dataset
  -> copy JSONL/SQLite into app storage
  -> show first streamed results
  -> build local SQLite/FTS index in background
```

## Run locally

If the repository does not yet contain generated platform folders, run:

```bash
flutter create . --platforms=android,linux
flutter pub get
```

Linux desktop preview:

```bash
flutter run -d linux
```

Android device preview:

```bash
flutter devices
flutter run -d <device-id>
```

## Dataset policy

Large datasets are not committed to this repository.

The real translated Recipe1M-derived dataset can stay local and later be imported by the app or converted into an optimized SQLite database.

Supported target formats planned:

- `.jsonl` for universal streaming import.
- `.sqlite` / `.db` for fast indexed search.

## Repository layout

```text
lib/                  Flutter app source
examples/             Tiny demo data only
docs/                 Architecture and dataset notes
tools/                Future dataset builders/import helpers
data/                 Local-only datasets; ignored by Git
```

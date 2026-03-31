# my_birthday_app

A Flutter birthday app with a custom multi-screen story, mini-games, and media-heavy gift reveals.

## Run locally

```bash
flutter pub get
flutter run
```

## Build for web

For a local production-style web build:

```bash
flutter build web --release --base-href "/my_birthday_app/"
```

## Deploy to GitHub Pages

This repo includes a GitHub Actions workflow at `.github/workflows/deploy-pages.yml`.

After you push the project to GitHub:

1. Open the repository on GitHub.
2. Go to `Settings` -> `Pages`.
3. Under `Source`, select `GitHub Actions`.
4. Push to the `main` branch.
5. Wait for the `Deploy Flutter Web to GitHub Pages` workflow to finish.

The live URL will usually be:

```text
https://YOUR_USERNAME.github.io/YOUR_REPO/
```

If the repository name is `YOUR_USERNAME.github.io`, then the site URL will be:

```text
https://YOUR_USERNAME.github.io/
```

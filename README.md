# Feature Flags Manager

An Edge/Chrome (Manifest V3) browser extension to manage feature flags on
**any website** through a simple popup UI instead of hand-editing the URL.

It reads the current tab's query string, lets you toggle/edit each flag, and
applies your selection by navigating the tab. Works on any `http`/`https` page.

> Clean-room re-implementation inspired by the "Azure Feature Flags Management"
> extension. Not affiliated with or derived from the original author's code.

## What it does

- Reads the current tab's query string and lists each `name=value` pair as a feature flag.
- Checkbox toggles whether a flag is applied.
- Star marks a flag as a **favorite** so it always appears in the list (even when not in the URL).
- Save button stores the current value of a flag to favorites.
- Trash button removes a flag row (and the favorite, if starred).
- **Go!** rebuilds the URL from the checked flags and navigates the current tab.
- **Add feature flag** inserts a new empty row.

Favorites are stored locally via `chrome.storage.local`. The extension collects no data. See the privacy policy: https://mzoabi.github.io/feature-flags-manager/privacy-policy

## Load it locally (unpacked)

1. Open `edge://extensions` (or `chrome://extensions`).
2. Enable **Developer mode**.
3. Click **Load unpacked** and select this `feature-flags-manager` folder.
4. Pin the extension and open it on any web page.

## Regenerate icons

Icons are produced from a script (no binaries checked in required):

```pwsh
pwsh -File tools/generate-icons.ps1
```

## Package for publishing

Build the publishable ZIP (with `manifest.json` at the root) into `dist/`:

```pwsh
npm install   # first time only
npm run build
```

This produces `dist/feature-flags-manager.zip`, ready to upload to either store.

### Publish to Microsoft Edge Add-ons

1. Go to the [Partner Center Edge program](https://partner.microsoft.com/dashboard/microsoftedge/).
2. Create a new extension submission and upload `dist/feature-flags-manager.zip`.
3. Fill in listing details, privacy (no data collected), and submit for certification.

### Publish to Chrome Web Store

1. Go to the [Chrome Web Store Developer Dashboard](https://chrome.google.com/webstore/devconsole/).
2. Create a new item and upload the same `dist/feature-flags-manager.zip`.
3. Complete the listing and submit for review.

## Project layout

```
feature-flags-manager/
  manifest.json        # MV3 manifest
  src/
    icons/             # generated PNG icons
    popup.html         # popup UI
    popup.css          # styles
    popup.js           # logic (parse/merge/apply flags, favorites)
  store/               # listing text, 300x300 logo, screenshots
  tools/
    generate-icons.ps1       # icon generator
    generate-store-logo.ps1  # store logo generator
    build-zip.mjs            # npm build script (npm run build)
  package.json
```

# Microsoft Edge Add-ons — Store Listing Content

Copy/paste these into Partner Center when submitting.

## Category
Developer tools

## Single purpose
Manage feature flags through the URL query string on any website via a simple popup UI.

## Short description
Easily view, toggle, and apply feature flags via the URL query string on any website, using a simple popup UI instead of editing the URL by hand.

> Note: the short description comes from the `description` field in `manifest.json`. To change it, edit the manifest and re-upload the package.

## Description (min 250 characters)
Feature Flags Manager lets you view, toggle, and apply feature flags on any website without hand-editing the URL query string.

When you open the popup on any http or https page, the extension reads the current URL and lists every query parameter as a name and value pair. Use the checkbox to include or exclude a flag, edit values inline, then click Go! to rebuild the URL and reload the page with your selection.

Save frequently used flags as favorites so they always appear — even when they aren't in the current URL — and update their stored value with a single click. Add brand-new flags on the fly, or remove the ones you no longer need.

All favorites are stored locally in your browser. The extension collects no data and sends nothing to external servers.

## Permission justifications
- **tabs** — Read the active tab's URL to parse the current feature flags, and update the tab's URL to apply the selected flags when the user clicks Go!.
- **storage** — Persist the user's favorite feature flags locally (chrome.storage.local) so they remain available across sessions.

No host permissions are requested — the extension uses only the `tabs` API and `chrome.tabs.update`, so it needs no per-site access.

## Remote code
No — the extension is Manifest V3 and executes no remotely hosted code.

## Data usage
No user data is collected, used, or transferred.

## Search terms (optional, max 7)
feature flags, query params, url flags, developer tools, query string

## Assets
- **Logo:** `store/logo-300.png` (300 x 300)
- **Screenshot:** use the popup screenshot (640 x 480 or 1280 x 800)

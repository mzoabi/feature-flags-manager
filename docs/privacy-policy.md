# Privacy Policy

Effective date: July 1, 2026

Feature Flags Manager is a browser extension for viewing, editing, and applying URL query parameters on the current web page. This policy explains what information the extension handles and how it is used.

## Data Collection

Feature Flags Manager does not collect, sell, share, transmit, or remotely store personal information or browsing data.

## Data Stored Locally

The extension may store favorite feature flag names and values in your browser using `chrome.storage.local`. This information remains on your device and is used only to show your saved flags in the extension popup.

You can remove saved flags from the extension popup, or clear the extension's local storage through your browser settings.

## Current Tab Access

When you open the popup, the extension reads the URL query string of the active `http` or `https` tab so it can display existing query parameters as editable feature flags. When you choose to apply changes, the extension rebuilds the URL query string and navigates the current tab to that updated URL.

This URL information is processed locally in your browser and is not sent to any server.

## Permissions

The extension uses these browser permissions:

- `tabs`: to read and update the active tab URL when applying feature flag changes.
- `storage`: to save favorite feature flags locally in your browser.

## Third Parties

Feature Flags Manager does not use analytics, advertising, tracking services, or third-party data processors.

## Changes to This Policy

This policy may be updated if the extension's behavior changes. Updates will be reflected in this file with a new effective date.

## Contact

For questions about this privacy policy, contact the extension publisher through the store listing where you installed the extension.

# tamer-display-browser

Open URLs in the system browser for Lynx. Supports in-app auth sessions (OAuth callback handling).

## Installation

```bash
npm install tamer-display-browser
```

Add to your app's dependencies and run `t4l link`.

## Usage

```ts
import { openBrowserAsync, openAuthSessionAsync, dismissBrowser } from 'tamer-display-browser'

// Open URL in system browser
const result = await openBrowserAsync('https://example.com')
if (result.type === 'opened') {
  // Browser opened
}

// OAuth flow: open auth URL, capture redirect
const authResult = await openAuthSessionAsync(
  'https://auth.example.com/authorize?...',
  'myapp://auth/callback'
)
if (authResult.type === 'success' && authResult.url) {
  // User completed auth; url contains redirect with code
}

// Dismiss in-app browser (if applicable)
await dismissBrowser()
```

## API

| Method | Returns | Description |
|--------|---------|-------------|
| `openBrowserAsync(url)` | `Promise<{ type: string }>` | Open URL in system browser |
| `openAuthSessionAsync(url, redirectUrl)` | `Promise<AuthSessionResult>` | Open auth URL; captures redirect. `AuthSessionResult`: `{ type: 'success', url }` or `{ type: 'cancel' }` or `{ type: 'dismiss' }` |
| `dismissBrowser()` | `Promise<{ type: string }>` | Dismiss in-app browser |

## Platform

Uses **lynx.ext.json**. Run `t4l link` after adding to your app.

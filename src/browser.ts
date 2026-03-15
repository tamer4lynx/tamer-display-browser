'background only'

import { addEventListener } from 'tamer-linking'
import type { AuthSessionResult } from './browser.types.js'

declare const NativeModules: {
  DisplayBrowserModule?: {
    openBrowserAsync(url: string, optionsJson: string, callback: (result: string) => void): void
    openAuthSessionAsync?(url: string, redirectUrl: string | null, callback: (result: string) => void): void
    dismissBrowser?(callback: (result: string) => void): void
  }
}

export async function openBrowserAsync(url: string): Promise<{ type: string }> {
  return new Promise((resolve) => {
    const mod = NativeModules?.DisplayBrowserModule
    if (!mod?.openBrowserAsync) {
      resolve({ type: 'unavailable' })
      return
    }
    mod.openBrowserAsync(url, '{}', (result: string) => {
      try {
        resolve(JSON.parse(result || '{}'))
      } catch {
        resolve({ type: 'opened' })
      }
    })
  })
}

export async function openAuthSessionAsync(url: string, redirectUrl: string | null): Promise<AuthSessionResult> {
  const mod = NativeModules?.DisplayBrowserModule
  if (mod?.openAuthSessionAsync) {
    return new Promise((resolve) => {
      mod.openAuthSessionAsync!(url, redirectUrl, (result: string) => {
        try {
          const r = JSON.parse(result || '{}')
          if (r.url) resolve({ type: 'success', url: r.url })
          else if (r.type === 'cancel') resolve({ type: 'cancel' })
          else resolve({ type: 'dismiss' })
        } catch {
          resolve({ type: 'dismiss' })
        }
      })
    })
  }
  return openAuthSessionPolyfill(url, redirectUrl)
}

async function openAuthSessionPolyfill(url: string, redirectUrl: string | null): Promise<AuthSessionResult> {
  const redirectPromise = new Promise<AuthSessionResult>((resolve) => {
    const sub = addEventListener('url', (event: { url?: string }) => {
      const u = event?.url
      if (u && redirectUrl && u.startsWith(redirectUrl)) {
        sub.remove()
        resolve({ type: 'success', url: u })
      }
    })
    setTimeout(() => {
      sub.remove()
      resolve({ type: 'dismiss' })
    }, 300000)
  })
  openBrowserAsync(url)
  return redirectPromise
}

export function dismissBrowser(): void {
  NativeModules?.DisplayBrowserModule?.dismissBrowser?.(() => {})
}

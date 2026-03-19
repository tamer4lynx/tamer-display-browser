declare var NativeModules: {
  DisplayBrowserModule?: {
    openBrowserAsync(url: string, optionsJson: string, callback: (result: string) => void): void
    openAuthSessionAsync?(url: string, redirectUrl: string | null, callback: (result: string) => void): void
    dismissBrowser?(callback: (result: string) => void): void
  }
}

import Foundation
import Lynx
import SafariServices
import AuthenticationServices

@objcMembers
public final class DisplayBrowserModule: NSObject, LynxModule {

    @objc public static var name: String { "DisplayBrowserModule" }

    @objc public static var methodLookup: [String: String] {
        [
            "openBrowserAsync": NSStringFromSelector(#selector(openBrowserAsync(_:optionsJson:callback:))),
            "openAuthSessionAsync": NSStringFromSelector(#selector(openAuthSessionAsync(_:redirectUrl:callback:))),
            "dismissBrowser": NSStringFromSelector(#selector(dismissBrowser(_:)))
        ]
    }

    private var authSession: ASWebAuthenticationSession?

    @objc public init(param: Any) { super.init() }
    @objc public override init() { super.init() }

    @objc func openBrowserAsync(_ url: String, optionsJson: String, callback: @escaping (String) -> Void) {
        guard let urlObj = URL(string: url), urlObj.scheme == "http" || urlObj.scheme == "https" else {
            callback(createJSON(["type": "cancel", "error": "Invalid URL"]))
            return
        }
        DispatchQueue.main.async {
            let vc = SFSafariViewController(url: urlObj)
            UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true) {
                callback(self.createJSON(["type": "opened"]))
            }
        }
    }

    @objc func openAuthSessionAsync(_ url: String, redirectUrl: String?, callback: @escaping (String) -> Void) {
        guard let urlObj = URL(string: url), urlObj.scheme == "http" || urlObj.scheme == "https" else {
            callback(createJSON(["type": "cancel", "error": "Invalid URL"]))
            return
        }
        let scheme = redirectUrl.flatMap { URL(string: $0) }?.scheme
        DispatchQueue.main.async {
            self.authSession = ASWebAuthenticationSession(
                url: urlObj,
                callbackURLScheme: scheme,
                completionHandler: { [weak self] callbackURL, error in
                    self?.authSession = nil
                    if let url = callbackURL {
                        callback(self?.createJSON(["type": "success", "url": url.absoluteString]) ?? "{}")
                    } else {
                        callback(self?.createJSON(["type": "cancel"]) ?? "{}")
                    }
                }
            )
            self.authSession?.prefersEphemeralWebBrowserSession = false
            self.authSession?.presentationContextProvider = self
            self.authSession?.start()
        }
    }

    @objc func dismissBrowser(_ callback: @escaping (String) -> Void) {
        DispatchQueue.main.async {
            self.authSession?.cancel()
            self.authSession = nil
            callback(self.createJSON(["type": "dismiss"]))
        }
    }

    private func createJSON(_ dict: [String: Any]) -> String {
        (try? JSONSerialization.data(withJSONObject: dict)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"
    }
}

extension DisplayBrowserModule: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
}

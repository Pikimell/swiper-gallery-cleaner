import Foundation
import GoogleMobileAds
import UIKit

final class InterstitialAdManager: NSObject, FullScreenContentDelegate, ObservableObject {
    private var interstitial: InterstitialAd?
    private let adUnitID: String
    @Published var didDismissAd = false

    init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
        loadAd()
    }

    func loadAd() {
        let request = Request()
        InterstitialAd.load(with: adUnitID, request: request, completionHandler: { [weak self] ad, error in
            if let error = error {
                print("❌ Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            self?.interstitial?.fullScreenContentDelegate = self
        })
    }

    func showAd(from rootViewController: UIViewController, isSubscribed: Bool) {
        guard !isSubscribed else {
            didDismissAd = true
            return
        }
        guard let ad = interstitial else {
            print("⚠️ Interstitial ad is not ready yet.")
            loadAd()
            return
        }
        ad.present(from: rootViewController)
    }

    // MARK: - GADFullScreenContentDelegate

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Failed to present interstitial ad: \(error.localizedDescription)")
    }
    
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ Interstitial ad was dismissed.")
        didDismissAd = true
        loadAd()
    }
}

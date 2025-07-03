import Foundation
import GoogleMobileAds
import UIKit

final class RewardedAdManager: NSObject, FullScreenContentDelegate, ObservableObject {
    private var rewardedAd: RewardedAd?
    private let adUnitID: String

    init(adUnitID: String) {
        self.adUnitID = adUnitID
        super.init()
        loadAd()
    }

    // Завантаження реклами
    func loadAd() {
        let request = Request()
        RewardedAd.load(with: adUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("❌ Failed to load rewarded ad: \(error.localizedDescription)")
                return
            }
            self?.rewardedAd = ad
            self?.rewardedAd?.fullScreenContentDelegate = self
        }
    }

    // Показ винагороджувальної реклами
    func showAd(from rootViewController: UIViewController, rewardHandler: @escaping () -> Void) {
        guard let ad = rewardedAd else {
            print("⚠️ Rewarded ad is not ready yet.")
            loadAd()
            return
        }

        ad.present(from: rootViewController) {
            let reward = ad.adReward
            print("🎁 User earned reward: \(reward.amount) \(reward.type)")
            rewardHandler()
        }
    }

    // MARK: - Delegate methods

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("✅ Rewarded ad dismissed.")
        loadAd()
    }

    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("❌ Failed to present rewarded ad: \(error.localizedDescription)")
    }
}

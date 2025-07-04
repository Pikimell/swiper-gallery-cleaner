//
//  BannerAdView.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 01.07.2025.
//

import GoogleMobileAds
import SwiftUI

struct BannerAdView: View {
    @EnvironmentObject var storeKit: StoreKitManager
    let adUnitID: String

    var body: some View {
        Group {
            if !storeKit.isPremiumUser {
                BannerAdViewRepresentable(adUnitID: adUnitID)
                    .frame(height: 50)
            }
        }
    }
}

private struct BannerAdViewRepresentable: UIViewRepresentable {
    let adUnitID: String

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.rootViewController }
            .first
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}

#Preview {
    BannerAdView(adUnitID: "ca-app-pub-3940256099942544/2934735716")
        .environmentObject(StoreKitManager())
}

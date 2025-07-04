//
//  BannerAdView.swift
//  gallery-cleaner
//
//  Created by Володимир Пащенко on 01.07.2025.
//
import GoogleMobileAds
import SwiftUI

struct BannerAdView: UIViewRepresentable {
    let adUnitID: String
    @EnvironmentObject private var storeKit: StoreKitManager

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        guard !storeKit.isSubscribed else { return banner }
        banner.adUnitID = adUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first?.rootViewController }
            .first
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        uiView.isHidden = storeKit.isSubscribed
    }
}

#Preview {
    BannerAdView(adUnitID: "ca-app-pub-3940256099942544/2934735716") // тестовий ID
}

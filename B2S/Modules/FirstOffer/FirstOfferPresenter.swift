//
//  FirstOfferPresenter.swift
//  B2S
//
//  Created Egor Sakhabaev on 05.07.2021.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Sakhabaev Egor @Banck
//  https://github.com/Banck/Swift-viper-template-for-xcode
//

import UIKit
import StoreKit

final class FirstOfferPresenter {
    
    // MARK: - Properties
    weak private var view: FirstOfferView?
    var interactor: FirstOfferInteractorInput?
    private let router: FirstOfferWireframeInterface
    private let offer: Offer
    
    // MARK: - Initialization and deinitialization
    init(interface: FirstOfferView,
         interactor: FirstOfferInteractorInput?,
         router: FirstOfferWireframeInterface,
         offer: Offer) {
        self.view = interface
        self.interactor = interactor
        self.router = router
        self.offer = offer
    }
}

// MARK: - FirstOfferPresenterInterface
extension FirstOfferPresenter: FirstOfferPresenterInterface {
    func didSelectAction() {
        B2S.shared.delegate?.b2sPromotionOfferWillPurchase?(productId: offer.productId, offerId: offer.offerId)
        view?.startLoading()
        interactor?.purchasePromotionOffer(productId: offer.productId, offerId: offer.offerId)
    }

    func didSelectClose() {
        B2S.shared.pendingOffer = nil
        router.navigate(to: .dismiss)
    }

    func keyReplacement(offerText: String, product: SKProduct) -> String {
        var replacedOfferText: String = offerText
        if replacedOfferText.contains(OfferStringKeys.actual_price.rawValue) {
            replacedOfferText = replacedOfferText.replacingOccurrences(of: OfferStringKeys.actual_price.rawValue, with: "\(product.localizedPrice ?? "")")
        }
        if replacedOfferText.contains(OfferStringKeys.discount_price.rawValue) && product.discounts.first != nil {
            replacedOfferText = replacedOfferText.replacingOccurrences(of: OfferStringKeys.discount_price.rawValue, with: "\(product.discounts.first!.price.stringValue)" + " \(product.discounts.first!.priceLocale.currencySymbol!)")
        }
        return replacedOfferText
    }
    
    // MARK: - Lifecycle -
    func viewDidLoad() {
        view?.display(image: offer.screenData.image,
                      title: offer.screenData.title,
                      subtitle: offer.screenData.subtitle,
                      footer: offer.screenData.footer,
                      offer: offer.screenData.offer,
                      promotionButton: offer.screenData.promotionButton,
                      background: (image: offer.screenData.backgroundImage,
                                   color: offer.screenData.backgroundColor),
                      productId: offer.productId)
    }
    
    func viewDidAppear() {
        B2S.shared.delegate?.b2sScreenDidAppear?()
    }
    
    func viewDidDisappear() {
        B2S.shared.pendingOffer = nil
        B2S.shared.delegate?.b2sScreenDidDismiss?()
    }
}

// MARK: - FirstOfferInteractorOutput
extension FirstOfferPresenter: FirstOfferInteractorOutput {
    func purchasedPromotionOffer(with transaction: SKPaymentTransaction, offerData: (productId: String, offerId: String)) {
        B2S.shared.delegate?.b2sPromotionOfferDidPurchase?(productId: offerData.productId, offerId: offerData.offerId, transaction: transaction)
        router.navigate(to: .dismiss)
    }
    
    func purchasedPromotionOffer(with error: Error, offerData: (productId: String, offerId: String)) {
        let errorCode = (error as? SKError)?.code ?? .unknown
        B2S.shared.delegate?.b2sPromotionOfferDidFailPurchase?(productId: offerData.productId, offerId: offerData.offerId, errorCode: errorCode)
    }
    
    func fetchedFully() {
        view?.stopLoading()
    }
}
extension SKProduct {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter
    }()
    var isFree: Bool {
        price == 0.00
    }
    var localizedPrice: String? {
        guard !isFree else {
            return nil
        }
        let formatter = SKProduct.formatter
        formatter.locale = priceLocale
        return formatter.string(from: price)
    }
}

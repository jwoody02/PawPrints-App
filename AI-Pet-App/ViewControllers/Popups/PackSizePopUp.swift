//
//  PackSizePopUp.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/15/23.
//

import Foundation
import UIKit
import StoreKit
import PanModal

class PackSizePopUp: UIViewController, PanModalPresentable {
    override func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let myProduct = response.products
        for product in myProduct {
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
            iapProducts.append(product)
        }
        DispatchQueue.main.async {
            
                self.addPackWith(product: self.iapProducts[1])
            self.addPackWith(product: self.iapProducts[0])
            
            
        }

    }
    func addPackWith(product: SKProduct) {
        // create the following ui components:
        // - image: checkmark, hidden if not currently selected via currentlySelected
        // - label: e.g. "Sample Pack (6 images)"
        // - label: e.g. "$1.99"

        let checkmark = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        checkmark.tintColor = Constants.primaryColor.hexToUiColor()
        if product.productIdentifier != currentlySelected {
            checkmark.isHidden = true
        }
        checkmark.contentMode = .scaleAspectFit
        checkmark.alpha = 0
        checkmark.frame = CGRect(x: 20, y: getLastViewMaxY() + 40, width: 25, height: 30)
        self.view.addSubview(checkmark)

        let packNameLabel = UILabel()
        packNameLabel.text = product.localizedTitle
        packNameLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        packNameLabel.textColor = Constants.textColor.hexToUiColor()
        packNameLabel.textAlignment = .left
        packNameLabel.alpha = 0
        packNameLabel.frame = CGRect(x: checkmark.frame.maxX + 20, y: checkmark.frame.minY - 5, width: 200, height: 20)
        self.view.addSubview(packNameLabel)

        let packPriceLabel = UILabel()
        packPriceLabel.text = "$\(product.price)"
        packPriceLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        packPriceLabel.textColor = .gray
        packPriceLabel.alpha = 0
        packPriceLabel.textAlignment = .left
        packPriceLabel.frame = CGRect(x: checkmark.frame.maxX + 20, y: packNameLabel.frame.maxY + 5, width: 200, height: 20)
        self.view.addSubview(packPriceLabel)

        let button = UIButton()
        button.frame = CGRect(x: 0, y: checkmark.frame.minY - 10, width: self.view.frame.width, height: 50)
        button.addTarget(self, action: #selector(didSelectPackSize), for: .touchUpInside)
        button.tag = product.productIdentifier == small_pack_id ? 0 : 1
        self.view.addSubview(button)

        UIView.animate(withDuration: 0.3, delay: 0.1, options: .curveEaseOut, animations: {
            checkmark.alpha = 1
            packNameLabel.alpha = 1
            packPriceLabel.alpha = 1
        }, completion: nil)
    }
    func getLastViewMaxY() -> CGFloat {
        return self.view.subviews.last?.frame.maxY ?? 0
    }
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("Transaction completed successfully")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .failed:
                print("Transaction Failed")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .restored:
                print("Already Purchased")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }
    
    // MARK: - Public API
    var small_pack_id = "pawprintsai.smallpack"
    var large_pack_id = "pawprintsai.largepack"
    var product: SKProduct?
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var packSize = 0
    var currentlySelected = "pawprintsai.largepack"
    func getInAppPurchaseProducts() {
        if SKPaymentQueue.canMakePayments() {
            let productID: NSSet = NSSet(objects: small_pack_id, large_pack_id)
            productsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
            productsRequest.delegate = self
            productsRequest.start()
//            SKPaymentQueue.default().add(self)
        } else {
            print("can't make purchases")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = Constants.backgroundColor.hexToUiColor()
        // get products
        getInAppPurchaseProducts()
    }
    // did select new pack size
    @objc func didSelectPackSize(sender: UIButton) {
        let packSize = sender.tag
        // update currently selected
        if packSize == 0 {
            currentlySelected = small_pack_id
            self.parentVC?.setSelected(product: iapProducts[1])
        } else {
            currentlySelected = large_pack_id
            self.parentVC?.setSelected(product: iapProducts[0])
        }
        // dismiss view
        self.dismiss(animated: true, completion: nil)
    }
    // MARK: - Public API
    var panScrollable: UIScrollView? {
        return nil
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(180)
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(180)
    }
    var anchorModalToLongForm: Bool {
        return false
    }
    var parentVC: UIViewController?
}

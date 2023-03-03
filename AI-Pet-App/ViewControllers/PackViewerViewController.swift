//
//  PackViewerViewController.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/2/23.
//

import Foundation
import UIKit
import Firebase
//import FMPhotoPicker
import StoreKit
import SwiftyStoreKit
import TransitionButton
import FirebaseFirestore
import TLPhotoPicker
import FirebaseAnalytics

// MARK: - PackViewerViewController
class PackViewerViewController: UIViewController {
    
    override func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Got products!")
        let myProduct = response.products
        for product in myProduct {
            print(product.productIdentifier)
            print(product.localizedTitle)
            print(product.localizedDescription)
            print(product.price)
        }
        
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
                print("Already purchased")
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            default:
                print(transaction.transactionState.rawValue)
            }
        }
    }

    // Pack size drop down
//    lazy var packSizeSelector: UIView {
//
//    }
    // MARK: - In App Purchases (pack1, pack2, pack3)
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var productID = "com.caliwoodusa.AI-Pet-App.pack1"
    var productID2 = "com.caliwoodusa.AI-Pet-App.pack2"
    var productID3 = "com.caliwoodusa.AI-Pet-App.pack3"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // in app purchases
//        SKPaymentQueue.default().add(self)
        
    }

    
}
class PackView: UIView {
    // MARK: - Properties
    var pack: Any?
    // MARK: - UI
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        // scroll view is size of view
        scrollView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        // content size is size of view
        scrollView.contentSize = CGSize(width: self.bounds.width, height: self.bounds.height)
        scrollView.backgroundColor = Constants.surfaceColor.hexToUiColor()
        return scrollView
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 17)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.text = "Pack Name"
        label.frame = CGRect(x: 20, y: 20, width: self.bounds.width - 40, height: 50)
        
        return label
    }()
    lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textColor = .gray
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.text = "Subtitle"
        label.frame = CGRect(x: 20, y: 20, width: self.bounds.width - 40, height: 50)
        
        return label
    }()
    lazy var packImageView: ShadowImageView = {
        let imageView = ShadowImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.imageCornerRaidus = 10
       imageView.blurRadius = 3
       imageView.shadowRadiusOffSetPercentage = 0
       imageView.shadowOffSetByX = 0
        // imageView.clipsToBounds = true
        imageView.isHidden = false
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .blue
        imageView.frame = CGRect(x: 30, y: 20, width: UIScreen.main.bounds.width - 60, height: 200)
        imageView.shadowAlpha = CGFloat(0.9)
        
        return imageView
    }()

    // description button to collapse/expand
    lazy var descriptionButton: UIButton = {
        let button = UIButton()
        button.setTitle("", for: .normal)
        button.setTitleColor(Constants.textColor.hexToUiColor(), for: .normal)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        button.backgroundColor = .clear
        button.frame = CGRect(x: 0, y: packImageView.frame.maxY + 20, width: self.bounds.width, height: 40)
       button.addTarget(self, action: #selector(descriptionButtonTapped), for: .touchUpInside)
        return button
    }()
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.text = "Description"
        label.frame = CGRect(x: 20, y: descriptionButton.frame.maxY, width: self.bounds.width - 40, height: 50)
        
        return label
    }()
    lazy var minusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "minus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .regular))
        imageView.isHidden = false
        imageView.tintColor = .gray
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = .clear
        imageView.frame = CGRect(x: 20, y: descriptionButton.frame.maxY + 20, width: 10, height: 10)
        return imageView
    }()
    var OGDescriptionHeight = 0
    lazy var actualDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 14)
        label.textColor = .gray
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.text = ""
        label.frame = CGRect(x: 20, y: minusImageView.frame.maxY, width: self.bounds.width - 40, height: 50)
        
        return label
    }()
    // view preview button
    lazy var viewPreviewButton: TransitionButton = {
        let button = TransitionButton()
        button.setTitle("View Preview   ", for: .normal)
        // button.setTitleColor(.gray, for: .normal)
        // button.backgroundColor = .lightGray.withAlphaComponent(0.2)
        // button.tintColor = .gray
        button.setTitleColor(Constants.surfaceColor.hexToUiColor(), for: .normal)
        button.backgroundColor = Constants.textColor.hexToUiColor()
        button.tintColor = Constants.surfaceColor.hexToUiColor()
        
        let image = UIImage(systemName: "arrow.right")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 14, weight: .bold))
        button.setImage(image, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        button.layer.cornerRadius = 10
        button.semanticContentAttribute = .forceRightToLeft
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        button.frame = CGRect(x: 20, y: actualDescriptionLabel.frame.maxY + 20, width: self.bounds.width - 40, height: 53)
        button.addTarget(self, action: #selector(viewPreviewButtonTapped), for: .touchUpInside)
        return button
    }()

    lazy var disclaimerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Regular", size: 12)
        label.textColor = .gray
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.text = "The order preview is an example order of this pack using one of our own pets and is an example of what you will receive, however, each order is unique and will not be exactly the same."
        label.frame = CGRect(x: 20, y: viewPreviewButton.frame.maxY + 20, width: self.bounds.width - 40, height: 70)
        
        return label
    }()
    func setupUI() {
        titleLabel.frame = CGRect(x: 20, y: 20, width: self.bounds.width - 40, height: 20)
        
        let padding = 20
        // add subviews
        packImageView.shadowAlpha = CGFloat(0.9)
        let shadowWidth = CGFloat(Int(frame.width) - (padding*2))
        let shadowHeight = shadowWidth * 0.6
        var hasDemoOrder = false
        if let pack = pack as? LimitedPack {
            packImageView.layoutWithViewSize(image: pack.featuredImage, width: shadowWidth, height: shadowHeight)
            titleLabel.text = pack.title
            subtitleLabel.text = pack.subtitle
             actualDescriptionLabel.text = pack.description
            if pack.demo_order != nil {
                hasDemoOrder = true
            }
        } else if let pack = pack as? VarietyPack {
            packImageView.layoutWithViewSize(image: pack.featuredImage, width: shadowWidth, height: shadowHeight)
            titleLabel.text = pack.title
            subtitleLabel.text = pack.subtitle
            actualDescriptionLabel.text = pack.description
            if pack.demo_order != nil {
                hasDemoOrder = true
            }
        }
        subtitleLabel.frame = CGRect(x: 20, y: titleLabel.frame.maxY, width: self.bounds.width - 40, height: 20)
        subtitleLabel.sizeToFit()
        subtitleLabel.frame = CGRect(x: 20, y: titleLabel.frame.maxY, width: self.bounds.width - 40, height: subtitleLabel.frame.height)

        packImageView.frame = CGRect(x: 10, y: 15, width: shadowWidth, height: shadowHeight)
        packImageView.center.x = self.frame.width / 2
        packImageView.center.y = (packImageView.frame.height / 2) + CGFloat(padding) + subtitleLabel.frame.maxY
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(subtitleLabel)
        scrollView.addSubview(packImageView)


        // add description button
        descriptionButton.frame = CGRect(x: 0, y: packImageView.frame.maxY + 20, width: self.bounds.width, height: 40)
        scrollView.addSubview(descriptionButton)
        // add description label
        descriptionLabel.frame = CGRect(x: 20, y: descriptionButton.frame.maxY, width: self.bounds.width - 40, height: 50)
        descriptionLabel.center.y = descriptionButton.center.y
        scrollView.addSubview(descriptionLabel)
        // add minus image
        minusImageView.frame = CGRect(x: self.bounds.width - 40, y: descriptionButton.frame.maxY + 20, width: 15, height: 15)
        minusImageView.center.y = descriptionButton.center.y
        scrollView.addSubview(minusImageView)
        
        // add actual description label
        actualDescriptionLabel.frame = CGRect(x: 20, y: minusImageView.frame.maxY + 10, width: self.bounds.width - 40, height: 50)
        // size to fit
        actualDescriptionLabel.sizeToFit()
        OGDescriptionHeight = Int(actualDescriptionLabel.frame.height)
        scrollView.addSubview(actualDescriptionLabel)

        // add view preview button
        viewPreviewButton.frame = CGRect(x: 20, y: actualDescriptionLabel.frame.maxY + 20, width: self.bounds.width - 40, height: 45)
        scrollView.addSubview(viewPreviewButton)

        // add disclaimer label
        disclaimerLabel.frame = CGRect(x: 20, y: viewPreviewButton.frame.maxY + 20, width: self.bounds.width - 40, height: 70)
        scrollView.addSubview(disclaimerLabel)

        // make scrollable to fit all content
        scrollView.contentSize = CGSize(width: self.bounds.width, height: disclaimerLabel.frame.maxY + 20)
        // frame is still same
        scrollView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        scrollView.showsVerticalScrollIndicator = false

        // 
        addSubview(scrollView)
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        self.layer.borderWidth = 1
        

        // check if we have a demo order
        if hasDemoOrder == false {
            // change view preview button to "No Preview Available" and change image to circle with line through it
            viewPreviewButton.setTitle("No Preview Available", for: .normal)
            viewPreviewButton.setImage(nil, for: .normal)
            viewPreviewButton.isUserInteractionEnabled = false
            viewPreviewButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            viewPreviewButton.setTitleColor(UIColor.lightGray.withAlphaComponent(0.5), for: .normal)
            viewPreviewButton.tintColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
    }
    // MARK: - Actions
    // description button tapped
    @objc func descriptionButtonTapped() {
        if self.minusImageView.image == UIImage(systemName: "minus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)) {
            
            OGDescriptionHeight = Int(actualDescriptionLabel.frame.height)
            // animate and transform minus into plus
            UIView.animate (withDuration: 0.2, animations: {
                self.minusImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                self.minusImageView.image = UIImage(systemName: "plus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .regular))
                // animate up actual description label
                self.actualDescriptionLabel.frame = CGRect(x: 20, y: self.minusImageView.frame.maxY + 10, width: self.bounds.width - 40, height: 0)
                self.viewPreviewButton.frame = CGRect(x: 20, y: self.actualDescriptionLabel.frame.maxY + 20, width: self.bounds.width - 40, height: 45)
                self.disclaimerLabel.frame = CGRect(x: 20, y: self.viewPreviewButton.frame.maxY + 20, width: self.bounds.width - 40, height: 50)
            }) { (success) in
            }
        } else {
            // animate and transform plus into minus
            UIView.animate (withDuration: 0.2, animations: {
                self.minusImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
                self.minusImageView.image = UIImage(systemName: "minus")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .regular))
                // animate down actual description label
                self.actualDescriptionLabel.frame = CGRect(x: 20, y: self.minusImageView.frame.maxY + 10, width: self.bounds.width - 40, height: CGFloat(self.OGDescriptionHeight))
                self.viewPreviewButton.frame = CGRect(x: 20, y: self.actualDescriptionLabel.frame.maxY + 20, width: self.bounds.width - 40, height: 45)
                self.disclaimerLabel.frame = CGRect(x: 20, y: self.viewPreviewButton.frame.maxY + 20, width: self.bounds.width - 40, height: 50)

            }) { (success) in
            }
        }
        
    }
    // view preview button tapped
    @objc func viewPreviewButtonTapped() {
        // show pack
        // showPack(pack: pack)
    }
}
class PackSettings {
    static let shouldHaveBackgroundGlow = true
}
extension UIViewController: SKProductsRequestDelegate {
    
    func addIdLabel(pack: Any) {
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        if let pack = pack as? LimitedPack {
            // invisible label used to hold our pack id
            let packIdLabel = UILabel()
            packIdLabel.text = pack.internal_id
            packIdLabel.alpha = 0
            packIdLabel.tag = 420
            topVC?.view.addSubview(packIdLabel)
            print("* Added packIdLabel to limited")
            // now add a label with the pack name
            let packNameLabel = UILabel()
            packNameLabel.text = pack.title
            packNameLabel.alpha = 0
            packNameLabel.tag = 421
            topVC?.view.addSubview(packNameLabel)

        } else if let pack = pack as? VarietyPack {
            // invisible label used to hold our pack id
            let packIdLabel = UILabel()
            packIdLabel.text = pack.internal_id
            packIdLabel.alpha = 0
            packIdLabel.tag = 420
            topVC?.view.addSubview(packIdLabel)
            print("* Added packIdLabel to variety")
            // now add a label with the pack name
            let packNameLabel = UILabel()
            packNameLabel.text = pack.title
            packNameLabel.alpha = 0
            packNameLabel.tag = 421
            topVC?.view.addSubview(packNameLabel)

        }
    }
    func removeIdLabel() {
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        topVC?.view.viewWithTag(420)?.removeFromSuperview()
        topVC?.view.viewWithTag(421)?.removeFromSuperview()
    }
    // new method of showing packs
    func showPack(pack: Any) {
        Analytics.logEvent("show_pack_popup", parameters: nil)
        self.addIdLabel(pack: pack)
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        let holderView = UIView()
        holderView.frame = (topVC?.view.frame)!
        holderView.backgroundColor = .clear
        holderView.alpha = 0
        holderView.isUserInteractionEnabled = true
        topVC?.view.addSubview(holderView)

        // vibration
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let shadowWidth = CGFloat(Int(self.view.frame.width) - (30*2))
        let shadowHeight = shadowWidth * 0.6
        let shadowImageView = ShadowImageView()
        if PackSettings.shouldHaveBackgroundGlow {
            // add a ShadowImageView so we can get a nice blur effect
            shadowImageView.frame = self.view.frame
            shadowImageView.alpha = 0
            shadowImageView.isUserInteractionEnabled = true
            shadowImageView.shadowAlpha = CGFloat(0.9)
            
            if let pack = pack as? LimitedPack {
                shadowImageView.layoutWithViewSize(image: pack.featuredImage, width: shadowWidth, height: shadowHeight)
            } else if let pack = pack as? VarietyPack {
                shadowImageView.layoutWithViewSize(image: pack.featuredImage, width: shadowWidth, height: shadowHeight)
            }
            shadowImageView.center.x = self.view.center.x
//            holderView.addSubview(shadowImageView)
        }
        // create view that blurs the entire screen
        UIGraphicsBeginImageContextWithOptions((view.frame.size), false, 0)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let imagze = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let blurryView = UIImageView()
        blurryView.frame = self.view.frame
        blurryView.image = imagze
        blurryView.alpha = 0
        // add to top viewcontroller
        blurryView.isUserInteractionEnabled = true
        holderView.addSubview(blurryView)
        holderView.fadeIn()
        var blurEffect = UIBlurEffect(style: .light)
        // check if dark mode is enabled
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                blurEffect = UIBlurEffect(style: .dark)
            }
        }
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.frame = view.bounds
        blurryView.addSubview(visualEffectView)
        // create close button in top right
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(systemName: "xmark")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)), for: .normal)
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.imageView?.tintColor = Constants.textColor.hexToUiColor()
        closeButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        closeButton.layer.borderWidth = 1
        // check if we have notch
        if #available(iOS 11.0, *) {
            if UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0 > 20 {
                closeButton.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: 70, width: 40, height: 40)
            } else {
                closeButton.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: 40, width: 40, height: 40)
            }
        } else {
            closeButton.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: 40, width: 40, height: 40)
        }
        // closeButton.frame = CGRect(x: UIScreen.main.bounds.width - 70, y: 70, width: 40, height: 40)
        closeButton.tintColor = Constants.textColor.hexToUiColor()
        closeButton.layer.cornerRadius = closeButton.frame.width/2
        closeButton.backgroundColor = Constants.surfaceColor.hexToUiColor()
        closeButton.isUserInteractionEnabled = true
        closeButton.addTarget(self, action: #selector(hidePack), for: .touchUpInside)
        blurryView.addSubview(closeButton)

        // create pack view
        let packView = PackView()
        packView.pack = pack
        // put pack view lower than close button
        // packView.frame = CGRect(x: 30, y: closeButton.frame.maxY + 20, width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.height - closeButton.frame.maxY - 200)
        // start packView below so we can animate it up
        packView.frame = CGRect(x: 30, y: closeButton.frame.maxY + 100, width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.height - closeButton.frame.maxY - 200)
        packView.layer.cornerRadius = 12
        packView.clipsToBounds = true
        packView.alpha = 0
        packView.center.x = blurryView.center.x
        packView.backgroundColor = Constants.surfaceColor.hexToUiColor()
        packView.setupUI()


        // create "place order" button
        let placeOrderButton = TransitionButton(type: .custom)
        placeOrderButton.setTitle("Place Order", for: .normal)
        placeOrderButton.setTitleColor(.white, for: .normal)
        placeOrderButton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        placeOrderButton.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 90, width: packView.frame.width - 10, height: 53)
        placeOrderButton.center.x = packView.center.x
        placeOrderButton.layer.cornerRadius = 10
        // add shadow
        placeOrderButton.layer.shadowColor = Constants.primaryColor.hexToUiColor().cgColor
        placeOrderButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        placeOrderButton.layer.shadowRadius = 4
        placeOrderButton.layer.shadowOpacity = 0.25
        placeOrderButton.tag = 68
        placeOrderButton.backgroundColor = Constants.primaryColor.hexToUiColor()
        // pass button into placeOrderPressed
        // placeOrderButton.addTarget(self, action: #selector(placeOrderPressed), for: .touchUpInside)
        placeOrderButton.addTarget(self, action: #selector(placeOrderPressed), for: .touchUpInside)
        blurryView.addSubview(placeOrderButton)



        
        // create two buttons for the two different types of orders
        let select_order_type = UIButton(type: .custom)
        // default order is large $4.99
        select_order_type.setTitle("Full Pack (30 images) - $3.99", for: .normal)
        select_order_type.setTitleColor(Constants.textColor.hexToUiColor(), for: .normal)
        select_order_type.contentHorizontalAlignment = .left
        select_order_type.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        select_order_type.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14)
        select_order_type.frame = CGRect(x: 0, y: placeOrderButton.frame.maxY - 110, width: packView.frame.width - 10, height: 40)
        select_order_type.center.x = packView.center.x
        select_order_type.layer.cornerRadius = 10
        // add shadow
        select_order_type.layer.shadowColor = Constants.primaryColor.hexToUiColor().cgColor
        select_order_type.layer.shadowOffset = CGSize(width: 0, height: 2)
        select_order_type.layer.shadowRadius = 4
        select_order_type.layer.shadowOpacity = 0.25

        select_order_type.backgroundColor = Constants.surfaceColor.hexToUiColor()
        select_order_type.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        select_order_type.layer.borderWidth = 1
        select_order_type.tag = 69
        select_order_type.addTarget(self, action: #selector(showOrderOptions), for: .touchUpInside)
        blurryView.addSubview(select_order_type)
        
        let doubleArrow = UIImageView(image: UIImage(systemName: "chevron.down")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)))
        doubleArrow.frame = CGRect(x: select_order_type.frame.maxX - 30, y: 0, width: 15, height: 25)
        doubleArrow.center.y = select_order_type.center.y
        doubleArrow.contentMode = .scaleAspectFit
        doubleArrow.tintColor = Constants.textColor.hexToUiColor()
        blurryView.addSubview(doubleArrow)
        

        blurryView.addSubview(packView)
        blurryView.fadeIn()
        // hidePack when blurryView tapped
        let tap = UITapGestureRecognizer(target: self, action: #selector(hidePack))
        visualEffectView.addGestureRecognizer(tap)

        if PackSettings.shouldHaveBackgroundGlow {
            // set y to closeButton.frame.maxY + 100 for the shadow image
            shadowImageView.frame = CGRect(x: 0, y: closeButton.frame.maxY + 100, width: shadowWidth, height: shadowHeight)
            shadowImageView.center.x = blurryView.center.x
        }

        // animate pack view up
        UIView.animate(withDuration: 0.3, animations: {
            packView.frame = CGRect(x: 30, y: closeButton.frame.maxY + 20, width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.height - closeButton.frame.maxY - 200)
            packView.alpha = 1
            if PackSettings.shouldHaveBackgroundGlow {
                shadowImageView.alpha = 1
            }
        }) { (success) in
            // add pack view to blurry view
            // blurryView.addSubview(packView)
        }
        
        
        
    }
    func getOrderTypeButton() -> UIButton {
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        let blurryView = topVC?.view.subviews.last
        let order_type_butt = blurryView?.viewWithTag(69) as! UIButton
        return order_type_butt
    }
    func setSelected(product: SKProduct) {
        // find select_order_type button and set title
        let order_type_butt = getOrderTypeButton()
        order_type_butt.setTitle("\(product.localizedTitle) - $\(product.price)", for: .normal)
    }
    // MARK: - show order options
    @objc func showOrderOptions() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let vc = PackSizePopUp()
        vc.parentVC = self
        // get currently selected product
        let order_type_butt = getOrderTypeButton()
        let title = order_type_butt.titleLabel?.text
        if ((title?.contains("6 Images")) != nil) && title?.contains("6 images") == true {
            vc.currentlySelected = "pawprintsai.smallpack"
        } else if title?.contains("30 Images") ?? false && title?.contains("30 images") == true {
            vc.currentlySelected = "pawprintsai.largepack"
        }
        Analytics.logEvent("show_order_options", parameters: nil)
        self.presentPanModal(vc)
    }
    // MARK: - hide pack
    @objc func hidePack() {
        
            Analytics.logEvent("hide_pack_popup", parameters: nil)
        self.removeIdLabel()
        // soft vibration
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        print("hide pack")
        // remove pack view
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        // fade down and out pack
        UIView.animate(withDuration: 0.3, animations: {
            if let viewLast = topVC?.view.subviews.last {
                if let secondView = viewLast.subviews.last {
                    if let viewz = secondView.subviews.last {
                    viewz.frame = CGRect(x: 30, y: 110 + 100, width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.height - 110 - 200)
                    viewz.alpha = 0
                    
                }
                }
                
            }
            topVC?.view.subviews.last?.alpha = 0
            
        }) { (success) in
            topVC?.view.subviews.last?.removeFromSuperview()
        }
        
    }
    // MARK: - Place order Pressed
    @objc func placeOrderPressed(sender: TransitionButton) {
        
            Analytics.logEvent("place_order_pressed", parameters: nil)
        var small_pack_id = "pawprintsai.smallpack"
        var large_pack_id = "pawprintsai.largepack"
        // hard vibration
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        sender.startAnimation()
        sender.isUserInteractionEnabled = false
        // search ai-models on firestore to see if any exist, or if we need to upload pictures to train a new one
        let db = Firestore.firestore()
        // where userId == current user
        let user = Auth.auth().currentUser
        let userId = user?.uid
        let docRef = db.collection("ai-models").whereField("userId", isEqualTo: userId!)
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                // check if we have a model
                if querySnapshot!.documents.count > 0 {
                    // we have a model, so we can just place the order
                    print("we have a model")
                    if SKPaymentQueue.canMakePayments() {
                        let productID: NSSet = NSSet(objects: small_pack_id, large_pack_id)
                        let productsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
                        productsRequest.delegate = self
                        productsRequest.start()
                        //            SKPaymentQueue.default().add(self)
                    } else {
                        print("can't make purchases")
                    }
                } else {
                    // we don't have a model, so we need to upload pictures to train a new one
                    print("we don't have a model, presenting photo selector")
                    self.showGoodbadImagesView()
                }
            }
        }
    
    }
    // MARK: - Show purchase prompt
    func purchaseProduct(product: SKProduct) {
        print("purchase product called for product \(product)")
        // find label with tag 420
        let topVC = UIApplication.shared.keyWindow?.rootViewController
        let label = topVC?.view.viewWithTag(420) as! UILabel
        let pack_id = label.text!
        print("pack id is \(pack_id)")
        // show loading
//        showLoading()
        // purchase product
        SwiftyStoreKit.purchaseProduct(product) { result in
//            self.hideLoading()
            switch result {
            case .success(let product):
                // turn off user interaction so user doesn't accidentally purchase twice and doesn't close the view
                topVC?.view.isUserInteractionEnabled = false
                // purchase successful
                print("Purchase Success: \(product.productId)")
                var previewImage: UIImage? = nil

                var references = [String]()
                
                // check if we need to upload pictures by grabbing data from photos_to_upload
                if let photos_g = UserDefaults.standard.object(forKey: "photos_to_upload") as? Data {
                    let photos = NSKeyedUnarchiver.unarchiveObject(with: photos_g as Data) as! [UIImage]
                    // upload pictures
                    print("uploading \(photos.count) photos")
                    previewImage = photos[0]
                    // upload photos to storage
                    let storage = Storage.storage()
                    let storageRef = storage.reference()
                    let user = Auth.auth().currentUser
                    let userId = user?.uid
                    let mainDispatchGroup = DispatchGroup()
                    for photo in photos {
                        mainDispatchGroup.enter()
                        // generate random image id
                        let imageId = UUID().uuidString
                        let image_name = "\(imageId).jpg"
                        let imagesRef = storageRef.child("training_images/\(userId!)/\(image_name)")
                        print("Uploading training_images/\(userId!)/\(image_name)")
                        
                        references.append("training_images/\(userId!)/\(image_name)")
                        let data = photo.jpegData(compressionQuality: 0.8)
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpeg"
                        let uploadTask = imagesRef.putData(data!, metadata: metadata) { (metadata, error) in
                            guard let metadata = metadata else {
                                // Uh-oh, an error occurred!
                                return
                            }
                            // Metadata contains file metadata such as size, content-type.
                            let size = metadata.size
                            
                            print("* Finished uploading an image!")
                            mainDispatchGroup.leave()
                        }
                    }
                    // remove photos from user defaults
                    mainDispatchGroup.notify(queue: .main) {
                        
                        Analytics.logEvent("uploaded_images_for_training", parameters: ["image_count": references.count])
                        UserDefaults.standard.removeObject(forKey: "photos_to_upload")
                        print("* finished uploading photos, placing the order")
                    // get receipt from purchase, it'll be verified on the server
                    SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
                        switch result {
                        case .success(let receiptData):
                            let receiptString = receiptData.base64EncodedString(options: [])
                            // json/array of receipt data
                            //                        let receipt = JSON(parseJSON: receiptString)
                            print("fetched receipt: \(receiptString)")
                            // random order id
                            let order_id = UUID().uuidString
                            let userId = Auth.auth().currentUser?.uid
                            print("fetched receipt: \(receiptString)")
                            let db = Firestore.firestore()
                            var order_data: [String: Any] = [
                                "userId": userId!,
                                "status": "pending",
                                "orderId": order_id,
                                "receipt": receiptString,
                                "packId": pack_id,
                                "packSize": product.productId,
                                "order_timestamp": Date().timeIntervalSince1970,
                            ]
                            if references.count > 0 {
                                order_data["train_images"] = references
                            }
                            print("* submitting with order data: \(order_data)")
                            db.collection("orders").document(order_id).setData(order_data) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added!")
                                    topVC?.view.isUserInteractionEnabled = true
                                    // hide pack view and open order view
                                    self.hidePack()
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    
                                    // create readable time stamp
                                    let date = Date()
                                    let formatter = DateFormatter()
                                    // format should just be hour and minute and PM or Am
                                    formatter.dateFormat = "h:mm a"
                                    let time = formatter.string(from: date)
                                    var pack_name = pack_id
                                    // try to find packNameLabel with tag 421
                                    let topVC2 = UIApplication.shared.keyWindow?.rootViewController
                                    if let packNameLabel = topVC2?.view.viewWithTag(421) as? UILabel {
                                        print("found pack name label")
                                        pack_name = packNameLabel.text!
                                    }
                                    Analytics.logEvent("submitted_order", parameters: ["pack_name": pack_name])
                                    // push OrderViewerViewController
                                    let orderViewerViewController = OrderViewerViewController()
                                    //                                            orderViewerViewController.order = Order(orderId: order_id, userId: userId!, status: .pending, packId: pack_id, packSize: product.productId, name: pack_id, price: 0, preview_image: previewImage, transaction_id: "", order_timestamp: "", result_sections: [])
                                    orderViewerViewController.shouldShowConfetti = true
                                    orderViewerViewController.order = Order(name: pack_name, price: 0, preview_image: "", description: "", status: .pending, order_id: order_id, transaction_id: order_id, order_timestamp: time, result_sections: [], packId: pack_id)
                                    self.navigationController?.pushViewController(orderViewerViewController, animated: true)
                                }
                            }
                        case .error(let error):
                            print("Receipt verification failed: \(error)")
                            Analytics.logEvent("error_receipt_verification", parameters: ["error": error.localizedDescription])
                            print("Purchase Failed: \(error)")
                            let topVC = UIApplication.shared.keyWindow?.rootViewController
                            let blurryView = topVC?.view.subviews.last
                            let place_order_butt = blurryView?.viewWithTag(68) as! TransitionButton
                            place_order_butt.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.5, completion: nil)
                            place_order_butt.isUserInteractionEnabled = true
                            // grab NSLocalizedDescription
                            let localizedReason = error.localizedDescription
                            let alert = UIAlertController(title: "Purchase Failed", message: "An error occured, please try again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            // wait and reset button cornerRadius
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                place_order_butt.layer.cornerRadius = 10
                            }
                        }
                    }
                }
                } else {
                    
                    // get receipt from purchase, it'll be verified on the server
                    SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
                        switch result {
                        case .success(let receiptData):
                            let receiptString = receiptData.base64EncodedString(options: [])
                            // json/array of receipt data
    //                        let receipt = JSON(parseJSON: receiptString)
                            print("fetched receipt: \(receiptString)")
                            // random order id
                            let order_id = UUID().uuidString
                            let userId = Auth.auth().currentUser?.uid
                            print("fetched receipt: \(receiptString)")
                            let db = Firestore.firestore()
                            var order_data: [String: Any] = [
                                "userId": userId!,
                                "status": "pending",
                                "orderId": order_id,
                                "receipt": receiptString,
                                "packId": pack_id,
                                "packSize": product.productId,
                                "order_timestamp": Date().timeIntervalSince1970,
                            ]
                            if references.count > 0 {
                                order_data["train_images"] = references
                            }
                            print("* submitting with order data: \(order_data)")
                            db.collection("orders").document(order_id).setData(order_data) { err in
                                if let err = err {
                                    print("Error adding document: \(err)")
                                } else {
                                    print("Document added!")
                                    topVC?.view.isUserInteractionEnabled = true
                                    // hide pack view and open order view
                                    self.hidePack()
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()

                                    // create readable time stamp
                                    let date = Date()
                                    let formatter = DateFormatter()
                                    // format should just be hour and minute and PM or Am
                                    formatter.dateFormat = "h:mm a"
                                    let time = formatter.string(from: date)
                                    var pack_name = pack_id
                                    let topVC2 = UIApplication.shared.keyWindow?.rootViewController
                                    if let packNameLabel = topVC2?.view.viewWithTag(421) as? UILabel {
                                        print("found pack name label")
                                        pack_name = packNameLabel.text!
                                    }
                                    Analytics.logEvent("submitted_order", parameters: ["pack_name": pack_name])
                                    // push OrderViewerViewController
                                    let orderViewerViewController = OrderViewerViewController()
                                    orderViewerViewController.shouldShowConfetti = true
    //                                            orderViewerViewController.order = Order(orderId: order_id, userId: userId!, status: .pending, packId: pack_id, packSize: product.productId, name: pack_id, price: 0, preview_image: previewImage, transaction_id: "", order_timestamp: "", result_sections: [])
                                    orderViewerViewController.order = Order(name: pack_name, price: 0, preview_image: "", description: "", status: .pending, order_id: order_id, transaction_id: order_id, order_timestamp: time, result_sections: [], packId: pack_id)
                                    self.navigationController?.pushViewController(orderViewerViewController, animated: true)
                                }
                            }
                        case .error(let error):
                            
                            Analytics.logEvent("error_receipt_verification", parameters: ["error": error.localizedDescription])
                            print("Receipt verification failed: \(error)")
                            print("Purchase Failed: \(error)")
                            let topVC = UIApplication.shared.keyWindow?.rootViewController
                            let blurryView = topVC?.view.subviews.last
                            let place_order_butt = blurryView?.viewWithTag(68) as! TransitionButton
                            place_order_butt.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.5, completion: nil)
                            place_order_butt.isUserInteractionEnabled = true
                            // grab NSLocalizedDescription
                            let localizedReason = error.localizedDescription
                            let alert = UIAlertController(title: "Purchase Failed", message: "An error occured, please try again.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            // wait and reset button cornerRadius
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                place_order_butt.layer.cornerRadius = 10
                            }
                        }
                    }
                }
                

            case .error(let error):
                
                Analytics.logEvent("error_with_purchase", parameters: ["error": error.localizedDescription])
                // purchase failed
                print("Purchase Failed: \(error)")
                let topVC = UIApplication.shared.keyWindow?.rootViewController
                let blurryView = topVC?.view.subviews.last
                let place_order_butt = blurryView?.viewWithTag(68) as! TransitionButton
                place_order_butt.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.5, completion: nil)
                place_order_butt.isUserInteractionEnabled = true
                // grab NSLocalizedDescription
                let localizedReason = error.localizedDescription
                let alert = UIAlertController(title: "Purchase Failed", message: "An error occured, please try again.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                // wait and reset button cornerRadius
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    place_order_butt.layer.cornerRadius = 10
                }
            }
        }
    }
    // MARK: - Grab currently selected pack, initiate purchase
     public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("products request received")
        let small_pack_id = "pawprintsai.smallpack"
        let large_pack_id = "pawprintsai.largepack"
        let count : Int = response.products.count
         DispatchQueue.main.async {
             if (count>0) {
                 let title = self.getOrderTypeButton().titleLabel?.text
                 print("current title: \(title)")
                 if title?.contains("6 images") == true {
                     let validProduct: SKProduct = response.products[1] as SKProduct
                     if (validProduct.productIdentifier == small_pack_id) {
                         print(validProduct.localizedTitle)
                         print(validProduct.localizedDescription)
                         print(validProduct.price)
                         self.purchaseProduct(product: validProduct)
                     } else {
                         print(validProduct.productIdentifier)
                     }
                 } else if title?.contains("30 images") == true {
                     let validProduct: SKProduct = response.products[0] as SKProduct
                     if (validProduct.productIdentifier == large_pack_id) {
                         print(validProduct.localizedTitle)
                         print(validProduct.localizedDescription)
                         print(validProduct.price)
                         self.purchaseProduct(product: validProduct)
                     } else {
                         print(validProduct.productIdentifier)
                     }
                 }
             } else {
                 print("nothing")
             }
         }
        
    }
}
extension UIButton {
    func stylePackButtonForTapped() {
        // dark gray background and text color
        self.backgroundColor = Constants.textColor.hexToUiColor().withAlphaComponent(0.2)
        self.setTitleColor(Constants.surfaceColor.hexToUiColor(), for: .normal)
    }
    func stylePackbuttonForUnTapped() 
    {
        // light gray background and text color
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        self.setTitleColor(Constants.textColor.hexToUiColor(), for: .normal)

    }
}

//
//  TrainAIImagesPopup.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/16/23.
//

import Foundation
import UIKit
import TLPhotoPicker
import TransitionButton
import FirebaseAnalytics
import StoreKit
import SwiftyStoreKit
class ImagesInfoPopup: UIView {
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        // scroll view is size of view
        scrollView.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        // content size is size of view
        scrollView.contentSize = CGSize(width: self.bounds.width, height: self.bounds.height)
        scrollView.backgroundColor = Constants.surfaceColor.hexToUiColor()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isScrollEnabled = true

        return scrollView
    }()
    lazy var letsUpLoadSomePhotosLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "AvenirNext-Bold", size: 17)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.text = "It's time to upload some photos!"
        label.frame = CGRect(x: 20, y: 20, width: self.bounds.width - 40, height: 30)
        
        return label
    }()
    lazy var mainInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "The better the photos you upload are, the better the art will be. We recommend uploading at least 10-20 images of your pet with various backgrounds. In general, portrait photos (aka photos where your pet is facing the camera) work best."
        label.font = UIFont(name: "AvenirNext-Regular", size: 11)
        label.textColor = .gray
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.sizeToFit()
        // label.frame = CGRect(x: 20, y: 70, width: self.bounds.width - 40, height: 80)
        label.frame = CGRect(x: 20, y: 40, width: self.bounds.width - 40, height: 0)
        return label
    }()
    lazy var examplesOfGoodPhotosLabel: UILabel = {
        let label = UILabel()
        label.text = "Examples of good photos:"
        label.font = UIFont(name: "AvenirNext-Regular", size: 15)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.frame = CGRect(x: 20, y: mainInfoLabel.frame.maxY + 10, width: self.bounds.width - 40, height: 20)
        // make "good" text green and bold
        let attributedString = NSMutableAttributedString(string: label.text!)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGreen.cgColor, range: NSRange(location: 12, length: 4))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "AvenirNext-Bold", size: 15)!, range: NSRange(location: 12, length: 4))
        label.attributedText = attributedString

        return label
    }()
    lazy var goodPhotosScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: examplesOfGoodPhotosLabel.frame.maxY + 10, width: self.bounds.width, height: 120)
        scrollView.contentSize = CGSize(width: self.bounds.width * 2, height: 100)
        scrollView.backgroundColor = Constants.surfaceColor.hexToUiColor()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    lazy var whatMakesAGoodPhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "✅ Different backgrounds\n✅ Different Angles of face\n✅ Good lighting\n✅ Simple backgrounds without much going on"
        label.font = UIFont(name: "AvenirNext-Bold", size: 11)
        label.textColor = .gray
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.frame = CGRect(x: 20, y: goodPhotosScrollView.frame.maxY + 10, width: self.bounds.width - 40, height: 70)
        return label
    }()
    lazy var examplesOfBadPhotosLabel: UILabel = {
        let label = UILabel()
        label.text = "Examples of bad photos:"
        label.font = UIFont(name: "AvenirNext-Regular", size: 15)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.frame = CGRect(x: 20, y: whatMakesAGoodPhotoLabel.frame.maxY + 20, width: self.bounds.width - 40, height: 20)
        // make "bad" text red and bold
        let attributedString = NSMutableAttributedString(string: label.text!)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemRed.cgColor, range: NSRange(location: 12, length: 3))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "AvenirNext-Bold", size: 15)!, range: NSRange(location: 12, length: 3))
        label.attributedText = attributedString
        
        return label
    }()
    lazy var badPhotosScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: examplesOfBadPhotosLabel.frame.maxY + 10, width: self.bounds.width, height: 120)
        scrollView.contentSize = CGSize(width: self.bounds.width * 2, height: 100)
        scrollView.backgroundColor = Constants.surfaceColor.hexToUiColor()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    lazy var whatMakesABadPhotoLabel: UILabel = {
        let label = UILabel()
        label.text = "❌ Blurry photos\n❌ Photos with the same background\n❌ Photos with bad lighting\n❌ Photos with your pet facing away from the camera\n❌ Low contrast with the background\n❌ Background with lots going on"
        label.font = UIFont(name: "AvenirNext-Bold", size: 11)
        label.textColor = .gray
        label.textAlignment = .left
        label.numberOfLines = 0
        label.backgroundColor = .clear
        label.frame = CGRect(x: 20, y: badPhotosScrollView.frame.maxY + 10, width: self.bounds.width - 40, height: 95)
        return label
    }()
    func addGoodPhoto(image: UIImage) {
        // grab the frame of the last view currently in the scroll view
        let lastViewFrame = goodPhotosScrollView.subviews.last?.frame ?? CGRect(x: 10, y: 0, width: 0, height: 0)
        // create a new view with the image
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: lastViewFrame.maxX + 10, y: 0, width: 90, height: 120)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        // add the new view to the scroll view
        goodPhotosScrollView.addSubview(imageView)
        // update the content size of the scroll view
        goodPhotosScrollView.contentSize = CGSize(width: imageView.frame.maxX + 20, height: 120)
    }
    func addBadPhoto(image: UIImage) {
        // grab the frame of the last view currently in the scroll view
        let lastViewFrame = badPhotosScrollView.subviews.last?.frame ?? CGRect(x: 10, y: 0, width: 0, height: 0)
        // create a new view with the image
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: lastViewFrame.maxX + 10, y: 0, width: 90, height: 120)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        // add the new view to the scroll view
        badPhotosScrollView.addSubview(imageView)
        // update the content size of the scroll view
        badPhotosScrollView.contentSize = CGSize(width: imageView.frame.maxX + 20, height: 120)
    }
    func updateUI() {
        self.backgroundColor = Constants.backgroundColor.hexToUiColor()
        self.addSubview(scrollView)
        scrollView.addSubview(letsUpLoadSomePhotosLabel)
        scrollView.addSubview(mainInfoLabel)
        scrollView.addSubview(examplesOfGoodPhotosLabel)
        scrollView.addSubview(goodPhotosScrollView)
        scrollView.addSubview(whatMakesAGoodPhotoLabel)
        scrollView.addSubview(examplesOfBadPhotosLabel)
        scrollView.addSubview(badPhotosScrollView)
        scrollView.addSubview(whatMakesABadPhotoLabel)
        // files are in Resources/Good and Bad image examples/
        addGoodPhoto(image: UIImage(named: "good_1.heic")!)
        addGoodPhoto(image: UIImage(named: "good_2.tiff")!)
        addGoodPhoto(image: UIImage(named: "good_4.tiff")!)
        addGoodPhoto(image: UIImage(named: "good_5.heic")!)
        addGoodPhoto(image: UIImage(named: "good_3.tiff")!)
        addGoodPhoto(image: UIImage(named: "good_6.png")!)
        addGoodPhoto(image: UIImage(named: "good_7.jpeg")!)
        // addGoodPhoto(image: UIImage(named: "good_8.webp")!)
//        addGoodPhoto(image: UIImage(named: "good_9.webp")!)
        addBadPhoto(image: UIImage(named: "bad_1.tiff")!)
        addBadPhoto(image: UIImage(named: "bad_2.heic")!)
        addBadPhoto(image: UIImage(named: "bad_3.heic")!)
        addBadPhoto(image: UIImage(named: "bad_4.heic")!)

        // update scroll view content size
        scrollView.contentSize = CGSize(width: self.bounds.width, height: whatMakesABadPhotoLabel.frame.maxY + 20)
    }
}
extension UIViewController {
    func showGoodbadImagesView() {
        // add blurred background and add ImagesInfoPopup view
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
        closeButton.addTarget(self, action: #selector(hideImagesPopup), for: .touchUpInside)
        blurryView.addSubview(closeButton)
        
        let imagesInfoView = ImagesInfoPopup()
        imagesInfoView.frame = CGRect(x: 30, y: closeButton.frame.maxY + 20, width: UIScreen.main.bounds.width - 60, height: UIScreen.main.bounds.height - closeButton.frame.maxY - 150)
        imagesInfoView.layer.cornerRadius = 12
        imagesInfoView.clipsToBounds = true
        imagesInfoView.center.x = blurryView.center.x
        imagesInfoView.backgroundColor = Constants.surfaceColor.hexToUiColor()
        imagesInfoView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        imagesInfoView.layer.borderWidth = 1
        imagesInfoView.updateUI()
        blurryView.addSubview(imagesInfoView)
        
        
        blurryView.fadeIn()
        // hidePack when blurryView tapped
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideImagesPopup))
        visualEffectView.addGestureRecognizer(tap)

        let letsGoBujtton = UIButton(type: .custom)
        letsGoBujtton.setTitle("Let's Go!", for: .normal)
        letsGoBujtton.setTitleColor(Constants.surfaceColor.hexToUiColor(), for: .normal)
        letsGoBujtton.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 16)
        letsGoBujtton.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - 90, width: imagesInfoView.frame.width - 10, height: 53)
        letsGoBujtton.center.x = imagesInfoView.center.x
        letsGoBujtton.layer.cornerRadius = 10
        // add shadow
        letsGoBujtton.layer.shadowColor = Constants.textColor.hexToUiColor().cgColor
        letsGoBujtton.layer.shadowOffset = CGSize(width: 0, height: 2)
        letsGoBujtton.layer.shadowRadius = 4
        letsGoBujtton.layer.shadowOpacity = 0.25
        letsGoBujtton.tag = 86
        letsGoBujtton.backgroundColor = Constants.textColor.hexToUiColor()
        // pass button into placeOrderPressed
        // placeOrderButton.addTarget(self, action: #selector(placeOrderPressed), for: .touchUpInside)
        letsGoBujtton.addTarget(self, action: #selector(letsGoPressed), for: .touchUpInside)
        blurryView.addSubview(letsGoBujtton)


    }
    @objc func letsGoPressed() {
        // soft vibration
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.impactOccurred()
        // hide pack, present photo picker
        hideImagesPopup(stopButton: false)
        // present photo picker
//        let vc = FMPhotoPickerViewController(config: self.config())
//        vc.title = "Select 10-20 Photos"
//        vc.delegate = self
//        self.present(vc, animated: true)
        let viewController = TLPhotosPickerViewController()
        viewController.delegate = self
        viewController.didExceedMaximumNumberOfSelection = { [weak self] (picker) in
            // you can use localized string here.
            let alert = UIAlertController(title: "Whoops, Hold on their partner!", message: "You can select a maximum of 20 photos.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(alert, animated: true)
        }
        // full screen
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: nil)
        
    }
    @objc func hideImagesPopup(stopButton:Bool = true) {
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
            if stopButton {
                let blurryView = topVC?.view.subviews.last
                let place_order_butt = blurryView?.viewWithTag(68) as! TransitionButton
                place_order_butt.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.5, completion: nil)
                // wait and then set place_order_butt corner radius
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    place_order_butt.layer.cornerRadius = 10
                }
            }
            
        }
        
    }
    @objc func removeGoodbadImagesView() {
        for view in self.view.subviews {
            if view.tag == 1 || view.tag == 2 {
                view.removeFromSuperview()
            }
        }
    }
}
extension UIViewController: TLPhotosPickerViewControllerDelegate {
    public func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
         var small_pack_id = "pawprintsai.smallpack"
         var large_pack_id = "pawprintsai.largepack"
        // use selected order here
        print("dismissPhotoPickerWithTLPHAssets")
        print(withTLPHAssets)
        // get images from assets
        var images = [UIImage]()
        for asset in withTLPHAssets {
            if let image = asset.fullResolutionImage {
                images.append(image)
            }
        }
        if images.count < 10 {
            print("whoops, we don't have enough photos")
            let alert = UIAlertController(title: "Not Enough Photos Selected", message: "Please select 10-20 photos, you only selected \(images.count) images.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            // get the second most view controller since
            let topVC = UIApplication.shared.keyWindow?.rootViewController
            topVC?.present(alert, animated: true)
            Analytics.logEvent("not_enough_photos_selected", parameters: ["image_count":images.count])
            let blurryView = topVC?.view.subviews.last
            let place_order_butt = blurryView?.viewWithTag(68) as! TransitionButton
            place_order_butt.stopAnimation(animationStyle: .shake, revertAfterDelay: 0.5, completion: nil)
            // wait and then set place_order_butt corner radius
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                place_order_butt.layer.cornerRadius = 10
            }
            return
        }
        
        // pass images to next view controller
        print("* looks like we have enough images, passing to pack view")
         let imageData = NSKeyedArchiver.archivedData(withRootObject: images)
         UserDefaults.standard.set(imageData, forKey: "photos_to_upload")
         // TODO: SAVE FOR UPLOAD TO STORAGE
         if SKPaymentQueue.canMakePayments() {
             let productID: NSSet = NSSet(objects: small_pack_id, large_pack_id)
             let productsRequest = SKProductsRequest(productIdentifiers: productID as! Set<String>)
             productsRequest.delegate = self
             productsRequest.start()
             //            SKPaymentQueue.default().add(self)
         } else {
             print("can't make purchases")
         }
    }
    public func dismissComplete() {
        print("dismissComplete")
        
    }
    public func handleNoAlbumPermissions(picker: TLPhotosPickerViewController) {
        print("handleNoAlbumPermissions")
    }
    public func handleNoCameraPermissions(picker: TLPhotosPickerViewController) {
        print("handleNoCameraPermissions")
    }
    public func didExceedMaximumNumberOfSelection(picker: TLPhotosPickerViewController) {
        print("didExceedMaximumNumberOfSelection")
        // show alert
        let alert = UIAlertController(title: "Maximum Photos", message: "You can only select 20 photos at a time.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    func handleDidCancel(picker: TLPhotosPickerViewController) {
        print("handleDidCancel")
    }
    func presentPhotoPickerViewController(picker: TLPhotosPickerViewController) {
        print("presentPhotoPickerViewController")
        self.present(picker, animated: true, completion: nil)
    }
}

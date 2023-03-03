//
//  LimitedPackCollectionViewCell.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/2/23.
//

import Foundation
import UIKit

// MARK: - LimitedPackCollectionViewCell
class LimitedPackCollectionViewCell: UICollectionViewCell {
    // MARK: - Public API
    var limitedPack: Any? {
        didSet {
            updateUI()
        }
    }
    // MARK: - Private API
    @IBOutlet weak var limitedPackNameLabel: UILabel!
    @IBOutlet weak var bottomBlackGradientView: UIView!

    @IBOutlet weak var pictureHolder: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var limitedPackImageView: UIImageView!

    @IBOutlet weak var shadowImage: ShadowImageView!
    private func updateUI() {
//        self.awakeFromNib()
        self.backgroundColor = .clear
        if let pack = limitedPack as? LimitedPack {
            limitedPackImageView.image = pack.featuredImage
            limitedPackNameLabel.text = pack.title
            backgroundImageView.image = pack.featuredImage
        } else if let pack = limitedPack as? VarietyPack {
            limitedPackImageView.image = pack.featuredImage
            limitedPackNameLabel.text = pack.title
            backgroundImageView.image = pack.featuredImage
        }
        updateUIFrames()
    }
    private func updateUIFrames() {
        let padding = 10
        pictureHolder.frame = CGRect(x: 0, y: 0, width: Int(frame.width), height: Int(frame.height))
//        pictureHolder.layer.cornerRadius = 10
        pictureHolder.layer.masksToBounds = true
        pictureHolder.backgroundColor = Constants.backgroundColor.hexToUiColor()
        let tmp = 45
        backgroundImageView.frame = CGRect(x: tmp, y: tmp, width: Int(pictureHolder.frame.width) - (tmp*2), height: Int(pictureHolder.frame.height) - (tmp*2))
        backgroundImageView.layer.cornerRadius = 10
        backgroundImageView.layer.masksToBounds = true
        blurView.frame = CGRect(x: 0, y: 0, width: pictureHolder.frame.width, height: pictureHolder.frame.height)
        limitedPackImageView.frame = CGRect(x: padding, y: padding, width: Int(frame.width) - (padding*2), height: Int(frame.height) - (padding*2))



        limitedPackImageView.layer.cornerRadius = 10
        limitedPackImageView.layer.masksToBounds = true
        

        var imagez: UIImage? = nil
        if let pack = limitedPack as? LimitedPack {
            imagez = pack.featuredImage
        } else if let pack = limitedPack as? VarietyPack {
            imagez = pack.featuredImage
        }
        if let imagez = imagez {
            // Center crop the image
            let sourceCGImage = imagez.cgImage!
            // crop to fit shadowImage dimensions
            let cropRect = CGRect(
                x: 0,
                y: 0,
                width: Int(shadowImage.frame.width),
                height: Int(shadowImage.frame.height)
            ).integral
            let croppedCGImage = sourceCGImage.cropping(
                to: cropRect
            )!

            // Use the cropped cgImage to initialize a cropped
            // UIImage with the same image scale and orientation
            let croppedImage = UIImage(
                cgImage: croppedCGImage,
                scale: imagez.imageRendererFormat.scale,
                orientation: imagez.imageOrientation
            )
//            print("shadowImage size: \(shadowImage.imageView.size)")
            shadowImage.shadowAlpha = CGFloat(0.9)
            let shadowWidth = CGFloat(Int(frame.width) - (padding*2))
            let shadowHeight = CGFloat(Int(frame.height) - (padding*2) - 30)
            shadowImage.layoutWithViewSize(image: imagez, width: shadowWidth, height: shadowHeight)

            shadowImage.frame = CGRect(x: 10, y: 15, width: shadowWidth, height: shadowHeight)
            shadowImage.center.x = self.frame.width / 2
            shadowImage.center.y = (self.frame.height / 2) - 10
        }

        limitedPackNameLabel.font = UIFont(name: "AvenirNext-Bold", size: 18)

        bottomBlackGradientView.frame = CGRect(x: Int(shadowImage.frame.minX), y: Int(shadowImage.frame.maxY) - 40, width: Int(shadowImage.frame.width), height: 40)
        bottomBlackGradientView.clipsToBounds = true
        bottomBlackGradientView.layer.cornerRadius = 10
        // black gradient to make text more readable
        let gradient = CAGradientLayer()
        // make it rounded and bound by the image
        gradient.frame = bottomBlackGradientView.bounds
        gradient.cornerRadius = 10
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.5).cgColor]
        gradient.locations = [0.0, 1.0]
        bottomBlackGradientView.layer.insertSublayer(gradient, at: 0)

        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateUIFrames()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        updateUI()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        updateUIFrames()
    }

    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        updateUIFrames()
    }

}
extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}

//
//  OrderTableViewCell.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/2/23.
//

import Foundation
import UIKit
import Kingfisher
// MARK: - OrderTableViewCell
class OrderTableViewCell: UITableViewCell {
    // MARK: - Public API
    var order: Order? {
        didSet {
            updateUI()
        }
    }
    // MARK: - Private API
    @IBOutlet weak var orderPreviewImage: ShadowImageView!
    @IBOutlet weak var orderNameLabel: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var orderProgressBar: UIProgressView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var stepView: StepBar!

    // completed order stuff
    @IBOutlet weak var imagesImageView: UIImageView!
    @IBOutlet weak var numberOfImagesLabel: UILabel!
    @IBOutlet weak var completedOrderLabel: UILabel!

    private func updateUI() {
        orderPreviewImage.imageView.kf.setImage(with: URL(string: order?.preview_image_url ?? ""))
        orderNameLabel.text = order?.name
//        orderStatusLabel.text = order?.status

        updateUIFrames()
    }
    private func updateUIFrames() {
        let padding = 10
        orderPreviewImage.frame = CGRect(x: 5, y: 15, width: frame.height - 30, height: frame.height - 30)
        orderPreviewImage.frame = CGRect(x: 0, y: padding, width: Int(70), height: Int(70))
        var imagez: UIImage? = nil
        orderPreviewImage.imageView.kf.setImage(with: URL(string: order?.preview_image_url ?? "")) { result in
            switch result {
            case .success(let value):
                imagez = value.image
                self.orderPreviewImage.shadowAlpha = CGFloat(0.0)
                // let shadowWidth = CGFloat(Int(frame.height) - (padding*2))
                // let shadowHeight = CGFloat(Int(frame.height) - (padding*2))
                let shadowWidth = 70
                self.orderPreviewImage.layoutWithViewSize(image: imagez!, width: CGFloat(shadowWidth), height: CGFloat(shadowWidth))

                self.orderPreviewImage.frame = CGRect(x: 0, y: padding, width: Int(shadowWidth), height: Int(shadowWidth))
            case .failure(let error):
                print("Error: \(error)")
            }
        }

        orderNameLabel.frame = CGRect(x: orderPreviewImage.frame.maxX + 25, y: 15, width: frame.width - orderPreviewImage.frame.maxX - 30, height: 20)
        stepView.frame = CGRect(x: orderPreviewImage.frame.maxX + 25, y: orderNameLabel.frame.maxY + 5, width: orderNameLabel.frame.width - 30, height: 20)
        stepView.stepTitles = ["Start", "Processing", "Images", "Done!"]
        orderStatusLabel.frame = CGRect(x: orderNameLabel.frame.minX, y: orderNameLabel.frame.maxY + 5, width: orderNameLabel.frame.width, height: 16)
        orderProgressBar.frame = CGRect(x: orderNameLabel.frame.minX, y: orderStatusLabel.frame.maxY + 5, width: orderNameLabel.frame.width, height: 20)

        orderNameLabel.font = UIFont(name: "AvenirNext-Bold", size: 16)
        orderStatusLabel.font = UIFont(name: "AvenirNext-Regular", size: 14)
        let status = order?.status
        orderProgressBar.progress = 0.25
        orderStatusLabel.text = "Processing Order"
        stepView.isHidden = false
        imagesImageView.isHidden = true
            numberOfImagesLabel.isHidden = true
            completedOrderLabel.isHidden = true
        orderStatusLabel.textColor = .gray
        if status == .training {
            stepView.currentStep = 2
        } else if status == .generating_results {
            stepView.currentStep = 3
        } else if status == .completed {

        orderNameLabel.frame = CGRect(x: orderPreviewImage.frame.maxX + 25, y: 16, width: frame.width - orderPreviewImage.frame.maxX - 30, height: 20)
            stepView.isHidden = true
            imagesImageView.isHidden = false
            numberOfImagesLabel.isHidden = false
            completedOrderLabel.isHidden = false
            completedOrderLabel.text = "Completed" //✓
            completedOrderLabel.textColor = .systemGreen
            numberOfImagesLabel.font = UIFont(name: "AvenirNext-Bold", size: 14)
            completedOrderLabel.font = UIFont(name: "AvenirNext-Bold", size: 14)
            var numImages = 0
            if let sections = order?.result_sections {
                for section in sections {
                    numImages += section.images.count
                }
            }
            numberOfImagesLabel.text = "\(numImages) images"
            numberOfImagesLabel.textColor = .gray
            imagesImageView.image = UIImage(systemName: "photo.on.rectangle.angled")?.withTintColor(.gray, renderingMode: .alwaysOriginal).withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .large))
            // set frames
            imagesImageView.frame = CGRect(x: orderNameLabel.frame.minX, y: orderNameLabel.frame.maxY, width: 20, height: 20)
            numberOfImagesLabel.frame = CGRect(x: imagesImageView.frame.maxX + 5, y: imagesImageView.frame.minY, width: 100, height: 20)
            completedOrderLabel.frame = CGRect(x: orderNameLabel.frame.minX, y: numberOfImagesLabel.frame.maxY, width: 100, height: 20)


        } else {
            stepView.currentStep = 1
        }
        self.backgroundColor = .clear
//        self.layer.cornerRadius = 10
//        self.layer.masksToBounds = true
//        self.layer.borderWidth = 1
//        self.layer.borderColor = UIColor.lightGray.cgColor
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

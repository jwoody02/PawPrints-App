//
//  OrderViewerViewController.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/2/23.
//

import Foundation
import UIKit
import Firebase
import SwiftConfettiView
// MARK: - OrderViewerViewController
class OrderViewerViewController: BaseViewController {
    // MARK: - Public API
    var order: Order?
    // MARK: - Private API
    lazy var backButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "arrow.left")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 21, weight: .bold))
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(backButtonPressed), for: .touchUpInside)
        button.tintColor = Constants.textColor.hexToUiColor()
        button.frame = CGRect(x: 15, y: 52, width: 21, height: 60)
        button.contentMode = .scaleAspectFit
        button.imageView?.contentMode = .scaleAspectFit
        return button
    }()
    lazy var orderNameLabel: UILabel = {
        let label = UILabel()
        label.text = order?.name
        label.font = UIFont(name: "AvenirNext-Bold", size: 20)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        return label
    }()
    lazy var orderNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Order #\(order?.transaction_id ?? "N/A")"
        label.font = UIFont(name: "AvenirNext-Bold", size: 13)
        label.textColor = .gray
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Images collection view
    lazy var imagesCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: "ImageCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = true
        return collectionView
    }()
    lazy var progressBarView: StepBar = {
                let view = StepBar()
                view.stepTitles = ["Start", "Processing", "Images", "Done!"]
                view.backgroundColor = .clear
                view.vertical = true
                view.ShowSubTitle = true
                view.mainFontSize = UIFont(name: "AvenirNext-Bold", size: 16)
                view.smallFontSize = UIFont(name: "AvenirNext-Bold", size: 13)
                // create Order was placed at {time}
                // order_timestamp is a double in the form of a string
                let orderTimestamp = Double(order?.order_timestamp ?? "0")
                print("orderTimestamp: \(orderTimestamp ?? 0)" )
                // get the date from the timestamp
                let date = Date(timeIntervalSince1970: orderTimestamp ?? 0)
                // create a date formatter
                let dateFormatter = DateFormatter()
                // use local time zone for user
                dateFormatter.timeZone = TimeZone.current
                dateFormatter.locale = NSLocale.current
                dateFormatter.dateFormat = "h:mm a" //Specify your format that you want
                let strDate = dateFormatter.string(from: date)
                view.stepSubTitles = ["Order was placed at \(strDate)", "This can take up to 20 minutes to complete.", "Images are being generated", "Your order is complete!"]
                // view.stepSubTitles = ["Order was placed at 1:20 PM", "This can take up to 20 minutes to complete.", "Images are being generated", "Your order is complete!"]
                view.alpha = 0
                return view
            }()
    var shouldShowConfetti = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.toogleTabbar(hide: true)
        view.backgroundColor = Constants.backgroundColor.hexToUiColor()
        view.addSubview(backButton)
        view.addSubview(orderNameLabel)
        view.addSubview(orderNumberLabel)
        setupUI()
        self.navigationController?.isNavigationBarHidden = true
        view.addSubview(progressBarView)

            progressBarView.fadeIn()
        if order?.status == .completed {
            view.addSubview(imagesCollectionView)
            progressBarView.isHidden = true
        } else {
            progressBarView.frame = CGRect(x: 20, y: orderNumberLabel.frame.maxY + 50, width: 25, height: 300)
        }
        
        if shouldShowConfetti {
            // use SwiftConfettiView
            let confettiView = SwiftConfettiView(frame: view.bounds)
            confettiView.type = .confetti
            confettiView.intensity = 0.5
            view.addSubview(confettiView)
            confettiView.startConfetti()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                confettiView.stopConfetti()
                // wait another 2 seconds and remove from superview
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    confettiView.removeFromSuperview()
                }
            }
        }
    }
    func setupUI() {
        orderNameLabel.frame = CGRect(x: backButton.frame.maxX + 10, y: 60, width: view.frame.width - 20, height: 30)
        // make order number label 2 lines if need be and break by character
        orderNumberLabel.numberOfLines = 2
        orderNumberLabel.lineBreakMode = .byCharWrapping

        orderNumberLabel.frame = CGRect(x: orderNameLabel.frame.minX, y: orderNameLabel.frame.maxY - 5, width: view.frame.width - (orderNameLabel.frame.minX * 2), height: 30)
    }
    @objc func backButtonPressed() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        self.navigationController?.popViewController(animated: true)
        self.toogleTabbar(hide: false)
    }
}
extension OrderViewerViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let ac_section = order?.result_sections?[section]
        return ac_section?.images.count ?? 0
    }
    // MARK: - number of sections
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return order?.result_sections?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCollectionViewCell", for: indexPath) as! ImageCollectionViewCell
        if let imagez = order?.result_sections?[indexPath.section].images[indexPath.row].image {
            
            cell.image = imagez
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfImagesPerRow = 3
        let spacingBetweenCells: CGFloat = 2
        let totalSpacing = (2 * 2) + ((CGFloat(numberOfImagesPerRow) - 1) * spacingBetweenCells)
        if collectionView == self.imagesCollectionView {
            let width = (collectionView.bounds.width - totalSpacing) / CGFloat(numberOfImagesPerRow)
            return CGSize(width: width, height: width)
        } else {
            return CGSize(width: 0, height: 0)
        }

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        // let vc = ImageViewerViewController()
        // vc.image = order?.images[indexPath.row]
        // self.navigationController?.pushViewController(vc, animated: true)
    }
}
class ImageCollectionViewCell: UICollectionViewCell {
    var image: UIImage? {
        didSet {
            guard let image = image else { return }
            imageView.image = image
        }
    }
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 10
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

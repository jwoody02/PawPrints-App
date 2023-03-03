//
//  VarietyPackCollectionViewCell.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/7/23.
//

import Foundation
import UIKit

// MARK: - VarietyPackCollectionViewCell
class VarietyPackCollectionViewCell: UICollectionViewCell {
    // MARK: - Public API
    var varietyPack: Any? {
        didSet {
            updateUI()
        }
    }
    // MARK: - Private API
    @IBOutlet weak var featuredImageView: UIImageView!

    private func updateUI() {
//        self.awakeFromNib()
        self.backgroundColor = .clear
        if let pack = varietyPack as? VarietyPack {
            featuredImageView.image = pack.featuredImage
        }
        updateUIFrames()
    }
    private func updateUIFrames() {
        featuredImageView.layer.cornerRadius = 10
        featuredImageView.layer.masksToBounds = true
        featuredImageView.frame = self.bounds
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


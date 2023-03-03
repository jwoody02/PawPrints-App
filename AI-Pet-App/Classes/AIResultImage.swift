//
//  AIResultImage.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/2/23.
//

import Foundation
import UIKit
class ImageSection {
    // image section so we can group images together
    var name: String
    var images: [AIResultImage]

    init(name: String, images: [AIResultImage]) {
        self.name = name
        self.images = images
    }
}
class AIResultImage {
    // MARK: Public API
    var image: UIImage?
    var storage_ref = ""
    var section_ = ""
    
    init(image: UIImage? = nil, storage_ref: String = "", section_: String = "") {
        self.image = image
        self.storage_ref = storage_ref
        self.section_ = section_
    }
}

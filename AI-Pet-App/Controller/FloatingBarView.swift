//
//  FloatingBarView.swift
//  PrinterestTabBar
//
//  Created by Christophe Hoste on 29.03.20.
//  Copyright © 2020 Christophe Hoste. All rights reserved.
//

import UIKit

protocol FloatingBarViewDelegate: AnyObject {
    func did(selectindex: Int)
}

class FloatingBarView: UIView {

    weak var delegate: FloatingBarViewDelegate?

    var buttons: [UIButton] = []

    init(_ items: [String]) {
        super.init(frame: .zero)
        backgroundColor = .white

        setupStackView(items)
        updateUI(selectedIndex: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        layer.cornerRadius = bounds.height / 2

        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = .zero
        layer.shadowRadius = bounds.height / 2
    }

    func setupStackView(_ items: [String]) {
        for (index, item) in items.enumerated() {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .heavy, scale: .medium)
            let normalImage = UIImage(systemName: item, withConfiguration: symbolConfig)
            let selectedImage = UIImage(systemName: "\(item).fill", withConfiguration: symbolConfig)
            if normalImage != nil && selectedImage == nil {
                let button = createButton(normalImage: normalImage!, selectedImage: normalImage!, index: index)
                buttons.append(button)
            } else if selectedImage == nil {
                let newsymbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium, scale: .small)
                // looks like image isn't system, grab it from local filesystem
                let newImage = UIImage(named: item)?.withConfiguration(newsymbolConfig)
                let selected =  UIImage(named: "small_paw_filled.png")?.withConfiguration(newsymbolConfig)
                let button = createButton(normalImage: newImage!, selectedImage: selected!, index: index)
                buttons.append(button)
                
            }
            
            if let selectedImage = selectedImage {
                let button = createButton(normalImage: normalImage!, selectedImage: selectedImage, index: index)
                buttons.append(button)
                
            }
        }
        
        let stackView = UIStackView(arrangedSubviews: buttons)

        addSubview(stackView)
        stackView.fillSuperview(padding: .init(top: 0, left: 16, bottom: 0, right: 16))
        

        // add little red dot to put over the 3rd button
        let redDot = UIView()
        redDot.backgroundColor = .red
        redDot.constrainWidth(constant: 8)
        redDot.constrainHeight(constant: 8)
        redDot.layer.cornerRadius = 4
        redDot.clipsToBounds = true
        redDot.isHidden = false
        redDot.alpha = 0
        addSubview(redDot)
        // put red dot in the upper right corner of the 3rd button

        // redDot.anchor(top: nil, leading: nil, bottom: buttons[2].bottomAnchor, trailing: buttons[2].trailingAnchor, padding: .init(top: 0, left: 0, bottom: 8, right: 8))
        redDot.anchor(top: buttons[2].topAnchor, leading: nil, bottom: nil, trailing: buttons[2].trailingAnchor, padding: .init(top: 17, left: 0, bottom: 0, right: 20))
        
    }
    func toggleRedDot(hide: Bool) {
        if hide == true {
            // find red dot and hide it
            for view in self.subviews {
                if view.backgroundColor == .red {
                    view.fadeOut()
                }
            }
        } else {
            // find red dot and show it
            for view in self.subviews {
                if view.backgroundColor == .red {
                    view.fadeIn()
                }
            }
        }
    }
    func createButton(normalImage: UIImage, selectedImage: UIImage, index: Int) -> UIButton {
        let button = UIButton()
        button.constrainWidth(constant: 60)
        button.constrainHeight(constant: 60)
        button.setImage(normalImage, for: .normal)
        button.setImage(selectedImage, for: .selected)
        button.tag = index
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(changeTab(_:)), for: .touchUpInside)
        return button
    }

    @objc
    func changeTab(_ sender: UIButton) {
        sender.pulse()
        delegate?.did(selectindex: sender.tag)
        updateUI(selectedIndex: sender.tag)
    }

    func updateUI(selectedIndex: Int) {
        for (index, button) in buttons.enumerated() {
            if index == selectedIndex {
                button.isSelected = true
                
                button.tintColor = Constants.textColor.hexToUiColor()
            } else {
                button.isSelected = false
                button.tintColor = .gray
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func toggle(hide: Bool) {
        if !hide {
            isHidden = hide
        }

        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 1,
                       initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
            self.alpha = hide ? 0 : 1
            self.transform = hide ? CGAffineTransform(translationX: 0, y: 10) : .identity
        }) { (_) in
            if hide {
                self.isHidden = hide
            }
        }
    }
}

extension UIButton {

    func pulse() {
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.15
        pulse.fromValue = 0.95
        pulse.toValue = 1.0
        layer.add(pulse, forKey: "pulse")
    }
}

//
//  UIExtensions.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/1/23.
//

import UIKit
public struct Constants {
    static let borderRadius: CGFloat = 12
    static let globalFont: String = "PlusJakartaSans-Regular"
    static let globalFontBold: String = "PlusJakartaSansRoman-Bold"
    static let globalFontMedium: String = "PlusJakartaSansRoman-SemiBold"
    static let globalFontItali: String = "PlusJakartaSans-Italic"
    static var primaryColor: String = "#5e5cf5"
    static var secondaryColor: String = "#dddcfd"
    static var backgroundColor: String = "#f8f8f8"
    static var surfaceColor: String = "#ffffff"
    static var textColor: String = "#000000"
    
    static let isDebugEnabled = false
    // shared instance
    static let shared = Constants()
    func setDarkModeConstants() {
        Constants.primaryColor = "#5e5cf5"
        Constants.secondaryColor = "#26262b"
        Constants.backgroundColor = "#111111"
        Constants.surfaceColor = "#18191A"
        Constants.textColor = "#ffffff"
    }

}
extension String {
    func hexToUiColor() -> UIColor {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
extension UITextField {
    func styleComponents() {
        self.setLeftPaddingPoints(10)
        self.font = UIFont(name: "\(Constants.globalFont)", size: 14)
        self.layer.cornerRadius = 4
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 4
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        self.layer.borderWidth = 1
        
        self.leftViewMode = .always
    }
    func styleSearchBar() {
        self.setLeftPaddingPoints(10)
//        self.font = UIFont(name: "\(Constants.globalFont)", size: 14)
        //        self.layer.cornerRadius = 25
        self.layer.cornerRadius = 12
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 4
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        self.layer.borderWidth = 1
        self.leftViewMode = .always
    }
}
extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UITextView {
    func styleTextView() {
        //        self.setLeftPaddingPoints(10)
        self.font = UIFont(name: "\(Constants.globalFont)", size: 14)
        //        self.layer.cornerRadius = 25
        self.layer.cornerRadius = 20
        self.backgroundColor = .white
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 4
        self.clipsToBounds = false
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
        self.layer.borderWidth = 1
        //        self.leftView
    }
    func addCommentViewPadding() {
        self.textContainerInset = UIEdgeInsets(top: 16, left: 15, bottom: 15, right: 60)
    }
}
extension UIView {
    
    func fadeIn( _ alphaz: CGFloat? = 1, onCompletion: (() -> Void)? = nil) {
        var duration: TimeInterval?
        duration = 0.2
        if self.alpha == 1 && self.isHidden == false {
            return
        }
        self.alpha = 0
        self.isHidden = false
        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = alphaz! },
                       completion: { (value: Bool) in
            if let complete = onCompletion { complete() }
        }
        )
    }
    
    func fadeOut(_ duration: TimeInterval? = 0.2, onCompletion: (() -> Void)? = nil) {
        if self.alpha == 0 || self.isHidden == true {
            return
        }

        UIView.animate(withDuration: duration!,
                       animations: { self.alpha = 0 },
                       completion: { (value: Bool) in
            self.isHidden = true
            if let complete = onCompletion { complete() }
        }
        )
    }
    
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
extension UIView {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIView.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }
}
extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
struct DefaultsKeys {
    static let ke_y_val = "ke.Y.Val.OFAs.31234e.Tea"
}
extension UIView {
    func addBaseShadow() {
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.2).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = Constants.borderRadius
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.clear.cgColor
    }
    func addShadowWith(color: CGColor, offset: CGSize, opacity: Float) {
        self.layer.shadowColor = color
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = Constants.borderRadius
        self.clipsToBounds = true
    }
}
// Usage: insert view.pushTransition right before changing content
extension UIView {
    func pushTransition(_ duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
                                                            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromTop
        animation.duration = duration
        DispatchQueue.main.async {
            
            self.layer.add(animation, forKey: CATransitionType.push.rawValue)
        }
    }
}

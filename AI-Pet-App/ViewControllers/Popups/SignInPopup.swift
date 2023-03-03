//
//  SignInPopup.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/3/23.
//

import Foundation
import UIKit
import PanModal
import Firebase
import AEOTPTextField
// MARK: - SignInPopup
class SignInPopup: UIViewController, PanModalPresentable, AEOTPTextFieldDelegate, UITextFieldDelegate {
    func didUserFinishEnter(the code: String) {
        print("* sending code to firebase: \(code)")
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")!
        
        // anonymous user info
       let anonymousUser = Auth.auth().currentUser!
        
        // send code and merge with anonymous user
        var credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
//        Auth.auth().currentUser?.link(with: credential) { (authResult, error) in
//            if let error = error {
//                print("* error linking phone number: \(error)")
//                return
//            }
//            print("* linked phone number")
//            // update all view controllers
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.updateAllViewControllers()
//            credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code)
//        }
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("* error signing in with phone number: \(error)")
                return
            }
            print("* signed in with phone number")
            // update all view controllers
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.updateAllViewControllers()
            // check to see if the anonymous user has any orders
            let db = Firestore.firestore()
            db.collection("orders").whereField("userID", isEqualTo: anonymousUser.uid).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("* error getting orders: \(error)")
                    return
                }
                if querySnapshot!.documents.count > 0 {
                    // there are orders, so we need to update them
                    for document in querySnapshot!.documents {
                        db.collection("orders").document(document.documentID).updateData(["userID": authResult!.user.uid])
                    }
                }
                // delete the anonymous user
                anonymousUser.delete { error in
                    if let error = error {
                        print("* error deleting anonymous user: \(error)")
                        return
                    }
                    print("* deleted anonymous user")
                }
            }
            // transfer all ai models to the new user
            db.collection("ai_models").whereField("userID", isEqualTo: anonymousUser.uid).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("* error getting ai models: \(error)")
                    return
                }
                if querySnapshot!.documents.count > 0 {
                    // there are ai models, so we need to update them
                    for document in querySnapshot!.documents {
                        db.collection("aiModels").document(document.documentID).updateData(["userID": authResult!.user.uid])
                    }
                }
            }

            // dismiss popup
            self.dismiss(animated: true, completion: nil)
            }
        }
        
    
    
    // MARK: - Public API
    var panScrollable: UIScrollView? {
        return nil
    }
    var shortFormHeight: PanModalHeight {
        return .contentHeight(450)
    }
    var longFormHeight: PanModalHeight {
        return .contentHeight(450)
    }
    var anchorModalToLongForm: Bool {
        return false
    }
    var parentVC: UIViewController?
    // First step: Collect phone number
    // Second step: Collect verification code

    // MARK: - Private API
    lazy var phoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Phone Number"
        textField.keyboardType = .numberPad
        textField.font = UIFont(name: "AvenirNext-Regular", size: 14)
        textField.textColor = Constants.textColor.hexToUiColor()
        textField.textAlignment = .left
        textField.styleSearchBar()
        textField.borderStyle = .none
        textField.textColor = Constants.textColor.hexToUiColor()
        textField.backgroundColor = Constants.surfaceColor.hexToUiColor()
        textField.frame = CGRect(x: 30, y: 30, width: UIScreen.main.bounds.width - 60, height: 50)
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 50))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.delegate = self
        return textField
    }()
    lazy var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.greyOut()
        
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        button.frame = CGRect(x: phoneNumberTextField.frame.minX, y: phoneNumberTextField.frame.maxY + 25, width: phoneNumberTextField.frame.width, height: 53)
        return button
    }()
    lazy var verificationLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter Verification Code"
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .center
        label.frame = CGRect(x: 30, y: phoneNumberTextField.frame.minY, width: phoneNumberTextField.frame.width, height: 21)
        // label.center.x = 
        label.isHidden = true
        return label
    }()
    // verification text field using aeotextfield
    lazy var VerificationTextField: AEOTPTextField = {
        let textField = AEOTPTextField()
        textField.otpDelegate = self
        textField.configure(with: 6)
        // textField.frame = CGRect(x: 15, y: phoneNumberTextField.frame.maxY + 25, width: phoneNumberTextField.frame.width, height: 53)
        textField.center.x = view.center.x
        textField.center.y = verificationLabel.center.y + 40
        textField.isHidden = true
//        textField.otpBackgroundColor = Constants.surfaceColor.hexToUiColor()
//        textField.otpTextColor = Constants.textColor.hexToUiColor()
//        textField.textColor = Constants.textColor.hexToUiColor()
////        textField.backgroundColor = Constants.surfaceColor.hexToUiColor()
//        textField.otpFilledBorderColor = Constants.textColor.hexToUiColor()
//        textField.otpFilledBackgroundColor = Constants.surfaceColor.hexToUiColor()
//        textField.otpDefaultBorderColor = .gray
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor.hexToUiColor()
        view.addSubview(phoneNumberTextField)
        view.addSubview(continueButton)
        view.addSubview(verificationLabel)
        view.addSubview(VerificationTextField)
        phoneNumberTextField.delegate = self
        phoneNumberTextField.becomeFirstResponder()
        phoneNumberTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        phoneNumberTextField.frame = CGRect(x: 15, y: 15, width: view.frame.width - 30, height: 53)
    }
    @objc func continueButtonTapped() {
        // send verification code with firebase
        var phoneNumber = phoneNumberTextField.text!
        // properly format phone number for firebase
        phoneNumber = "+1" + phoneNumber
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("* error verifying phone number:")
                print(error.localizedDescription)
                return
            }
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            UIView.animate(withDuration: 0.5, animations: {
                self.phoneNumberTextField.frame = CGRect(x: -self.phoneNumberTextField.frame.width, y: self.phoneNumberTextField.frame.minY, width: self.phoneNumberTextField.frame.width, height: self.phoneNumberTextField.frame.height)
                self.continueButton.frame = CGRect(x: -self.continueButton.frame.width, y: self.continueButton.frame.minY, width: self.continueButton.frame.width, height: self.continueButton.frame.height)
                self.continueButton.alpha = 0
                self.phoneNumberTextField.alpha = 0
            }) { _ in
                self.phoneNumberTextField.isHidden = true
                self.continueButton.isHidden = true
                self.VerificationTextField.isHidden = false
                self.verificationLabel.isHidden = false
                self.view.addSubview(self.VerificationTextField)
                UIView.animate(withDuration: 0.5, animations: {
                    self.VerificationTextField.frame = CGRect(x: 15, y: self.verificationLabel.frame.maxY + 10, width: self.phoneNumberTextField.frame.width, height: 53)
                    self.VerificationTextField.center.x = self.view.center.x
                    self.VerificationTextField.alpha = 1
                    self.VerificationTextField.becomeFirstResponder()

                })
            }
        }
    }
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count ?? 0 == 10 && ((textField.text?.isPhone()) != nil) && textField.text?.isPhone() == true {
            continueButton.blueifyButton()
        } else {
            continueButton.greyOut()
        }
    }
    

}
extension UIButton {
    func greyOut() {
        self.backgroundColor = .lightGray.withAlphaComponent(0.4)
        self.layer.cornerRadius = 10
        self.layer.shadowColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor
        self.layer.shadowOffset = CGSize(width: 4, height: 10)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 10
        self.isUserInteractionEnabled = false
    }
    func blueifyButton() {
        self.backgroundColor = Constants.primaryColor.hexToUiColor()
        self.layer.cornerRadius = 4
       self.layer.shadowColor = Constants.primaryColor.hexToUiColor().withAlphaComponent(0.3).cgColor
        self.layer.shadowOffset = CGSize(width: 4, height: 10)
        self.layer.shadowOpacity = 0.5
       self.layer.shadowRadius = 4
        self.isUserInteractionEnabled = true
    }
}
extension String {
    
    public func isPhone()->Bool {
        if self.isAllDigits() == true {
            let phoneRegex = "[235689][0-9]{6}([0-9]{3})?"
            let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return  predicate.evaluate(with: self)
        }else {
            return false
        }
    }
    
    private func isAllDigits()->Bool {
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = self.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  self == filtered
    }
}

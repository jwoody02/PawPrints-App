//
//  SearchViewController.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/2/23.
//

import Foundation
import UIKit
import TransitionButton
import Firebase
// MARK: - SearchViewController
class SearchViewController: BaseViewController {
    // MARK: - Public API
    var searchResults: [Any] = [] {
        didSet {
//            updateUI()
        }
    }
    let varietyPackHeight = ((UIScreen.main.bounds.width - 50) / 2) * (9 / 11)
    // 9 : 11 aspect ratio for variety images so that 2 images fit on the screen
    var varietyImageSize: CGSize = CGSize(width:0, height: 0)
    // MARK: - Private API
    lazy var searchForPacksLabel: UILabel = {
        let label = UILabel()
        label.text = "Search"
        label.font = UIFont(name: "AvenirNext-Bold", size: 20)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.frame = CGRect(x: 30, y: 100, width: 200, height: 21)

        return label
    }()
    lazy var searchForPacksTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Search for Packs..."
        textField.font = UIFont(name: "AvenirNext-Regular", size: 14)
        textField.textColor = Constants.textColor.hexToUiColor()
        textField.textAlignment = .left
        textField.styleSearchBar()
        textField.borderStyle = .none
        textField.textColor = Constants.textColor.hexToUiColor()
        textField.backgroundColor = Constants.surfaceColor.hexToUiColor()
        textField.frame = CGRect(x: 30, y: 140, width: UIScreen.main.bounds.width - 60, height: 50)
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 50))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.delegate = self
        return textField
    }()

    lazy var limitedTimePacksLabel: UILabel = {
        let label = UILabel()
        label.text = "Limited Packs"
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.frame = CGRect(x: 30, y: 20, width: 200, height: 21)
        label.alpha = 0
        return label
    }()
    lazy var limitedTimePacksCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 20, right: 10)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: limitedTimePacksLabel.frame.minY + 10, width: UIScreen.main.bounds.width, height: 200), collectionViewLayout: layout)
        collectionView.backgroundColor = Constants.backgroundColor.hexToUiColor()
        collectionView.register(UINib(nibName: "LimitedCollectionCell", bundle: nil), forCellWithReuseIdentifier: "LimitedPackCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    lazy var noLimitedPacksLabel: UILabel = {
        let label = UILabel()
        label.text = "No Limited Packs"
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.frame = CGRect(x: limitedTimePacksCollectionView.frame.minX, y: limitedTimePacksCollectionView.frame.minY + 40, width: limitedTimePacksCollectionView.frame.width, height: 21)
        label.alpha = 0
        return label
    }()
    lazy var varietyPacksLabel: UILabel = {
        let label = UILabel()
        label.text = "Variety Packs"
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.frame = CGRect(x: 30, y: limitedTimePacksCollectionView.frame.minY + 170, width: 200, height: 21)
        label.alpha = 0
        return label
    }()
    lazy var varietyPacksCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 10, left: 20, bottom: 0, right: 20)
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: varietyPacksLabel.frame.minY + 10, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        collectionView.backgroundColor = .clear
        collectionView.register(UINib(nibName: "VarietyPackCell", bundle: nil), forCellWithReuseIdentifier: "VarietyPackCollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    lazy var noVarietyPacksLabel: UILabel = {
        let label = UILabel()
        label.text = "No Variety Packs"
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textColor = .gray
        label.textAlignment = .center
        label.frame = CGRect(x: varietyPacksCollectionView.frame.minX, y: varietyPacksCollectionView.frame.minY + 40, width: varietyPacksCollectionView.frame.width, height: 21)
        label.alpha = 0
        return label
    }()
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect(x: 0, y: searchForPacksTextField.frame.maxY + 10, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 10 - searchForPacksTextField.frame.maxY))
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 100)
        scrollView.backgroundColor = Constants.backgroundColor.hexToUiColor()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        return scrollView
    }()
    var limitedPacks = [LimitedPack]()
    var varietyPacks = [VarietyPack]()

    var searchlimitedPacks = [LimitedPack]()
    var searchvarietyPacks = [VarietyPack]()

    var isSearching = false

    // MARK: - viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor.hexToUiColor()
        view.addSubview(searchForPacksLabel)
        view.addSubview(searchForPacksTextField)
        scrollView.addSubview(limitedTimePacksLabel)
        scrollView.addSubview(limitedTimePacksCollectionView)
        scrollView.addSubview(varietyPacksLabel)
        scrollView.addSubview(varietyPacksCollectionView)
        scrollView.addSubview(noLimitedPacksLabel)
        scrollView.addSubview(noVarietyPacksLabel)
        view.addSubview(scrollView)
        self.hideKeyboardWhenTappedAround()
        scrollView.hideKeyboardWhenTappedAround()
        updateLimitedPacks()
        updateVarietyPacks()
        // move limited pack label to front
        scrollView.bringSubviewToFront(limitedTimePacksLabel)
        scrollView.sendSubviewToBack(limitedTimePacksCollectionView)
        scrollView.sendSubviewToBack(varietyPacksCollectionView)
        view.bringSubviewToFront(searchForPacksTextField)
        view.bringSubviewToFront(searchForPacksLabel)
//        let varietyImageAspectRatio: CGFloat = 9 / 11
//        let varietyImageWidth: CGFloat = (UIScreen.main.bounds.width - 40) / 2
//        let varietyImageHeight: CGFloat = self.varietyImageWidth * self.varietyImageAspectRatio
//        varietyImageSize: CGSize = CGSize(width: self.varietyImageWidth, height: self.varietyImageHeight)
        self.navigationController?.isNavigationBarHidden = true
    }
    // MARK: - Update Limited Packs
    func updateLimitedPacks() {
        // fetch limited packs
        guard let _ = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        LimitedPack.fetchLimitedPacks() { (limitedPacks) in
            if limitedPacks.count == 0 {
                // show no limited packs label
                self.noLimitedPacksLabel.fadeIn()
            } else {
                self.limitedPacks = limitedPacks
                self.limitedTimePacksLabel.fadeIn()
                self.limitedTimePacksCollectionView.reloadData()
            }
            
        }
    }
    // MARK: - Update Variety Packs
    func updateVarietyPacks() {
        // fetch variety packs
        guard let _ = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        VarietyPack.fetchVarietyPacks() { (varietyPacks) in
            print("* got \(varietyPacks.count) variety packs")
            if varietyPacks.count == 0 {
                // show no variety packs label
                self.noVarietyPacksLabel.fadeIn()
            } else {
                self.varietyPacks = varietyPacks
                self.noVarietyPacksLabel.fadeOut()
                let heightNeeded = CGFloat(ceil(Double(self.varietyPacks.count) / 2)) * self.varietyPackHeight
                // update scroll view and over estimate by adding variety pack height
                self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: self.varietyPacksLabel.frame.maxY + heightNeeded + self.varietyPackHeight)
                UIView.animate(withDuration: 0.3, animations: {
                    self.varietyPacksCollectionView.reloadData()
                    self.varietyPacksLabel.alpha = 1
                })
            }
        }
    }
    init(showPushButton: Bool = false) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        toogleTabbar(hide: false)
    }
    func searchForPacks(searchTerm: String) {
        // search out varietyPacks array for searchTerm
        for pack in limitedPacks {
            if pack.title.lowercased().contains(searchTerm.lowercased()) {
                print("found \(pack.title)")
                searchlimitedPacks.append(pack)
            }
        }
        for pack in varietyPacks {
            if pack.title.lowercased().contains(searchTerm.lowercased()) {
                print("found \(pack.title)")
                searchvarietyPacks.append(pack)
            }
        }
        isSearching = true
        // update frames and hide if needed
        if searchlimitedPacks.count == 0 {
            // update no limited packs label
            noLimitedPacksLabel.fadeIn()
        } else {
            noLimitedPacksLabel.fadeOut()
        }
        if searchvarietyPacks.count == 0 {
            // update no variety packs label
            noVarietyPacksLabel.fadeIn()
        } else {
            noVarietyPacksLabel.fadeOut()
        } 
        limitedTimePacksCollectionView.reloadData()
        varietyPacksCollectionView.reloadData()

    }
}
extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // text did change
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // get text
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        // if text is empty, set isSearching to false
        if text == "" {
            isSearching = false
            searchlimitedPacks = []
            searchvarietyPacks = []
            if limitedPacks.count == 0 {
                noLimitedPacksLabel.fadeIn()
            } else {
                noLimitedPacksLabel.fadeOut()
            }
            if varietyPacks.count == 0 {
                noVarietyPacksLabel.fadeIn()
            } else {
                noVarietyPacksLabel.fadeOut()
            }
            UIView.animate(withDuration: 0.3, animations: {
                self.limitedTimePacksCollectionView.reloadData()
                self.varietyPacksCollectionView.reloadData()
            })
            // limitedTimePacksCollectionView.reloadData()
            // varietyPacksCollectionView.reloadData()
        } else {
            searchlimitedPacks = []
            searchvarietyPacks = []
            // search for packs
            searchForPacks(searchTerm: text)
        }

        return true
    }

}
// MARK: - Collection View
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == limitedTimePacksCollectionView {
            if isSearching {
                return searchlimitedPacks.count
            }
            return limitedPacks.count
        } else {
            if isSearching {
                return searchvarietyPacks.count
            }
            return varietyPacks.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // for now reuse the same cell for both
        if collectionView == limitedTimePacksCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LimitedPackCollectionViewCell", for: indexPath) as! LimitedPackCollectionViewCell
            if isSearching {
                cell.limitedPack = searchlimitedPacks[indexPath.row]
            } else {
                cell.limitedPack = limitedPacks[indexPath.row]
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VarietyPackCollectionViewCell", for: indexPath) as! VarietyPackCollectionViewCell
            if isSearching {
                cell.varietyPack = searchvarietyPacks[indexPath.row]
            } else {
                cell.varietyPack = varietyPacks[indexPath.row]
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let packSize = CGSize(width: 220, height: 160)
        if collectionView == limitedTimePacksCollectionView {
            return packSize
        } else {
            return CGSize(width: (UIScreen.main.bounds.width - 50) / 2, height: varietyPackHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == limitedTimePacksCollectionView {
            if isSearching {
                self.showPack(pack: searchlimitedPacks[indexPath.item])
            } else {
                self.showPack(pack: limitedPacks[indexPath.item])
            }
        } else {
            if isSearching {
                self.showPack(pack: searchvarietyPacks[indexPath.item])
            } else {
                self.showPack(pack: varietyPacks[indexPath.item])
            }
        }
    }
    // set spacing between cells to 0
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == limitedTimePacksCollectionView {
            return 0
        } else {
            return 10
        }
    }
}

//
//  ViewController.swift
//  PrinterestTabBar
//
//  Created by Christophe Hoste on 29.03.20.
//  Copyright © 2020 Christophe Hoste. All rights reserved.
//

import UIKit
import Firebase
import PageControls
import SkeletonView
import TransitionButton
class ViewController: BaseViewController {
    var currentIndex = 0
    var timer : Timer?
    lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Push new VC", for: .normal)
        button.addTarget(self, action: #selector(handeAction(_:)), for: .touchUpInside)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        button.titleEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8)
        button.constrainWidth(constant: 150)
        return button
    }()
    lazy var LimitedPacksLabel: UILabel = {
        let label = UILabel()
        label.text = "Limited Edition Packs"
        // label.font = UIFont.boldSystemFont(ofSize: 20)
        label.font = UIFont(name: "AvenirNext-Bold", size: 16)
        label.frame = CGRect(x: 30, y: 100, width: 200, height: 21)
        label.isUserInteractionEnabled = false
        return label
    }()
    lazy var littleRedDot: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.frame = CGRect(x: 193, y: 103, width: 5, height: 5)
        view.layer.cornerRadius = 2.5
        view.layer.masksToBounds = true
        return view
    }()
    lazy var SignedInLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        // Check if signed in or anonymous

        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        if Auth.auth().currentUser != nil {
            // check if anonymous
            if Auth.auth().currentUser?.isAnonymous == true {
                label.text = "Signed In Anonymously"
                label.textColor = "#8B0000".hexToUiColor()
            } else {
                label.text = "Signed In ✓"
                label.textColor = "#00A86B".hexToUiColor()
            }
        } else {
            label.text = "Not Signed In"
            label.textColor = "#8B0000".hexToUiColor()
            
        }

        label.frame = CGRect(x: UIScreen.main.bounds.width - 155, y: 60, width: 120, height: 30)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.isHidden = true
        return label
    }()
    lazy var NoLimitedPacksLabel: UILabel = {
        let label = UILabel()
        label.text = "No Limited Packs Available Please check back later"
        // label.font = UIFont.boldSystemFont(ofSize: 14)
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.numberOfLines = 2
        label.textColor = .gray
        label.textAlignment = .center
        label.frame = CGRect(x: 30, y: 240, width: 220, height: 40)
        label.center.x = UIScreen.main.bounds.width / 2
        label.isHidden = true
//        label.backgroundColor = .red
        return label
    }()
    lazy var noLimitedPacksImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "clock.arrow.circlepath")
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 160, width: 60, height: 60)
        imageView.tintColor = .gray
        imageView.center.x = UIScreen.main.bounds.width / 2
        imageView.isHidden = true
        return imageView
    }()
    lazy var PacksViewAllButton : UIButton = {
        let button = UIButton()
        button.setTitle("View All ➜", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .lightGray.withAlphaComponent(0.2)
        // button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 12)
        button.frame = CGRect(x: UIScreen.main.bounds.width - 110, y: 100, width: 80, height: 24)
        button.center.y = LimitedPacksLabel.center.y
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleViewAllPacks), for: .touchUpInside)
        return button
    }()
    var orders = [Order]()
    lazy var ordersTableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OrderTableViewCell.self, forCellReuseIdentifier: "OrderTableViewCell")
        return tableView
    }()
    
    var limitedPacks = [LimitedPack]()
    lazy var limitedPacksCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        // collectionView.register(LimitedPackCollectionViewCell.self, forCellWithReuseIdentifier: "LimitedPackCollectionViewCell")
        collectionView.register(UINib(nibName: "LimitedCollectionCell", bundle: nil), forCellWithReuseIdentifier: "LimitedPackCollectionViewCell")
        collectionView.frame = CGRect(x: 0, y: LimitedPacksLabel.frame.maxY + 10, width: UIScreen.main.bounds.width, height: 240)
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alpha = 0
        collectionView.isSkeletonable = true
        collectionView.isPagingEnabled = true
        // add some padding for first cell
        // collectionView.contentInset = UIEdgeInsets(top: 0, left: LimitedPacksLabel.frame.minX - 10, bottom: 0, right: LimitedPacksLabel.frame.minX - 10)
//        collectionView.sectionInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 30)
        return collectionView
    }()
    lazy var orderUpdatesLabel: UILabel = {
        let label = UILabel()
        label.text = "Order Updates"
        // label.font = UIFont.boldSystemFont(ofSize: 20)
        label.font = UIFont(name: "AvenirNext-Bold", size: 16)
        label.frame = CGRect(x: 30, y: 370, width: 220, height: 21)
        return label
    }()
    lazy var noOrderUpdatesLabel: UILabel = {
        let label = UILabel()
        label.text = "No order updates, looks like you're all caught up!"
        // label.font = UIFont.boldSystemFont(ofSize: 14)
        label.font = UIFont(name: "AvenirNext-Bold", size: 14)
        label.textColor = .gray
        label.numberOfLines = 2
        label.textAlignment = .center
        label.frame = CGRect(x: 30, y: 520, width: 220, height: 50)
        label.center.x = UIScreen.main.bounds.width / 2
        label.isHidden = false
        return label
    }()
    lazy var noOrderUpdatesImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle")
        imageView.contentMode = .scaleAspectFit
        // put it right above the label
        imageView.frame = CGRect(x: 0, y: 440, width: 60, height: 60)
        imageView.tintColor = .gray
        imageView.center.x = UIScreen.main.bounds.width / 2
        imageView.isHidden = false
        return imageView
    }()
    lazy var viewAllOrdersButton: UIButton = {
        let button = UIButton()
        button.setTitle("View All ➜", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        button.backgroundColor = .lightGray.withAlphaComponent(0.2)
        // button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        button.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 12)
        button.frame = CGRect(x: UIScreen.main.bounds.width - 110, y: 350, width: 80, height: 24)
        button.center.y = orderUpdatesLabel.center.y
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleViewAllOrders(_:)), for: .touchUpInside)
        return button
    }()
    // MARK: - Page indicator with page controls framework
    lazy var pageControl: PillPageControl = {
        let pageControl = PillPageControl()
        pageControl.pageCount = 3
//        pageControl.currentPage = 0
        pageControl.backgroundColor = .clear
        pageControl.inactiveTint = .lightGray.withAlphaComponent(0.6)
        pageControl.activeTint = Constants.textColor.hexToUiColor().withAlphaComponent(0.7)
        pageControl.frame = CGRect(x: 0, y: 355, width: 100, height: 15)

        pageControl.sizeToFit()
        pageControl.center.x = UIScreen.main.bounds.width / 2
        pageControl.alpha = 0
        return pageControl
    }()
    // main scroll view for the whole page
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        // scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 1000)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        return scrollView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(LimitedPacksLabel)
        view.addSubview(NoLimitedPacksLabel)
        // view.addSubview(littleRedDot)
        view.addSubview(orderUpdatesLabel)
        view.addSubview(noOrderUpdatesLabel)
        view.addSubview(PacksViewAllButton)
        view.addSubview(viewAllOrdersButton)
        view.addSubview(noOrderUpdatesImageView)
        view.addSubview(noLimitedPacksImageView)
        view.addSubview(limitedPacksCollectionView)
        view.addSubview(pageControl)
        view.addSubview(SignedInLabel)
//        limitedPacksCollectionView.prepareSkeleton { (done) in
//                    self.limitedPacksCollectionView.showSkeleton()
//                }
        fetchLimitedPacks()
        fetchOrderUpdates()
        if Auth.auth().currentUser == nil {
            Auth.auth().signInAnonymously { (result, error) in
                if let error = error {
                    print("Failed to sign in anonymously with error: ", error.localizedDescription)
                    return
                }
                print("Successfully signed in anonymously with uid: ", result?.user.uid ?? "")
                self.fetchLimitedPacks()
                self.fetchOrderUpdates()
            }
        } 
//        view.addSubview(SignedInLabel)
//        view.addSubview(limitedPacksCollectionView)
//        view.addSubview(ordersTableView)
        
        // move PacksViewAllButton to front
        view.bringSubviewToFront(PacksViewAllButton)
        self.navigationController?.isNavigationBarHidden = true
        // move limited edition stuff to back
        view.sendSubviewToBack(limitedPacksCollectionView)
    }
    func fetchOrderUpdates() {
        // make sure we have valid user auth
        guard let _ = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
//        self.orders = Order.fetchOrdersByOrderDate()
//        if self.orders.count == 0 {
//            self.noOrderUpdatesLabel.isHidden = false
//        } else {
//            self.noOrderUpdatesLabel.isHidden = true
//            self.noOrderUpdatesLabel.removeFromSuperview()
//            self.noOrderUpdatesImageView.removeFromSuperview()
//        }
//        self.ordersTableView.reloadData()
    }
    func fetchLimitedPacks() {
        // make sure we have valid user auth
        guard let _ = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        LimitedPack.fetchLimitedPacks() { (limitedPacks) in
            self.limitedPacks = limitedPacks
            
             if self.limitedPacks.count == 0 {
                // animate in
                self.NoLimitedPacksLabel.fadeIn()
                self.noLimitedPacksImageView.fadeIn()
                
            } else {
                // animate out and remove from superview
                self.NoLimitedPacksLabel.fadeOut()
                self.noLimitedPacksImageView.fadeOut()
                
                self.pageControl.pageCount = self.limitedPacks.count
                self.pageControl.frame = CGRect(x: 0, y: 360, width: 100, height: 15)
                self.pageControl.sizeToFit()
                self.pageControl.center.x = UIScreen.main.bounds.width / 2
                
                self.limitedPacksCollectionView.reloadData()

                // wait 0.3 seconds and then remove from super view
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//                    self.limitedPacksCollectionView.hideSkeleton()
                    self.NoLimitedPacksLabel.removeFromSuperview()
                    self.noLimitedPacksImageView.removeFromSuperview()
                    self.limitedPacksCollectionView.layoutIfNeeded()
                    self.limitedPacksCollectionView.layoutSubviews()
                    self.limitedPacksCollectionView.fadeIn()
                    if self.limitedPacks.count > 1 {
                        self.pageControl.fadeIn()
                        self.startTimer()
                    }
                }
            }
        }
       

    }
    // MARK - Timer stuff
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    @objc func timerAction(){
        let desiredScrollPosition = (currentIndex < limitedPacks.count - 1) ? currentIndex + 1 : 0
        // scroll to the desired position
        let indexPath = IndexPath(item: desiredScrollPosition, section: 0)
        limitedPacksCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    init(showPushButton: Bool = false) {
        super.init(nibName: nil, bundle: nil)

        if showPushButton {
//            setupButton()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        toogleTabbar(hide: false)
    }

    func setupButton() {

        view.addSubview(button)
        button.centerInSuperview()
    }

    @objc
    func handeAction(_ sender: UIButton) {
        let newVC = PushViewController()
        navigationController?.navigationBar.tintColor = Constants.textColor.hexToUiColor()
        navigationController?.pushViewController(newVC, animated: true)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // handleViewAllOrders
    @objc func handleViewAllOrders(_ sender: UIButton) {
        // vibrate
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // go to orders page by tapping 3rd tab
        let tabBarController = self.tabBarController
        if let tabBarController = tabBarController as? Tabbarcontoller {
            
            tabBarController.changeTab(index: 2)
        }
    }
    // handleViewAllPacks
    @objc func handleViewAllPacks(_ sender: UIButton) {
        // vibrate
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        // go to packs page by tapping 2nd tab
        let tabBarController = self.tabBarController
        if let tabBarController = tabBarController as? Tabbarcontoller {
            
            tabBarController.changeTab(index: 1)
        }
    }
    func updateUI() {
        // update limited packs and order updates
        fetchLimitedPacks()
        fetchOrderUpdates()
    }
    
}
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SkeletonCollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LimitedPackCollectionViewCell", for: indexPath) as! LimitedPackCollectionViewCell
        cell.limitedPack = limitedPacks[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let newVC = PackViewerViewController()
//        navigationController?.navigationBar.tintColor = Constants.textColor.hexToUiColor()
//        newVC.pack = limitedPacks[indexPath.item]
//        navigationController?.pushViewController(newVC, animated: true)
//        if let tabbar = self.navigationController?.tabBarController as? Tabbarcontoller {
//            tabbar.toggle(hide: true)
//        }
        self.showPack(pack: limitedPacks[indexPath.item])
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return limitedPacks.count
    }
    // size of each cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // grab size of collectionView
        let collectionViewSize = collectionView.frame.height
        print("collectionViewSize: \(collectionViewSize)")
        // return size of cell
        return CGSize(width: collectionView.frame.width - 40, height: collectionViewSize)
    }
    // MARK: - Page indicator
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        let progressInPage = scrollView.contentOffset.x - (page * scrollView.bounds.width)
        let progress = CGFloat(page) + progressInPage
        pageControl.progress = progress
       
    }
    // listen for scrolling by user and stop timer
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        timer?.invalidate()
    }
    // spacing between cells
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "LimitedPackCollectionViewCell"
    }
    func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
}
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath) as! OrderTableViewCell
        cell.order = orders[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let newVC = OrderViewerViewController()
        navigationController?.navigationBar.tintColor = Constants.textColor.hexToUiColor()
        navigationController?.pushViewController(newVC, animated: true)
    }
    
    
}

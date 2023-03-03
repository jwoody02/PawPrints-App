//
//  OrdersViewController.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/2/23.
//

import Foundation
import UIKit
import FirebaseAuth
enum OrderStatus {
    case pending
    case training
    case generating_results
    case completed
    case failed
}
// MARK: - OrdersViewController
class OrdersViewController: BaseViewController {
    // MARK: - Public API
    // var orders: [Order] = [Order(name: "Test order", price: 399, preview_image: UIImage(named: "IMG_0892.tiff"), description: "", status: .completed, order_id: "test12354", transaction_id: "asd12123123", order_timestamp: "", result_sections: []), Order(name: "Graphic Pack #1", price: 399, preview_image: UIImage(named: "IMG_3580.tiff"), description: "", status: .training, order_id: "test12354", transaction_id: "asd12123123", order_timestamp: "", result_sections: [])] {
    var orders: [Order] = [] {
        didSet {
            updateUI()
        }
    }
    
    // MARK: - Private API
    lazy var ordersLabel: UILabel = {
        let label = UILabel()
        label.text = "Orders"
        label.font = UIFont(name: "AvenirNext-Bold", size: 20)
        label.textColor = Constants.textColor.hexToUiColor()
        label.textAlignment = .left
        label.frame = CGRect(x: 30, y: 100, width: 200, height: 21)
        
        return label
    }()
    
    lazy var noOrdersLabel: UILabel = {
        let label = UILabel()
        label.text = "No Orders Found"
        label.font = UIFont(name: "AvenirNext-Bold", size: 16)
        label.textColor = .gray
        label.textAlignment = .center
        label.isHidden = true
        label.frame = CGRect(x: 30, y: 300, width: UIScreen.main.bounds.width - 60, height: 50)
        return label
    }()
    
    // scroll view to hold "all", "In Progress", "Completed" buttons
    lazy var ordersScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 30, y: 140, width: UIScreen.main.bounds.width - 60, height: 50)
        scrollView.backgroundColor = Constants.backgroundColor.hexToUiColor()
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        // we want to scroll horizontally
        scrollView.isScrollEnabled = true
        
        // add buttons to scroll view
        let allButton = UIButton()
        allButton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        allButton.styleForOrders()
        allButton.setTitle("All", for: .normal)
        allButton.styleForSelectednotification()
        allButton.addTarget(self, action: #selector(allButtonPressed), for: .touchUpInside)
        scrollView.addSubview(allButton)
        
        let inProgressButton = UIButton()
        inProgressButton.frame = CGRect(x: 110, y: 0, width: 100, height: 40)
        inProgressButton.setTitle("In Progress", for: .normal)
        inProgressButton.styleForOrders()
        inProgressButton.addTarget(self, action: #selector(inProgressButtonPressed), for: .touchUpInside)
        scrollView.addSubview(inProgressButton)
        
        let completedButton = UIButton()
        completedButton.frame = CGRect(x: 220, y: 0, width: 100, height: 40)
        completedButton.setTitle("Completed", for: .normal)
        completedButton.styleForOrders()
        completedButton.addTarget(self, action: #selector(completedButtonPressed), for: .touchUpInside)
        scrollView.addSubview(completedButton)
        
        
        scrollView.contentSize = CGSize(width: completedButton.frame.maxY, height: 50)
        
        return scrollView
    }()
    lazy var ordersTableView: UITableView = {
        let tableView = UITableView()
        tableView.frame = CGRect(x: 30, y: ordersScrollView.frame.maxY + 10, width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height - (ordersScrollView.frame.maxY + 10))
        tableView.delegate = self
        tableView.dataSource = self
        // tableView.register(OrderTableViewCell.self, forCellReuseIdentifier: "OrderTableViewCell")
        
        tableView.register(UINib(nibName: "OrderTableViewCell", bundle: nil), forCellReuseIdentifier: "OrderTableViewCell")
        tableView.backgroundColor = Constants.backgroundColor.hexToUiColor()
        tableView.separatorStyle = .none
        tableView.rowHeight = 110
        return tableView
    }()
    // MARK: - viewdidload
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constants.backgroundColor.hexToUiColor()
        view.addSubview(ordersLabel)
        view.addSubview(ordersTableView)
        ordersTableView.reloadData()
        view.addSubview(noOrdersLabel)
        view.addSubview(ordersScrollView)
        // fetch all orders
        fetchAllOrders()
    }
    func resetbuttons() {
        // loop through subviews of scrollview and reset buttons
        for view in ordersScrollView.subviews {
            if let button = view as? UIButton {
                button.styleForOrders()
            }
        }
        
    }
    // MARK: - Button Actions
    @objc func allButtonPressed() {
        print("all button pressed")
        resetbuttons()
        if let button = ordersScrollView.subviews[0] as? UIButton {
            button.styleForSelectednotification()
        }
    }
    @objc func inProgressButtonPressed() {
        print("in progress button pressed")
        resetbuttons()
        if let button = ordersScrollView.subviews[1] as? UIButton {
            button.styleForSelectednotification()
        }
    }
    @objc func completedButtonPressed() {
        print("completed button pressed")
        resetbuttons()
        if let button = ordersScrollView.subviews[2] as? UIButton {
            button.styleForSelectednotification()
        }
        
    }
    func updateUI() {
        
    }
    func fetchAllOrders() {
        print("fetching all orders")
        orders = []
        // fetch using fetchOrdersByOrderDate
        guard let _ = Auth.auth().currentUser else {
            print("No user logged in")
            return
        }
        // fetch orders
        Order.fetchOrdersByOrderDate() { (ordersz) in
            // set orders
            self.orders = ordersz
            self.ordersTableView.reloadData()
            if self.orders.count == 0 {
                self.noOrdersLabel.isHidden = false
            } else {
                self.noOrdersLabel.isHidden = true
            }
            // go through images in each section and see if it's a url or not
            // asynchronously download images in queue
            
            // make asynchronous queue
            let queue = DispatchQueue(label: "com.image.downloader", attributes: .concurrent)
            // make group
            let group = DispatchGroup()
            var i = 0
            // loop through orders
            for order in self.orders {
                var j = 0
                // loop through images
                for section in order.result_sections ?? [] {
                    var k = 0
                    for image in section.images {
                        // check if image is a url
                        if image.storage_ref.contains("https") {
                            // download image
                            group.enter()
                            queue.async(group: group) {
                                let url = URL(string: image.storage_ref)
                                let data = try? Data(contentsOf: url!)
                                if let imageData = data {
                                    let image = UIImage(data: imageData)
                                    // add image to order
                                    self.orders[i].result_sections![j].images[k].image = image
                                    group.leave()
                                }
                            }
                        } else {
                            // add image to order
                            // order.imagesToDisplay.append(UIImage(named: image)!)
                            print("error with order image: not a url")
                        }
                        k += 1
                    }
                    j += 1
                }
                i += 1
            }
            group.notify(queue: .main) {
                self.ordersTableView.reloadData()
            }
        }
    }
}
extension OrdersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderTableViewCell", for: indexPath) as! OrderTableViewCell
        cell.selectionStyle = .none
        cell.order = orders[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected row")
        // vibration
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        // push OrderViewerViewController
        let orderViewerViewController = OrderViewerViewController()
        orderViewerViewController.order = orders[indexPath.row]
        navigationController?.pushViewController(orderViewerViewController, animated: true)
        
    }
}
extension UIButton {
    func styleForOrders() {
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 0
        self.backgroundColor = Constants.surfaceColor.hexToUiColor()
        self.setTitleColor(.gray, for: .normal)
        self.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        self.addBaseShadow()
        
    }
    
    func styleForSelectednotification() {
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.8).cgColor
        self.layer.shadowOffset = CGSize(width: 2, height: 4)
        self.layer.shadowOpacity = 0.6
        self.layer.shadowRadius = 4
        
        self.titleLabel?.font = UIFont(name: "AvenirNext-Bold", size: 14)
        self.setTitleColor(Constants.surfaceColor.hexToUiColor(), for: .normal)
        self.backgroundColor = Constants.textColor.hexToUiColor()
        self.tintColor = Constants.surfaceColor.hexToUiColor()
    }
}

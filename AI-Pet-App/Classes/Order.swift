//
//  Order.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/2/23.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase
import Kingfisher
class Order {
    // MARK: Public API
    var name: String
    var price: Int?
    var preview_image_url: String
    var packId = ""
    var description: String?
    var status: OrderStatus?
    var order_id: String?
    var transaction_id: String?
    var order_timestamp: String?
    // var result_images: [AIResultImage]?
    var result_sections: [ImageSection]?
    
    // MARK: Initialization
    init(name: String, price: Int?, preview_image: String?, description: String?, status: OrderStatus?, order_id: String?, transaction_id: String?, order_timestamp: String?, result_sections: [ImageSection]?, packId: String) {
        self.name = name
        self.price = price
        self.preview_image_url = preview_image ?? ""
        self.description = description
        self.status = status
        self.order_id = order_id
        self.transaction_id = transaction_id
        self.order_timestamp = order_timestamp
        self.result_sections = result_sections
        self.packId = packId
    }
    // completion handler
    static func fetchOrdersByOrderDate(completion: @escaping ([Order]) -> Void) {
        print("grabbing by date with userId \(Auth.auth().currentUser!.uid)")
        let db = Firestore.firestore()
        let docRef = db.collection("orders").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).order(by: "order_timestamp", descending: true).limit(to: 39)
        var orders = [Order]()
        // fetch orders and add to orders
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(orders)
            } else {
                print("got \(querySnapshot!.documents.count) orders")
                Order.getOrdersFromSnapshot(querySnapshot: querySnapshot!) { (orders) in
                    completion(orders)
                }
            }
        }
    }
    // Parse orders from snapshot from firestore
    static func getOrdersFromSnapshot(querySnapshot: QuerySnapshot, completion: @escaping ([Order]) -> Void) {
        var orders = [Order]()
        // do everything in background thread and then complete on main thread
        
        // dispatch group for us to join
        let group = DispatchGroup()
        // dispatch queue
        let queue = DispatchQueue(label: "com.ai-pet-app.orders", qos: .background)
       
            for document in querySnapshot.documents {
                group.enter()
                let data = document.data()
                let name = data["name"] as? String ?? ""
                //                    let price = data["price"] as? Int ?? ""
                //            let preview_image = UIImage(named: data["preview_image"] as? String ?? "")!
                let description = data["description"] as? String ?? ""
                let status_string = data["status"] as? String ?? ""
                var status: OrderStatus = OrderStatus.pending
                if status_string == "training" || status_string == "queued" {
                    status = OrderStatus.training
                } else if status_string == "completed" {
                    status = OrderStatus.completed
                } else if status_string == "failed" {
                    status = OrderStatus.failed
                } else if status_string == "generating" {
                    status = OrderStatus.generating_results
                }
                let order_id = data["orderId"] as? String ?? ""
                let transaction_id = data["orderId"] as? String ?? ""
                let order_timestamp = String(data["order_timestamp"] as? Double ?? 0.0)
                var result_images: [ImageSection] = []
                // check if result_images is an array or a dictionary
                if let resulting_images = data["result_images"] as? [String] {
                    print("result_images is an array, creating section with name All")
                    // create a section with name All
                    let section = ImageSection(name: "All", images: [])
                    for image in resulting_images {
                        let ai_result_image = AIResultImage(image: nil, storage_ref: image, section_: "All")
                        section.images.append(ai_result_image)
                    }
                    result_images.append(section)
                }
                if let resulting_images = data["result_images"] as? [String: Any] {
                    print("result_images is a dictionary, creating sections")
                    // create sections
                    for (key, value) in resulting_images {
                        let section = ImageSection(name: key, images: [])
                        if let images = value as? [String] {
                            for image in images {
                                let ai_result_image = AIResultImage(image: nil, storage_ref: image, section_: key)
                                section.images.append(ai_result_image)
                            }
                        }
                        result_images.append(section)
                    }
                }
                var previewImage: UIImage? = nil
                var packName = ""
                // now check if pack_id exists, if it does we need to fetch the pack name and preview image from firebase database
                if let pack_id = data["packId"] as? String {
                    print("pack_id exists, fetching pack name and preview image")
                    // firestore database reference NOT firestore
                    let db = Database.database().reference()
                    // now check limited_packs first and then variety_packs if it doesn't exist
                    db.child("limited_packs").child(pack_id).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        let pack_name = value?["title"] as? String ?? ""
                        let pack_preview_image_url = value?["featuredImage"] as? String ?? ""
                        // download from url
                        let url = URL(string: pack_preview_image_url)
                        if let url = url {
                            // add to preview_image_url
                            let order = Order(name: pack_name, price: 0, preview_image: pack_preview_image_url, description: description, status: status, order_id: order_id, transaction_id: transaction_id, order_timestamp: order_timestamp, result_sections: result_images, packId: pack_id)
                            orders.append(order)
                            print("added order with pack_id \(pack_id)")
                            group.leave()
                        } else {
                            print("url is nil, trying variety packs")
                            db.child("variety_packs").child(pack_id).observeSingleEvent(of: .value, with: { (snapshot) in
                            // Get user value
                            let value = snapshot.value as? NSDictionary
                            let pack_name = value?["title"] as? String ?? ""
                            let pack_preview_image_url = value?["featuredImage"] as? String ?? ""
                            print("downloaded preview image from \(pack_preview_image_url)")
                            // download from url
                            let url = URL(string: pack_preview_image_url)
                            if let url = url {
                                let order = Order(name: pack_name, price: 0, preview_image: pack_preview_image_url, description: description, status: status, order_id: order_id, transaction_id: transaction_id, order_timestamp: order_timestamp, result_sections: result_images, packId: pack_id)
                                orders.append(order)
                                print("added order with pack_id \(pack_id)")
                                group.leave()
                            }
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                        }
                        
                    }) { (error) in
                        print(error.localizedDescription)
                        db.child("variety_packs").child(pack_id).observeSingleEvent(of: .value, with: { (snapshot) in
                            // Get user value
                            let value = snapshot.value as? NSDictionary
                            let pack_name = value?["title"] as? String ?? ""
                            let pack_preview_image_url = value?["featuredImage"] as? String ?? ""
                            print("downloaded preview image from \(pack_preview_image_url)")
                            // download from url
                            let url = URL(string: pack_preview_image_url)
                            if let url = url {
                                let order = Order(name: pack_name, price: 0, preview_image: pack_preview_image_url, description: description, status: status, order_id: order_id, transaction_id: transaction_id, order_timestamp: order_timestamp, result_sections: result_images, packId: pack_id)
                                orders.append(order)
                                print("added order with pack_id \(pack_id)")
                                group.leave()
                            }
                        }) { (error) in
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        
        group.notify(queue: .main) {
            print("finished fetching \(orders.count) orders")
            completion(orders)
        }
    }
    
    
    func fetchOrdersByLatestUpdate(completion: @escaping ([Order]) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("orders").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).order(by: "latest_update_timestamp", descending: true).limit(to: 39)
        var orders = [Order]()
        // fetch orders and add to orders
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(orders)
            } else {
                print("got \(querySnapshot!.documents.count) orders")
                Order.getOrdersFromSnapshot(querySnapshot: querySnapshot!) { (orders) in
                    completion(orders)
                }
            }
        }
    }
    func fetchCompletedOrders(completion: @escaping ([Order]) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("orders").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).whereField("status", isEqualTo: "completed").order(by: "order_timestamp", descending: true).limit(to: 39)
        var orders = [Order]()
        // fetch orders and add to orders
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(orders)
            } else {
                print("got \(querySnapshot!.documents.count) orders")
                Order.getOrdersFromSnapshot(querySnapshot: querySnapshot!) { (orders) in
                    completion(orders)
                }
                
            }
        }
    }
    func fetchInProgressOrders(completion: @escaping ([Order]) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("orders").whereField("userId", isEqualTo: Auth.auth().currentUser!.uid).whereField("status", isNotEqualTo: "completed").order(by: "order_timestamp", descending: true).limit(to: 39)
        var orders = [Order]()
        // fetch orders and add to orders
        docRef.getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(orders)
            } else {
                print("got \(querySnapshot!.documents.count) orders")
                Order.getOrdersFromSnapshot(querySnapshot: querySnapshot!) { (orders) in
                    completion(orders)
                }
            }
        }
    }
}

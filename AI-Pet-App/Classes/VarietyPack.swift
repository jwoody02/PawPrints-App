//
//  VarietyPack.swift
//  AI-Pet-App
//
//  Created by Jordan Wood on 1/2/23.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
class VarietyPack {
    // MARK: - Public API
    var title = ""
    var subtitle = ""
    var description = ""
    var featuredImage: UIImage
    var price = 0
    var internal_id = ""
    var demo_order: Order?
    var expire_timestamp: String? // we don't want user to make order after this time
    var banner_message: String? // we want to show this message to user (potentially)
    var index = 0

    // MARK: - Initialization
    init(title: String, subtitle: String, description: String, featuredImage: UIImage, price: Int, internal_id: String, demo_order: Order?, expire_timestamp: String?, banner_message: String?, index: Int?) {
        self.title = title
        self.subtitle = subtitle
        self.description = description
        self.featuredImage = featuredImage
        self.price = price
        self.internal_id = internal_id
        self.demo_order = demo_order
        self.expire_timestamp = expire_timestamp
        self.banner_message = banner_message
        if let index = index {
            self.index = index
        }
    }
    // MARK: - private API ( OLD FIRESTORE VERSION )
    // static func fetchVarietyPacks() -> [VarietyPack] {
    //     var varietyPacks = [VarietyPack]()
    //     let db = Firestore.firestore()
    //     let docRef = db.collection("variety_packs").whereField("is_available", isEqualTo: true)
    //     // fetch variety packs and add to varietyPacks
    //     docRef.getDocuments { (querySnapshot, err) in
    //         if let err = err {
    //             print("Error getting documents: \(err)")
    //         } else {
    //             for document in querySnapshot!.documents {
    //                 let data = document.data()
    //                 let title = data["title"] as? String ?? ""
    //                 let subtitle = data["subtitle"] as? String ?? ""
    //                 let description = data["description"] as? String ?? ""
    //                 let featuredImage = UIImage(named: data["featuredImage"] as? String ?? "")!
    //                 let price = data["price"] as! Int
    //                 let internal_id = data["internal_id"] as? String ?? ""
    //                 let demo_order = Order(name: data["demo_order_name"] as? String ?? "", price: data["demo_order_price"] as! Int, preview_image: UIImage(named: data["demo_order_preview_image"] as? String ?? ""), description: data["demo_order_description"] as? String, status: data["demo_order_status"] as? String, order_id: data["demo_order_order_id"] as? String, transaction_id: data["demo_order_transaction_id"] as? String, order_timestamp: data["demo_order_order_timestamp"] as? String, result_images: data["demo_order_result_images"] as? [AIResultImage])
    //                 let varietyPack = VarietyPack(title: title, subtitle: subtitle, description: description, featuredImage: featuredImage, price: price, internal_id: internal_id, demo_order: demo_order)
    //                 varietyPacks.append(varietyPack)
    //             }
    //         }
    //     }
    //     return varietyPacks
    // }
    
    // fetch variety packs from real time database (not firestore)
    static func fetchVarietyPacks(completion: @escaping ([VarietyPack]) -> Void) {
        var varityPacks = [VarietyPack]()
        let db = Database.database().reference()
        let docRef = db.child("variety_packs")
        // fetch limited packs and add to limitedPacks
        docRef.observeSingleEvent(of: .value, with: { (snapshot) in
        print("snapshot: \(snapshot)")
        print("number of variety packs: \(snapshot.childrenCount)")
        // queue so we can wait for all images to download
        let queue = DispatchQueue(label: "varityPacks")
        queue.async {
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let data = snap.value as! [String: Any]
                let title = data["title"] as? String ?? ""
                let subtitle = data["subtitle"] as? String ?? ""
                let description = data["description"] as? String ?? ""
                // get url to download from
                let featuredImageURL = data["featuredImage"] as? String ?? ""
                // download image from url, check if everything is valid, other wise skip
                if let url = URL(string: featuredImageURL) {
                    do {
                        let imageData = try Data(contentsOf: url)
                        let featuredImage = UIImage(data: imageData)
                        let price = data["price"] as? Int ?? 0
                        let internal_id = data["internal_id"] as? String ?? ""
                        // let demo_order = Order(name: data["demo_order_name"] as? String ?? "", price: data["demo_order_price"] as! Int, preview_image: UIImage(named: data["demo_order_preview_image"] as? String ?? ""), description: data["demo_order_description"] as? String, status: data["demo_order_status"] as? String, order_id: data["demo_order_order_id"] as? String, transaction_id: data["demo_order_transaction_id"] as? String, order_timestamp: data["demo_order_order_timestamp"] as? String, result_images: data["demo_order_result_images"] as? [AIResultImage])
                        // check if demo_order_id and demo_order_user_id are valid
                        let demo_order_id = data["demo_order_id"] as? String ?? ""
                        let demo_order_user_id = data["demo_order_user_id"] as? String ?? ""
                        var demo_order: Order?
                        // if both are valid, fetch demo order from firestore
                        if demo_order_id != "" && demo_order_user_id != "" {
                            let db = Firestore.firestore()
                            let docRef = db.collection("orders").document(demo_order_id)
                            docRef.getDocument { (document, error) in
                                if let document = document, document.exists {
                                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                                    print("Document data: \(dataDescription)")
                                    let name = document.get("name") as? String ?? ""
                                    let price = document.get("price") as? Int ?? 0
//                                    let preview_image = UIImage(named: document.get("preview_image") as? String ?? "")
                                    let description = document.get("description") as? String ?? ""
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
                                    let order_id = document.get("order_id") as? String ?? ""
                                    let transaction_id = document.get("transaction_id") as? String ?? ""
                                    let order_timestamp = document.get("order_timestamp") as? String ?? ""
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
                                    let order = Order(name: name, price: price, preview_image: "", description: description, status: status, order_id: order_id, transaction_id: transaction_id, order_timestamp: order_timestamp, result_sections: result_images, packId: document.get("pack_id") as? String ?? "")
                                    demo_order = order
                                    let expire_timestamp = data["expire_timestamp"] as? String
                                    let banner_message = data["banner_message"] as? String
                                    if let featuredImage = featuredImage {
                                        let varietyPack = VarietyPack(title: title, subtitle: subtitle, description: description, featuredImage: featuredImage, price: price, internal_id: internal_id, demo_order: demo_order, expire_timestamp: expire_timestamp, banner_message: banner_message, index: data["index"] as? Int ?? 0)
                                        varityPacks.append(varietyPack)
                                    } else {
                                        print("* looks like featured image isn't valid")
                                    }
                                } else {
                                    print("Document does not exist")
                                    // add without demo order
                                    let expire_timestamp = data["expire_timestamp"] as? String
                                    let banner_message = data["banner_message"] as? String
                                    if let featuredImage = featuredImage {
                                        let varietyPack = VarietyPack(title: title, subtitle: subtitle, description: description, featuredImage: featuredImage, price: price, internal_id: internal_id, demo_order: nil, expire_timestamp: expire_timestamp, banner_message: banner_message, index: data["index"] as? Int ?? 0)
                                        varityPacks.append(varietyPack)
                                    } else {
                                        print("* looks like featured image isn't valid")
                                    }
                                }
                            }
                        } else {
                            let expire_timestamp = data["expire_timestamp"] as? String
                            let banner_message = data["banner_message"] as? String
                            if let featuredImage = featuredImage {
                                let varietyPack = VarietyPack(title: title, subtitle: subtitle, description: description, featuredImage: featuredImage, price: price, internal_id: internal_id, demo_order: nil, expire_timestamp: expire_timestamp, banner_message: banner_message, index: data["index"] as? Int ?? 0)
                                varityPacks.append(varietyPack)
                            } else {
                                print("* looks like featured image isn't valid")
                            }
                        }
                        
                        
                    } catch {
                        print("error: \(error)")
                    }
                }
            }
        }
        // wait for all images to download
        queue.sync {
            print("done downloading images")
             // sort limited packs by index
            varityPacks.sort(by: { $0.index < $1.index })
            // call completion handler
                completion(varityPacks)
        }
       
        })
    }
}

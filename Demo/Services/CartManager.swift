//
//  CartManager.swift
//  Demo
//
//  Created by Rupali Ghate on 11.06.19.
//  Copyright © 2019 MobiLab. All rights reserved.
//

import CoreData
import UIKit

class CartManager {
    // MARK: Properties

    static let shared = CartManager()

    private(set) var cartItems: [Item] = []

    private let entityName = "ItemEntity"

    private var itemEntities: [ItemEntity] = []

    private let appDelegate = UIApplication.shared.delegate as! AppDelegate

    // MARK: Initializers

    private init() {}

    // MARK: Public methods

    /// An async method to load items from database into an array.
    func getAllCartItems(completion: @escaping (Result<[Item], Error>) -> Void) {
        let context = self.appDelegate.persistentContainer.viewContext

        DispatchQueue.global(qos: .background).async {
            let fetchRequest: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()

            var cartItems: [Item] = []

            do {
                let itemEntities = try context.fetch(fetchRequest)

                cartItems = itemEntities.map { entity -> Item in
                    let id = entity.id!
                    let description = entity.itemDescription ?? ""
                    let picture = entity.picture ?? ""
                    let price = entity.price ?? 0
                    let title = entity.title ?? ""
                    let quantity = Int(entity.quantity)

                    return Item(id: id, title: title, description: description, picture: picture, price: price, quantity: quantity)
                }
                self.cartItems = cartItems
                self.itemEntities = itemEntities
            } catch let err {
                completion(.failure(err))
                return
            }
            completion(.success(self.cartItems))
        }
    }

    /// Checks if item is already available in the cart. If not, adds new item in database and cartItems array.
    /// If item is available in the cart, this method increments quantity of that item by 1 in the cartItems and saves the updated quantity in database.
    /// - Parameters: item: reference to the item being added/updated
    /// - Returns: Error: nil in case of successful update, Error in case of failure.
    func addToCart(item: Item, completion: @escaping (Error?) -> Void) {
        let context = self.appDelegate.persistentContainer.viewContext

        DispatchQueue.global(qos: .background).async {
            // check if item already present in array. if so, get its index and increment quantity of item and item-entity
            if let index = self.searchItemInCart(for: item) {
                let itemEntity = self.itemEntities[index]
                self.incrementItemQuantity(context: context, itemEntity: itemEntity) { err in
                    if let err = err {
                        completion(err)
                        return
                    }
                    self.cartItems[index].quantity += 1
                    completion(nil)
                }
            } else {
                // if not already added, create item entity and add to db at first position. create item object and add to first position
                self.saveNewItem(context: context, item: item) { result in
                    switch result {
                    case let .failure(err):
                        completion(err)
                    case let .success(entity):
                        self.itemEntities.append(entity)

                        let newItem = Item(item: item, quantity: 1)
                        self.cartItems.append(newItem)

                        completion(nil)
                    }
                }
            }
        }
    }

    /// An async method to find provided item in cart and reducing it's quantity by 1. If item quantity after reduction becomes zero,
    /// remove the item from database and cartItems array. Else update itemEntity with newly reduced quantity into database.
    /// - Parameters: item: reference to the item being updated/removed
    /// - Returns: Error: nil in case of successful update, Error in case of failure.
    func decrementItemQuantity(item: Item, completion: @escaping (Error?) -> Void) {
        let context = self.appDelegate.persistentContainer.viewContext

        DispatchQueue.global(qos: .background).async {
            // get index of passed item from cartItems array by matching their item-ids.
            guard let index = self.searchItemInCart(for: item) else {
                completion(.init(CustomError(description: "Item not available")))
                return
            }

            let itemEntity = self.itemEntities[index]
            let quantity = itemEntity.quantity - 1

            if quantity == 0 {
                // if quantity reaches to zero, delete item from database
                self.deleteItem(context: context, itemEntity: itemEntity, completion: { err in
                    if let err = err {
                        completion(err)
                        return
                    }
                    self.itemEntities.remove(at: index)
                    self.cartItems.remove(at: index)
                })
            } else {
                // save updated quantity into database
                itemEntity.quantity = quantity
                self.appDelegate.saveContext { err in
                    if let err = err {
                        completion(err)
                        return
                    }
                    // update cart array if database updated successfully
                    self.cartItems[index].quantity -= 1
                }
            }
            completion(nil)
        }
    }

    // Remove all the saved items from database and clears the cartItems array to make cart empty.
    /// - Returns: Error: nil in case of successful delete, Error in case of failure.
    func emptyCart(completion: @escaping (Error?) -> Void) {
        let context = self.appDelegate.persistentContainer.viewContext
        do {
            for entity in self.itemEntities {
                context.delete(entity)
            }
            self.appDelegate.saveContext { err in
                if let err = err {
                    completion(err)
                } else {
                    self.cartItems.removeAll()
                    completion(nil)
                }
            }
        }
    }

    // MARK: Helpers

    /// Function to search given item in cartItems array
    /// - Parameters: item - an item to be searched in the array
    /// - Returns: index of matching item in the array, nil otherwise
    private func searchItemInCart(for item: Item) -> Int? {
        return self.cartItems.firstIndex(where: { $0.id == item.id }) ?? nil
    }

    /// Increments quantity of item in database
    /// - Parameters: itemEntity to be updated
    /// - Returns: Error: nil for successful update, Error in case of failure.
    private func incrementItemQuantity(context _: NSManagedObjectContext, itemEntity: ItemEntity, completion: @escaping (Error?) -> Void) {
        // Increment and save item quantity into database
        itemEntity.quantity = itemEntity.quantity + 1
        self.appDelegate.saveContext(completion: completion)
    }

    /// Create and save new item into database
    /// - Parameters: item - items to be saved in database
    /// - Returns: Result with ItemEntity for successful update, Error otherwise
    private func saveNewItem(context: NSManagedObjectContext, item: Item, completion: @escaping (Result<ItemEntity, Error>) -> Void) {
        let itemEntity = ItemEntity(context: context)

        itemEntity.id = item.id
        itemEntity.title = item.title
        itemEntity.itemDescription = item.description
        itemEntity.picture = item.picture
        itemEntity.price = item.price
        let quantity = itemEntity.quantity + 1
        itemEntity.quantity = Int16(quantity)

        self.appDelegate.saveContext { err in
            if let err = err {
                completion(.failure(err))
            } else {
                completion(.success(itemEntity))
            }
        }
    }

    /// Delete item from database
    /// - Parameters: itemEntity to be deleted
    /// - Returns: Error: nil for successful delete, Error in case of failure.
    private func deleteItem(context: NSManagedObjectContext, itemEntity: ItemEntity, completion: @escaping (Error?) -> Void) {
        context.delete(itemEntity)
        self.appDelegate.saveContext(completion: completion)
    }
}

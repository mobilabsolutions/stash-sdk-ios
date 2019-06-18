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
    private lazy var context = appDelegate.persistentContainer.viewContext

    // MARK: Initializers

    private init() {}

    // MARK: Public methods

    func getAllCartItems(completion: @escaping (Result<[Item], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let fetchRequest: NSFetchRequest<ItemEntity> = ItemEntity.fetchRequest()

            var cartItems: [Item] = []

            do {
                let itemEntities = try self.context.fetch(fetchRequest)

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

    func addToCart(item: Item, completion: @escaping (Result<[Item], Error>) -> Void) {
        DispatchQueue.global(qos: .background).async {
            // check if item already present in array. if so, get its index and increment quantity of item and item-entity
            if let index = self.getItemIndex(item: item) {
                let itemEntity = self.itemEntities[index]
                self.incrementItemQuantity(itemEntity: itemEntity) { err in
                    if let err = err {
                        completion(.failure(err))
                        return
                    }
                    self.cartItems[index].quantity += 1
                    completion(.success(self.cartItems))
                }
            } else {
                // if not already added, create item entity and add to db at first position. create item object and add to first position
                self.create(item: item) { result in
                    switch result {
                    case let .failure(err):
                        completion(.failure(err))
                    case let .success(entity):
                        self.itemEntities.append(entity)

                        let newItem = Item(item: item, quantity: 1)
                        self.cartItems.append(newItem)

                        completion(.success(self.cartItems))
                    }
                }
            }
        }
    }

    func decrementItemQuantity(item: Item, completion: @escaping (Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let index = self.getItemIndex(item: item) else {
                completion(.init(CustomError(description: "Item not available")))
                return
            }

            let itemEntity = self.itemEntities[index]
            let quantity = itemEntity.quantity - 1

            if quantity == 0 {
                // if quantity reaches to zero, delete item from database
                self.deleteItem(itemEntity: itemEntity, completion: { err in
                    if let err = err {
                        completion(err)
                        return
                    }
                    self.itemEntities.remove(at: index)
                    self.cartItems.remove(at: index)
                })
            } else {
                itemEntity.quantity = quantity
                self.appDelegate.saveContext { err in
                    if let err = err {
                        completion(err)
                        return
                    }
                    self.cartItems[index].quantity -= 1
                }
            }
            completion(nil)
        }
    }

    func emptyCart(completion: @escaping (Error?) -> Void) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)

        do {
            try self.context.execute(request)
            self.cartItems.removeAll()
            completion(nil)
        } catch let err {
            completion(err)
        }
    }

    // MARK: Helpers

    private func getItemIndex(item: Item) -> Int? {
        return self.cartItems.firstIndex(where: { $0.id == item.id }) ?? nil
    }

    private func incrementItemQuantity(itemEntity: ItemEntity, completion: @escaping (Error?) -> Void) {
        let quantity = itemEntity.quantity + 1
        itemEntity.quantity = quantity
        self.appDelegate.saveContext(completion: completion)
    }

    private func create(item: Item, completion: @escaping (Result<ItemEntity, Error>) -> Void) {
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

    private func deleteItem(itemEntity: ItemEntity, completion: @escaping (Error?) -> Void) {
        self.context.delete(itemEntity)
        self.appDelegate.saveContext(completion: completion)
    }
}

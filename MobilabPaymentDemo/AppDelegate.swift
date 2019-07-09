//
//  AppDelegate.swift
//  Demo
//
//  Created by Rupali Ghate on 09.05.19.
//  Copyright © 2019 MobiLab Solutions GmbH. All rights reserved.
//

import CoreData
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DemoModel")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data save

    func saveContext(completion: @escaping (Error?) -> Void) {
        let context = self.persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                completion(nil)
            } catch let err {
                completion(err)
            }
        }
    }
}

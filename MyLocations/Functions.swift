//
//  Functions.swift
//  MyLocations
//
//  Created by Anatoliy Chernyuk on 10/16/17.
//  Copyright © 2017 Anatoliy Chernyuk. All rights reserved.
//

import Foundation
import Dispatch

let MyManagedObjectContextSaveDidFailNotification = Notification.Name(rawValue: "MyManagedObjectContextSaveDidFailNotification")

func fatalCoreDataError(_ error: Error) {
    print("***Fatal error: \(error)")
    NotificationCenter.default.post(name: MyManagedObjectContextSaveDidFailNotification, object: nil)
}

func afterDelay(_ seconds: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}

let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths.first!
}()

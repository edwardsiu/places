//
//  PlaceStore.swift
//  Places
//
//  Created by Edward Siu on 4/25/18.
//  Copyright © 2018 asm. All rights reserved.
//

import Foundation
import os.log

class PlaceStore: NSObject, NSCoding {
    struct PropertyKey {
        static let name = "name"
        static let formatted_address = "formatted_address"
        static let icon = "icon"
        static let place_id = "place_id"
    }
    
    var name: String
    var formatted_address: String
    var icon: String
    var place_id: String
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("favoritePlaces")
    
    init(name: String, address: String, icon: String, id: String) {
        self.name = name
        self.formatted_address = address
        self.icon = icon
        self.place_id = id
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(formatted_address, forKey: PropertyKey.formatted_address)
        aCoder.encode(icon, forKey: PropertyKey.icon)
        aCoder.encode(place_id, forKey: PropertyKey.place_id)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a place object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let address = aDecoder.decodeObject(forKey: PropertyKey.formatted_address) as? String else {
            os_log("Unable to decode the address for a place object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let icon = aDecoder.decodeObject(forKey: PropertyKey.icon) as? String else {
            os_log("Unable to decode the icon for a place object.", log: OSLog.default, type: .debug)
            return nil
        }
        guard let place_id = aDecoder.decodeObject(forKey: PropertyKey.place_id) as? String else {
            os_log("Unable to decode the place id for a place object.", log: OSLog.default, type: .debug)
            return nil
        }
        print("Decoded place: \(name)")
        self.init(name: name, address: address, icon: icon, id: place_id)
    }
}

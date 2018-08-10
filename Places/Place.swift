//
//  Place.swift
//  Places
//
//  Created by Edward Siu on 4/23/18.
//  Copyright © 2018 asm. All rights reserved.
//

import Foundation

struct SearchResults: Decodable {
    let results: [Place]
    let token: String?
}

struct DetailResult: Decodable {
    let result: Place
}

struct Place: Decodable {
    let rating: Double?
    let name: String
    let geometry: Geometry?
    let place_id: String
    let formatted_address: String
    let icon: String
    let website: String?
    let price_level: Double?
    let photos: [Photo]?
    let reviews: [Review]?
    let international_phone_number: String?
    let url: String?
    let address_components: [AddressComponent]?
    init(name: String, address: String, icon: String, id: String) {
        self.name = name
        self.formatted_address = address
        self.icon = icon
        self.place_id = id
        self.rating = nil
        self.geometry = nil
        self.website = nil
        self.price_level = nil
        self.photos = nil
        self.reviews = nil
        self.international_phone_number = nil
        self.url = nil
        self.address_components = nil
    }
}

struct Geometry: Decodable {
    let location: Coordinate
}

struct Coordinate: Decodable {
    let lat: Double
    let lng: Double
}

struct AddressComponent: Decodable {
    let long_name: String
    let types: [String]
    let short_name: String
}

struct Photo: Decodable {
    let photo_reference: String
    let width: Int
    let height: Int
}

struct Review: Decodable {
    let rating: Double
    let author_name: String
    let text: String
    let time: Int
    let author_url: String
    let profile_photo_url: String
}

struct YelpReview: Decodable {
    let rating: Double
    let url: String
    let text: String
    let time_created: String
    let user: YelpUser
}

struct YelpUser: Decodable {
    let image_url: String
    let name: String
}

struct Directions: Decodable {
    let routes: [Route]
}

struct Route: Decodable {
    let overview_polyline: Polyline
}

struct Polyline: Decodable {
    let points: String
}

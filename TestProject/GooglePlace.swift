//
//  GooglePlace.swift
//  TestProject
//
//  Created by Leshya Bracaglia on 5/1/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import SwiftyJSON

class GooglePlace {
    
    let placeId : String
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    let placeType: String
    let priceLevel : Int?
    let rating : Double?
    let openNow: Bool
    var photoReference: String?
    var photo: UIImage?
    let formattedAddress: String
    
    init(dictionary: [String: Any], acceptedTypes: [String])
    {
        let json = JSON(dictionary)
        placeId = json["place_id"].stringValue
        name = json["name"].stringValue
        address = json["vicinity"].stringValue
        openNow = json["open_now"].boolValue
        if(openNow){
            NSLog("Yes")
        }
        NSLog("Open now %", openNow)
        formattedAddress = json["address_components"][2]["long_name"].stringValue;
        NSLog("formatted Address %@", formattedAddress)
        
        priceLevel = json["price_level"].int
        rating = json["rating"].double
        let lat = json["geometry"]["location"]["lat"].doubleValue as CLLocationDegrees
        let lng = json["geometry"]["location"]["lng"].doubleValue as CLLocationDegrees
        coordinate = CLLocationCoordinate2DMake(lat, lng)
        
        photoReference = json["photos"][0]["photo_reference"].string
        
        var foundType = "restaurant"
        let possibleTypes = acceptedTypes.count > 0 ? acceptedTypes : ["bakery", "bar", "cafe", "restaurant"]
        
        if let types = json["types"].arrayObject as? [String] {
            for type in types {
                if possibleTypes.contains(type) {
                    foundType = type
                    break
                }
            }
        }
        placeType = foundType
    }
}

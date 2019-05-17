//
//  PlaceMarker.swift
//  TestProject
//
//  Created by Leshya Bracaglia on 5/1/19.
//  Copyright © 2019 nyu.edu. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class PlaceMarker: GMSMarker {
    let place: GooglePlace
    
    //Sets the GooglePlace pin as an extension of GMSMarker
    init(place: GooglePlace) {
        self.place = place
        super.init()
        
        position = place.coordinate
        icon = UIImage(named: place.placeType+"_pin")
        //pick a new pin img
        groundAnchor = CGPoint(x: 0.5, y: 1)
        
        appearAnimation = .pop
    }
}

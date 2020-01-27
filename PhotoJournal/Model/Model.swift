//
//  Model.swift
//  PhotoJournal
//
//  Created by Melinda Diaz on 1/23/20.
//  Copyright © 2020 Melinda Diaz. All rights reserved.
//

import Foundation
//Yes its only an image and its not codable so we turn it to data by turning it to an OBJECT. OBJECTS are codable. It can have a date an ID so turn it to an object.  ANd also have an identifier. Use the view ID and turn it to a string and it is a unique string to your object.

struct ImageObject: Codable {
    
    let imageData: Data //We cannot take UIIMage and its not codable and convert it to data and when we retrieve that we can convert it back to data.
    let date: Date
    let identifier = UUID().uuidString//its a class that gives us access to creating a unique identifier. Every object contains its own ID. the ID gets create by itself we do not create it on our own
    let imageDescription: String
}

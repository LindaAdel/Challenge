//
//  ProductModel .swift
//  Challenge
//
//  Created by Linda adel on 1/27/22.
//

import Foundation
import UIKit

/// Struct to hold products data from API
/// conform to codable for encoding and decoding data
struct ProductModel : Codable {
    var id : Int?
    var productDescription : String?
    var image : ProductImage?
    var price : Int?
}

/// Struct to hold products Images data from API
/// conform to codable for encoding and decoding data
struct ProductImage : Codable {
    var width : Int?
    var height : Int?
    var url : String?
}



//
//  ProductModel .swift
//  Challenge
//
//  Created by Linda adel on 1/27/22.
//

import Foundation
import UIKit

struct ProductModel : Codable {
    var id : Int?
    var productDescription : String?
    var image : ProductImage?
    var price : Int?
}
struct ProductImage : Codable {
    var width : Int?
    var height : Int?
    var url : String?
}



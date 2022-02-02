//
//  ProductService.swift
//  Challenge
//
//  Created by Linda adel on 1/27/22.
//

import Foundation

/// Class for network data transfer tasks
class ProductService{
    
    /// A simple way to establish network data transfer task for API Data.
    /// - Parameters:
    ///   - fetcgingPage: Number of pages fetched from API
    ///   - completion: Completion return an array of products struct model when fetching finish or error if exist
    func fetchProductData(fetcgingPage : Int , completion : @escaping ([ProductModel]?, Error?)->()){
        if let productURL = URL(string: URLs.getProductURL){
            URLSession.shared.dataTask(with: productURL , completionHandler: { data, response, error in
                if let productData = data , error == nil {
                    // we have data
                    var dataResponse : [ProductModel]?
                    do {
                        dataResponse =  try JSONDecoder().decode([ProductModel].self, from: productData)
                    } catch let error {
                        print("error converting data \(error.localizedDescription)")
                    }
                    if let productResponse = dataResponse {
                        
                        completion(productResponse,nil)
                    }
                }else {
                    if let dataError = error{
                        print("error fetching data \(dataError.localizedDescription)")
                        completion(nil , error)
                    }
                }
            }).resume()
        }
    }
    /// Method to cancel the ongoing data task
    func cancelFetchRequest(){
        if let productURL = URL(string: URLs.getProductURL){
            URLSession.shared.dataTask(with: productURL , completionHandler: { data, response, error in }).cancel()
        }
    }
    
}

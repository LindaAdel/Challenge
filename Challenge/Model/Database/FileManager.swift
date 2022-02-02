//
//  FileManger.swift
//  Challenge
//
//  Created by Linda adel on 1/30/22.
//

import Foundation

/// Class for products data caching
class ProductFileManager {
    
    /// A shared instance of products file Manager class.
    static let shared = ProductFileManager()
    
    /// An array to hold product cached.
    var products : [ProductModel]?
    
    /// A codable struct for the array of products that will be cached.
    struct  CachedProductsData : Codable{
        let products : [ProductModel]
    }
    ///  A really simple way to get file path URL.
    /// - Returns: File path URL if created.
    func documentDirectoryPath() -> URL? {
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        print("path : \(String(describing: path.first))")
        return path.first
    }
    
    ///  A simple way to cache the product struct into file on disk.
    /// - Parameter productsArray: An array of product struct
    func cacheProducts(with productsArray : [ProductModel]) {
        do {
            let filePath = documentDirectoryPath()?.appendingPathComponent("cachedProducts")
            let cachedProductsData = CachedProductsData(products: productsArray)
            let data = try JSONEncoder().encode(cachedProductsData)
            if let productsFilePath = filePath {
                try data.write(to: productsFilePath , options: .atomicWrite)
                
            }
            
        }catch let error {
            print("error caching products\(error.localizedDescription)")
        }
        JSONEncoder().dataEncodingStrategy = .base64
        
    }
    ///  A simple way to read cached product.
    /// - Returns: An array of product that was cached on disk.
    func readCachedProducts() -> [ProductModel]? {
        do{
            if let filePath = documentDirectoryPath()?.appendingPathComponent("cachedProducts"){
                if let data = try? Data(contentsOf: filePath){
                    JSONDecoder().dataDecodingStrategy = .base64
                    let cachedProductsData = try JSONDecoder().decode(CachedProductsData.self, from: data)
                    self.products = cachedProductsData.products
                }
            }
        }catch let error {
            print("error reading cached products\(error.localizedDescription)")
        }
        return products
    }
}












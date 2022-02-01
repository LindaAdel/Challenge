//
//  FileManger.swift
//  Challenge
//
//  Created by Linda adel on 1/30/22.
//

import Foundation

class ProductFileManager {
    
    static let shared = ProductFileManager()
    var products : [ProductModel]?
    
    struct  CachedProductsData : Codable{
        let products : [ProductModel]
    }

    func documentDirectoryPath() -> URL? {
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        print("path : \(String(describing: path.first))")
        return path.first
    }
    
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












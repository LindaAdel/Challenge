//
//  ImageDownloader.swift
//  Challenge
//
//  Created by Linda adel on 1/27/22.
//

import Foundation
import UIKit


/// Class for dowloading image to correspanding url and cashing this images
final class ImageDownloader {
    
    /// Shared instance of class
    static let shared = ImageDownloader()
    
    /// NSCache varible to cache image for each url
    private var cachedImages = NSCache<NSString, UIImage>()
    /// Dictionary for saving URLSessionDataTask to it's  URL
    private var imagesDownloadTasks: [String: URLSessionDataTask]
    
    
    ///  Queue for downloading images
    let serialQueueForImages = DispatchQueue(label: "images.queue", attributes: .concurrent)
    ///  Queue for data tasks
    let serialQueueForDataTasks = DispatchQueue(label: "dataTasks.queue", attributes: .concurrent)
    
    // MARK: Private init
    private init() {
        imagesDownloadTasks = [:]
    }
    
    
    /// Method to dowload images from URL and returnig them .
    /// if images are cached return the cached images
    /// - Parameters:
    ///   - imageUrlString: The remote URL to download images from
    ///   - completionHandler: A completion handler which returns two parameters. First one is an image which may or may not be cached and second one is a bool to indicate whether we returned the cached version or not
    ///   - placeholderImage: placeholder image in case of dowloading failed
    func downloadImage(with imageUrlString: String? ,
                       completionHandler: @escaping (UIImage?, Bool) -> Void,
                       placeholderImage: UIImage?) {
        
        guard let imageUrlString = imageUrlString else {
            completionHandler(placeholderImage, true)
            return
        }
        
        if let image = getCachedImageFrom(urlString: imageUrlString) {
            completionHandler(image, true)
        } else {
            guard let url = URL(string: imageUrlString) else {
                completionHandler(placeholderImage, true)
                return
            }
            
            if let _ = getDataTaskFrom(urlString: imageUrlString) {
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                
                guard let data = data else {
                    return
                }
                if let _ = error {
                    DispatchQueue.main.async {
                        completionHandler(placeholderImage, true)
                    }
                    return
                }
                
                let image = UIImage(data: data)
                self.serialQueueForImages.sync(flags: .barrier) {
                    if let imageToCache = image {
                        self.cachedImages.setObject(imageToCache, forKey: imageUrlString as NSString)
                    }
                }
                
                _ = self.serialQueueForDataTasks.sync(flags: .barrier) {
                    self.imagesDownloadTasks.removeValue(forKey: imageUrlString)
                }
                
                DispatchQueue.main.async {
                    completionHandler(image, false)
                }
            }
            
            self.serialQueueForDataTasks.sync(flags: .barrier) {
                imagesDownloadTasks[imageUrlString] = task
            }
            
            task.resume()
        }
    }
    
    
    // MARK: Helper methods
    
    /// Method that return cached image of certain URL
    /// - Parameter urlString: image URL for needed image
    /// - Returns: cached image to URL
    private func getCachedImageFrom(urlString: String) -> UIImage? {
        
        serialQueueForImages.sync {
            return cachedImages.object(forKey: urlString as NSString)
            
        }
    }
    
    private func getDataTaskFrom(urlString: String) -> URLSessionTask? {
        serialQueueForDataTasks.sync {
            return imagesDownloadTasks[urlString]
        }
    }
}

//
//  ImageDownloader.swift
//  Challenge
//
//  Created by Linda adel on 1/27/22.
//

import Foundation
import UIKit


final class ImageDownloader {
  
    static let shared = ImageDownloader()

    private var cachedImages = NSCache<NSString, UIImage>()
    private var imagesDownloadTasks: [String: URLSessionDataTask]

   
    let serialQueueForImages = DispatchQueue(label: "images.queue", attributes: .concurrent)
    let serialQueueForDataTasks = DispatchQueue(label: "dataTasks.queue", attributes: .concurrent)

    // MARK: Private init
    private init() {
        imagesDownloadTasks = [:]
    }

   
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

    private func cancelPreviousTask(with urlString: String?) {
        if let urlString = urlString, let task = getDataTaskFrom(urlString: urlString) {
            task.cancel()
            
            _ = serialQueueForDataTasks.sync(flags: .barrier) {
                imagesDownloadTasks.removeValue(forKey: urlString)
            }
        }
    }

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

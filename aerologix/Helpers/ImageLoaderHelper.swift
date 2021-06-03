//
//  ImageLoaderHeper.swift
//  aerologix
//
//  Created by Karthi CK on 02/06/21.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

class ImageLoader: UIImageView {

    var imageURL: URL?
    let activityIndicator = UIActivityIndicatorView()
    var task: URLSessionDataTask?

    func loadImageWithUrl(_ urlString: String, _ mode: UIView.ContentMode = .scaleAspectFill) {
        image = nil
        contentMode = mode
        // retrieves image if already available in cache
        if let imageFromCache = imageCache.object(forKey: urlString as NSString) {
            self.image = imageFromCache
            return
        }
        
        let url = URL(string: urlString)
        imageURL = url
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .darkGray
        addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        activityIndicator.startAnimating()
        // image does not available in cache.. so retrieving it from url...
        if url != nil {
            task = URLSession.shared.dataTask(with: url!) {
                (data, response, error) in
                if error != nil {
                    DispatchQueue.main.async(execute: {
                        self.activityIndicator.stopAnimating()
                    })
                    return
                }
                DispatchQueue.main.async {
                    if let unwrappedData = data,
                       let imageToCache = UIImage(data: unwrappedData) {
                        imageCache.setObject(imageToCache, forKey: NSString(string: urlString))
                        if self.imageURL == url {
                            self.image = imageToCache
                        }
                    }
                    self.activityIndicator.stopAnimating()
                }
            }
            task?.resume()
        }
    }
}

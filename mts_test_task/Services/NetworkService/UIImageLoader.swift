//
//  UIImageLoader.swift
//  mts_test_task
//
//  Created by  Matvey on 10.04.2021.
//

import UIKit

class UIImageLoader {
    static let shared = UIImageLoader()
    
    private let imageLoader = ImageLoader()
    private var imageViewsUUID = [UIImageView: UUID]()
    
    private init() {}
    
    func load(url: String, for imageView: UIImageView, handler: @escaping() -> Void) {
        
        let identifire = imageLoader.loadImage(url: url) { [weak self] (result) in
            
            defer { self?.imageViewsUUID.removeValue(forKey: imageView) }
            
            guard let image = try? result.get() else {
                DispatchQueue.main.async {
                    handler()
                }
                return
            }
            
            DispatchQueue.main.async {
                handler()
                imageView.image = image
            }
        }
        
        if let identifire = identifire { imageViewsUUID[imageView] = identifire }
    }
    
    func cancel(for imageView: UIImageView) {
        if let uuid = imageViewsUUID[imageView] {
            self.imageLoader.cancelLoad(uuid: uuid)
            imageViewsUUID.removeValue(forKey: imageView)
        }
    }
}

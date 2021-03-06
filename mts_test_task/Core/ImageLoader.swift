//
//  ImageLoader.swift
//  mts_test_task
//
//  Created by  Matvey on 10.04.2021.
//

import UIKit


class ImageLoader {
    private var loadedImages = [URL: UIImage]()
    private var runningRequests = [UUID: URLSessionDataTask]()
    
    func loadImage(url: String, complition: @escaping(Result<UIImage, Error>) -> Void) -> UUID? {
        guard let url = NetworkManager.convertToURL(strURL: url) else {
            complition(.failure(NetworkError.errorURL))
            return nil }
        
        if let image = loadedImages[url] {
            complition(.success(image))
            return nil
        }
        
        let uuid = UUID()
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            defer {
                DispatchQueue.main.async {
                    self?.runningRequests.removeValue(forKey: uuid)
                }
            }
            
            if let data = data,
               let image = UIImage(data: data) {
                self?.loadedImages.updateValue(image, forKey: url)
                complition(.success(image))
                return
            }
            
            guard let error = error else { return }
            
            guard (error as NSError).code == NSURLErrorCancelled else {
                complition(.failure(error))
                return
            }
        }
        DispatchQueue.global(qos: .default).async {
            task.resume()
        }
        runningRequests.updateValue(task, forKey: uuid)
        return uuid
    }
    
    func cancelLoad(uuid: UUID) {
        runningRequests[uuid]?.cancel()
        runningRequests.removeValue(forKey: uuid)
    }
}

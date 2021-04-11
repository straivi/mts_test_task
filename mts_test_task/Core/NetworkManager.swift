//
//  NetworkManager.swift
//  mts_test_task
//
//  Created by  Matvey on 09.04.2021.
//

import Foundation

class NetworkManager {
    
    func dataTask(request: URLRequest, complition: @escaping(Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            complition(data, error)
        }
        DispatchQueue.global(qos: .default).async {
            task.resume()
        }
    }
    
    func decodeJSON<T: Decodable>(type: T.Type, from data: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = data else { return nil }
        do {
            let object = try decoder.decode(type.self, from: data)
            return object
        } catch {
            return nil
        }
    }
}

//
//  NetworkService.swift
//  mts_test_task
//
//  Created by  Matvey on 09.04.2021.
//

import UIKit

// Struct for parsing
fileprivate struct NasaAPICollection: Decodable {
    let collection: NasaItemsList
}

fileprivate struct NasaItemsList: Decodable {
    let items: [Item]
}

fileprivate struct Item: Decodable {
    let itemSizesLink: String
    let previewLinkItems: [PreviewLink]
    let data: [ItemData]
    
    enum CodingKeys: String, CodingKey {
        case itemSizesLink = "href"
        case previewLinkItems = "links"
        case data
    }
}

fileprivate struct PreviewLink: Decodable {
    let previewImageUrl: String
    let rel: String
    
    enum CodingKeys: String, CodingKey {
        case previewImageUrl = "href"
        case rel
    }
}

fileprivate struct ItemData: Decodable {
    let title: String
    let description: String?
    let nasaId: String
    let createdDate: String
    let mediaType: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case nasaId = "nasa_id"
        case createdDate = "date_created"
        case mediaType = "media_type"
    }
}

// Struct for table
struct NasaObject {
    let previewImageUrl: String
    let title: String
    let description: String
    let nasaId: String
    let createdDate: Date
    let contentType: ContentType
    let sizesLink: String
}

struct ContentLink {
    let photoLink: String
    let videoLink: String?
}

enum ContentType {
    case image
    case video
}

class NetworkService {
    
    let networkManager = NetworkManager()
    
    // MARK: Popolar object list
    func getPopolarList(complition: @escaping(Result<[NasaObject], Error>) -> Void) {
        let path = "https://images-assets.nasa.gov/popular.json"
        let url = URL(string: path)
        guard let urlUnwrap = url else {
            complition(.failure(NetworkError.errorURL))
            return
        }
        var request = URLRequest(url: urlUnwrap)
        request.timeoutInterval = 5
        networkManager.dataTask(request: request) { (data, error) in
            if let error = error {
                DispatchQueue.main.async {
                    complition(.failure(error))
                }
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    complition(.failure(NetworkError.noDataError))
                }
                return
            }
            let decodeData = self.networkManager.decodeJSON(type: NasaAPICollection.self, from: data)
            guard let responseUnwraped = decodeData else {
                DispatchQueue.main.async {
                    complition(.failure(NetworkError.decodeError))
                }
                return
            }
            let popularList = self.convertToResponseObject(from: responseUnwraped)
            DispatchQueue.main.async {
                complition(.success(popularList))
                return
            }
        }
    }
    
    // MARK: Original contetn size
    func getOriginalSizeContent(byURL path: String, complition: @escaping(Result<ContentLink, Error>) -> Void) {
        guard let url = URL(string: path) else {
            complition(.failure(NetworkError.errorURL))
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        networkManager.dataTask(request: request) { (data, error) in
            if let error = error {
                DispatchQueue.main.async {
                    complition(.failure(error))
                }
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    complition(.failure(NetworkError.noDataError))
                }
                return
            }
            let decodeData = self.networkManager.decodeJSON(type: [String].self, from: data)
            guard let responseUnwraped = decodeData else {
                DispatchQueue.main.async {
                    complition(.failure(NetworkError.decodeError))
                }
                return
            }
            let photoLink: String = {
                if let link = responseUnwraped.first(where: { (str) -> Bool in
                    str.contains("medium") && (str.contains(".jpg") || str.contains(".png"))
                }) {
                    return link
                } else if let link = responseUnwraped.first(where: { (str) -> Bool in
                    str.contains(".jpg") || str.contains(".png")
                }) {
                    return link
                } else {
                    return ""
                }
            }()
            
            let videoLink: String? = {
                if let link = responseUnwraped.first(where: {
                    $0.contains("medium") && $0.contains(".mp4")
                }) {
                    return link
                } else {
                    var link: String? = nil
                    link = responseUnwraped.first(where: {
                        $0.contains(".mp4")
                    })
                    return link
                }
            }()
            
            let contentLink = ContentLink(photoLink: photoLink, videoLink: videoLink)
            
            DispatchQueue.main.async {
                complition(.success(contentLink))
                return
            }
        }
    }
    
    // MARK: Search
    func getSearchResult(searchTerm: String, page: Int, complition: @escaping(Result<[NasaObject], Error>) -> Void) {
        
        let params = prepareParamsForSearch(term: searchTerm, page: page)
        guard let url = createURL(with: params) else {
            complition(.failure(NetworkError.errorURL))
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        networkManager.dataTask(request: request) { (data, error) in
            if let error = error {
                DispatchQueue.main.async {
                    complition(.failure(error))
                }
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    complition(.failure(NetworkError.noDataError))
                }
                return
            }
            let decodeData = self.networkManager.decodeJSON(type: NasaAPICollection.self, from: data)
            guard let responseUnwraped = decodeData else {
                DispatchQueue.main.async {
                    complition(.failure(NetworkError.decodeError))
                }
                return
            }
            let popularList = self.convertToResponseObject(from: responseUnwraped)
            DispatchQueue.main.async {
                complition(.success(popularList))
                return
            }
        }
    }
    
    private func createURL(with params: [String: String]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "images-api.nasa.gov"
        components.path = "/search"
        components.queryItems = params.map { URLQueryItem(name: $0, value: $1) }
        return components.url
    }
    
    private func prepareParamsForSearch(term: String, page: Int) -> [String: String] {
        var params = [String: String]()
        params["q"] = term
        params["page"] = String(page)
        params["media_type"] = "image,video"
        return params
    }
    
    private func convertToResponseObject(from collection: NasaAPICollection) -> [NasaObject] {
        var popularObjectList: [NasaObject] = []
        
        for item in collection.collection.items {
            let previewImageUrl = item.previewLinkItems.first?.previewImageUrl ?? ""
            let title = item.data.first?.title ?? ""
            let description: String = {
                let str = item.data.first?.description ?? ""
                let strList = str.components(separatedBy: " ")
                let cleanedStrList = strList.map { (component) -> String in
                    component.hasPrefix("http") ? "" : component
                }
                return cleanedStrList.joined(separator: " ")
            }()
            let nasaId = item.data.first?.nasaId ?? ""
            let contentType: ContentType = {
                let mediaType = item.data.first?.mediaType
                return mediaType == "image" ? ContentType.image : ContentType.video
            }()
            let dateFormater = DateFormatter()
            dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let createdDate = dateFormater.date(from: item.data.first?.createdDate ?? "") ?? Date.init(timeIntervalSince1970: 0)
            
            popularObjectList.append(NasaObject(previewImageUrl: previewImageUrl,
                                                title: title,
                                                description: description,
                                                nasaId: nasaId,
                                                createdDate: createdDate,
                                                contentType: contentType,
                                                sizesLink: item.itemSizesLink
            ))
        }
        return popularObjectList
    }
    
}

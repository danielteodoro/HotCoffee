//
//  WebService.swift
//  HotCoffee
//
//  Created by Daniel Teodoro on 18/10/20.
//

import Foundation

enum NetworkError: Error {
    case decodingError
    case domainError
    case urlError
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

struct Resource<T: Codable> {
    let url: URL
    var httpMethod: HTTPMethod = .get
    var body: Data? = nil
}

extension Resource {
    init(url: URL) {
        self.url = url
    }
}

class WebService {
    func load<T>(resource: Resource<T>, completion: @escaping (Result<T, NetworkError>) -> Void) {
        
        var resquest = URLRequest(url: resource.url)
        resquest.httpMethod = resource.httpMethod.rawValue
        resquest.httpBody = resource.body
        resquest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: resquest) { data, response, error in
            
            guard let data = data, error == nil else {
                completion(.failure(.domainError))
                return
            }
            let result = try? JSONDecoder().decode(T.self, from: data)
            if let result = result {
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } else {
                completion(.failure(.decodingError))
            }
        }.resume()
    }
}

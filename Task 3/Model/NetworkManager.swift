//
//  NetworkManager.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import Foundation
import Moya


struct NetworkManager {
    
    static var shared = NetworkManager()
    private init(){}
    
    // Cache saves image as UIImage and image's link as NSString.
    let cache = NSCache<NSString, UIImage>()
}

// enum for Moya Network Call. Popular movies or Upcoming ones.
enum MovieType {
    case popular
    case upcoming
}

extension MovieType: TargetType {
    var baseURL: URL {
        URL(string: "https://api.themoviedb.org/3/movie")!
    }
    var path: String {
        switch self {
        case .popular:
            return "/popular"
        case .upcoming:
            return "/upcoming"
        }
    }
    
    // Specifies which method is used in the network call. In this case all are get methods, none are post.
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        
        // Parameters needed for the network call. Language and the apiKey.
        switch self {
        case .upcoming, .popular: return .requestParameters(parameters: ["language": "en-US", "api_key":"c8984794b536d067f2587fa6f3d84c39"], encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
    
    
}

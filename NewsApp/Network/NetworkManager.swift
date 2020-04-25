//
//  NetworkManager.swift
//  NewsApp
//
//  Created by Macbook Pro 15 on 4/24/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import Foundation

class NetworkManager {
    
    let urlSession = URLSession.shared // shared singleton session object used to run tasks. Will be useful later
    var baseURL = "https://newsapi.org/v2/"
    var token = PrivateKeys.newsApiKey.rawValue
    
    func getArticles(_ completion: @escaping (Result<[Article]>) -> Void) {
        let articlesRequest = makeRequest(for: .articles)
        let task = urlSession.dataTask(with: articlesRequest) { data, response, error in
            // Check for errors.
            if let error = error {
                return completion(Result.failure(error))
            }
            
            // Check to see if there is any data that was retrieved.
            guard let data = data else {
                return completion(Result.failure(EndPointError.noData))
            }
            
            // Attempt to decode the data.
            guard let result = try? JSONDecoder().decode(ArticleList.self, from: data) else {
                return completion(Result.failure(EndPointError.couldNotParse))
            }
            
            let articles = result.articles
            
            // Return the result with the completion handler.
            DispatchQueue.main.async {
                completion(Result.success(articles))
            }
        }
        task.resume()
    }
    
//    func getComments(_ articleId: Int, completion: @escaping (Result<[Comment]>) -> Void) {
//        let commentsRequest = makeRequest(for: .comments(articleId: articleId))
//        let task = urlSession.dataTask(with: commentsRequest) { data, response, error in
//            // Check for errors
//            if let error = error {
//                return completion(Result.failure(error))
//            }
//
//            // Check to see if there is any data that was retrieved.
//            guard let data = data else {
//                return completion(Result.failure(EndPointError.noData))
//            }
//
//            // Attempt to decode the comment data.
//            guard let result = try? JSONDecoder().decode(CommentApiResponse.self, from: data) else {
//                return completion(Result.failure(EndPointError.couldNotParse))
//            }
//
//            // Return the result with the completion handler.
//            DispatchQueue.main.async {
//                completion(Result.success(result.comments))
//            }
//        }
//        task.resume()
//    }
    
    // All the code we did before but cleaned up into their own methods
    private func makeRequest(for endPoint: EndPoints) -> URLRequest {
        // grab the parameters from the endpoint and convert them into a string
        let stringParams = endPoint.paramsToString()
        print("String Params=\(stringParams)")
        // get the path of the endpoint
        let path = endPoint.getPath()
        // create the full url from the above variables
        let fullURL = URL(string: baseURL.appending("\(path)?\(stringParams)"))!
        // build the request
        var request = URLRequest(url: fullURL)
        request.httpMethod = endPoint.getHTTPMethod()
        request.allHTTPHeaderFields = endPoint.getHeaders(token: token)
        return request
    }
    
    enum EndPoints {
        case articles
        case comments(articleId: Int)
        
        // determine which path to provide for the API request
        func getPath() -> String {
            switch self {
            case .articles:
                return "everything"
            case .comments:
                return "comments"
            }
        }
        
        // We're only ever calling GET for now, but this could be built out if that were to change
        func getHTTPMethod() -> String {
            return "GET"
        }
        
        // Same headers we used for Postman
        func getHeaders(token: String) -> [String: String] {
            return [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)",
//                "Host": "api.producthunt.com"
            ]
        }
        
        // grab the parameters for the appropriate object (article or comment)
        func getParams() -> [String: String] {
            switch self {
            case .articles:
                return [ //find more info at https://newsapi.org/docs/endpoints/everything
                    "sortBy": "popularity", //values can only be relevancy, popularity, publishedAt
//                    "q": "", //Keywords or phrases to search for in the article title and body.
//                    "qInTitle": "" //Keywords or phrases to search for in the article title only.
//                    "sources": "" //A comma-seperated string of identifiers (maximum 20) for the news sources or blogs you want headlines from. Use the /sources endpoint to locate these programmatically
//                    "domains": "", //A comma-seperated string of domains (eg bbc.co.uk, techcrunch.com, engadget.com) to restrict the search to.
//                    "excludeDomains": "" //A comma-seperated string of domains (eg bbc.co.uk, techcrunch.com, engadget.com) to remove from the results.
//                    "from": "" //A date and optional time for the oldest article allowed. This should be in ISO 8601 format (e.g. 2020-04-25 or 2020-04-25T02:36:43) Default: the oldest according to your plan.
//                    "to": "" //A date and optional time for the newest article allowed. This should be in ISO 8601 format (e.g. 2020-04-25 or 2020-04-25T02:36:43) Default: the newest according to your plan.
//                    "language": "", //The 2-letter ISO-639-1 code of the language you want to get headlines
                    "pageSize": "20", //(Int) 20 default and 100 is max
//                    "page": 20, //(Int) Use this to page through the results.
                ]
                
            case let .comments(articleId):
                return [
                    "sort_by": "votes",
                    "order": "asc",
                    "per_page": "20",
                    "search[article_id]": "\(articleId)"
                ]
            }
        }
        
        ///create string from array of parameters joining each element with & and put "=" between key and value
        func paramsToString() -> String {
            let parameterArray = getParams().map { key, value in
                return "\(key)=\(value)"
            }
            return parameterArray.joined(separator: "&")
        }
    }
    
    enum Result<T> {
        case success(T)
        case failure(Error)
    }
    
    enum EndPointError: Error {
        case couldNotParse
        case noData
    }
}

//
//  URLSessionClient.swift
//  LPERR
//
//  Created by Nitesh mishra on 14/02/24.
//

import Foundation

//extension URLSession: HTTPClient {
//    
//    //Invalid response error struct conforms to protocol
//    private struct UnexpectedValueRepresentation: Error {}
//
//    public func get(_ fromURL: URL, completion: @escaping (HTTPClientResult) -> Void) {
//        
//        /*------------------------------------------------------------
//         // let fromURL = URL(string: "https://wrong-url")!
//         //let fromURL = URL(string: "https://www.google.co.in/")!
//         // let fromURL = URL(string: "https://a-test-url")!
//         Uncomment above URLs to test failing cases one by one
//        ------------------------------------------------------------*/
//        
//        dataTask(with: fromURL) { data, response, error in
//            if let error = error {
//                completion(.failure(error))
//            } else if let data = data, let response = response as? HTTPURLResponse {
//                completion(.success(data, response))
//            } else {
//                completion(.failure(UnexpectedValueRepresentation()))
//            }
//            
//        }.resume()
//    }
//    
//}

public class URLSssionClient: HTTPClient {
    
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    //Invalid response error struct conforms to protocol
    private struct UnexpectedValueRepresentation: Error {}

    public func get(_ fromURL: URL, completion: @escaping (HTTPClientResult) -> Void) {
        
        /*------------------------------------------------------------
         // let fromURL = URL(string: "https://wrong-url")!
         //let fromURL = URL(string: "https://www.google.co.in/")!
         // let fromURL = URL(string: "https://a-test-url")!
         Uncomment above URLs to test failing cases one by one
        ------------------------------------------------------------*/
        
        session.dataTask(with: fromURL) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValueRepresentation()))
            }
            
        }.resume()
    }
    
}

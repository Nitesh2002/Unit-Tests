//
//  HttpClient.swift
//  LPERR
//
//  Created by Nitesh mishra on 08/02/24.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

public protocol HTTPClient {
    func get(_ fromURL: URL, completion:@escaping (HTTPClientResult) -> Void)
}

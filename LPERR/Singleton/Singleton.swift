////
////  Singleton.swift
////  LPERR
////
////  Created by Nitesh mishra on 31/01/24.
////
//
//import Foundation
//
//struct LoggedUser {
//    let name: String
//}
//
//class APIClient {
//    
//    static let instance = APIClient()
//    var name: String?
//    
//    init () {
//        print("Init")
//    }
//    
//    func loggin(completion:(LoggedUser) -> Void) {
//        completion(LoggedUser(name: "Real Name"))
//    }
//}
//
//
//
////extension APIClient {
////    func logUser(_ request: URLRequest, completion: (Data) -> Void) {
////        execute(request: request) { data in
////            completion(data)
////        }
////    }
////}
////
////extension APIClient {
////    func loadFeeds(_ request: URLRequest, completion: (Data) -> Void) {
////        execute(request: request) { data in
////            completion(data)
////        }
////    }
////}
//
////class LoginClient: APIClient {
////    func logUser(_ request: URLRequest, completion: (Data) -> Void) {
////        execute(request: request) { data in
////            completion(data)
////        }
////    }
////}
////
////class FeedClient: APIClient {
////    func loadFeeds(_ request: URLRequest, completion: (Data) -> Void) {
////        execute(request: request) { data in
////            completion(data)
////        }
////    }
////}
//
////class ViewController: UIViewController {
////
////    var api: APIClient = APIClient.instance
////
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        perfornLogin()
////    }
////
////    private func perfornLogin() {
////
////        api.loggin {  user in
////            print(user.name)
////        }
////    }
////}
//
//
////class ViewController: UIViewController {
////    
////    var loggedUser: (((LoggedUser)->Void)->Void)?
////    
////    override func viewDidLoad() {
////        super.viewDidLoad()
////        perfornLogin()
////    }
////    
////    private func perfornLogin() {
////        loggedUser? { user in
////            print(user.name)
////        }
////    }
////}
//
////class MockAPIClient: APIClient {
////
////    static let mockInstance = MockAPIClient()
////
////    override func loggin(completion: (LoggedUser) -> Void) {
////        completion(LoggedUser(name: "Test Name"))
////    }
////}
////
//////    func test_Singlton_VC() {
//////        let vc = ViewController()
//////        vc.api = MockAPIClient.mockInstance
//////        vc.api.loggin { user in
//////            print(user.name)
//////            XCTAssertEqual(user.name, "Test name", "Name falied to matched")
//////        }
//////    }
//    
////func test_Singlton_VC() {
////    let vc = ViewController()
////    vc.loggedUser = MockAPIClient.mockInstance.loggin
////}

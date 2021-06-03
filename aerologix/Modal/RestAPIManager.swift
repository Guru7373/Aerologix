//
//  RestAPIManager.swift
//  aerologix
//
//  Created by Karthi CK on 02/06/21.
//

import UIKit

class RestAPIManager: NSObject {

    static let sharedInstance = RestAPIManager()

    let devURL = URL(string: "https://bbf2a516-7989-4779-a5bf-ecb2777960c4.mock.pstmn.io/v1/dev/t2/employee/getAllDetails")
    
//    let reviewURL = URL(string: "https://bbf2a516-7989-4779-a5bf-ecb2777960c4.mock.pstmn.io/v1/prod/t2/employee/getAllDetails")
    
    let timeOut = TimeInterval(60)
    
    func getAllProfile(completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        var request = URLRequest(url: devURL!, timeoutInterval: timeOut)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            completionHandler(data, response, error)
        }.resume()
    }
}

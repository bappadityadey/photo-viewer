//
//  NTSAPIClient.swift
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

import Foundation

typealias ResponseHandler = ((NTSNetworkResponse) -> Void)
typealias PhotoDownloadHandler = ((String?, Error?) -> Void)

class NTSAPIClient {
    //MARK: Photo List API
    static func sendPhotoListRequest(_ completionCallback: @escaping (ResponseHandler)) {
        guard let url = URL(string: APIRequests.photoListUrl) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do {
                //here dataResponse received from a network request
                let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                let response = NTSNetworkResponse(request: url, urlResponse: response, data: jsonResponse, error: error)
                completionCallback(response)
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
}

//MARK: Download actual photo API
extension NTSAPIClient {
    static func sendDownloadFileAsync(url: URL, completion: @escaping (PhotoDownloadHandler)) {
        if let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let destinationUrl = documentsUrl.appendingPathComponent("\(url.lastPathComponent).jpg")
            if FileManager().fileExists(atPath: destinationUrl.path) {
                completion(destinationUrl.path, nil)
            } else {
                let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                let task = session.dataTask(with: request, completionHandler: { data, response, error in
                    if error == nil {
                        if let response = response as? HTTPURLResponse {
                            if response.statusCode == StatusCode.success {
                                if let data = data {
                                    if let _ = try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic) {
                                        completion(destinationUrl.path, error)
                                    } else {
                                        completion(destinationUrl.path, error)
                                    }
                                } else {
                                    completion(destinationUrl.path, error)
                                }
                            }
                        }
                    } else {
                        completion(destinationUrl.path, error)
                    }
                })
                task.resume()
            }
        }
    }
}

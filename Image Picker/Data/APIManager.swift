//
//  APIManager.swift
//  Image Picker
//
//  Created by BCL Device-18 on 19/5/24.
//

import Foundation
import Alamofire


class APIManager {
    
    static let shared = APIManager()
    
    var request: Request?
    
    private var requestQueue = DispatchQueue(label: "apiQueue")
    
    private var ongoingRequests = [Request]()

    func uploadImage(imageData: Data, leftPercentage: CGFloat, rightPercentage: CGFloat, topPercentage: CGFloat, bottomPercentage: CGFloat, keepOriginalSize: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let url = "http://103.95.97.11:8080/outpaint"
        let bearerToken = "c8aca83933b1773122ba65ed6429f6f13c61yu8aacecdfff0bfa9bb714f01de6"
        
//        let leftPercentage = "0.2"
//        let rightPercentage = "0.2"
//        let topPercentage = "0.2"
//        let bottomPercentage = "0.2"
//        let keepOriginalSize = "False"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(bearerToken)",
            "Content-Type": "multipart/form-data"
        ]
        
        let parameters: [String: String] = [
            "left_percentage":  String(describing: leftPercentage),
            "right_percentage": String(describing: rightPercentage),
            "top_percentage": String(describing: topPercentage),
            "bottom_percentage": String(describing: bottomPercentage),
            "keep_original_size": keepOriginalSize
        ]
        
        request = AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(imageData, withName: "file", fileName: "image.jpg", mimeType: "image/jpeg")
            
            for (key, value) in parameters {
                multipartFormData.append(Data(value.utf8), withName: key)
            }
            
        }, to: url, method: .post, headers: headers)
        .validate()
        .responseData { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        ongoingRequests.append(request!)
    }

    
    func cancelOngoingRequests() {
        for request in ongoingRequests {
            request.cancel()
        }
        ongoingRequests.removeAll()
        print("all ongoingRequests request cancel")
    }
    
}

//
//  CloudVisionAPI.swift
//  Boundri IOS
//
//  Created by Tanner York on 6/24/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation

import UIKit


func requestOcr(image: UIImage, completion: @escaping (Error?, String) -> Void) {
    let filename = "visionImage.png"
    
    // generate boundary string using a unique per-app string
    let boundary = UUID().uuidString
    
    let fieldName = "reqtype"
    let fieldValue = "fileupload"

    // Prepar URL Session
    let config = URLSessionConfiguration.default
    let session = URLSession(configuration: config)
    
    // Prepare Request Object
    var request = URLRequest(url: URL(string: "http://localhost:3000/api/ocr")!)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    var data = Data()
    // Add the reqtype field and its value to the raw http request data
    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    data.append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n".data(using: .utf8)!)
    data.append("\(fieldValue)".data(using: .utf8)!)

    // Add the image data to the raw http request data
    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
    data.append("Content-Disposition: form-data; name=\"fileToUpload\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
    data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
    data.append(image.pngData()!)
    
    // End the raw http request data, note that there is 2 extra dash ("-") at the end, this is to indicate the end of the data
    // According to the HTTP 1.1 specification https://tools.ietf.org/html/rfc7230
    data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

    // Send a POST request to the URL, with the data we created earlier
    session.uploadTask(with: request, from: data, completionHandler: { responseData, response, error in
        
        if(error != nil){
            completion(error!, "\(error!.localizedDescription)")
        }
        
        guard let responseData = responseData else {
            completion(nil, "Error, No responce data")
            return
        }
        
        if let responseString = String(data: responseData, encoding: .utf8) {
            completion(nil, responseString)
        }
    }).resume()
}

//requestOcr(imgAddress: UIImage()) { error, text in
//    guard error == nil else {
//        print(error)
//        return
//    }
//    print(text)
//}


//
//  CloudVisionAPI.swift
//  Boundri IOS
//
//  Created by Tanner York on 6/24/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation

import UIKit

func requestOcr(imgAddress: String) -> String {
    // Prepare URL
    let url = URL(string: "http://localhost:3000/api/ocr")
    guard let requestUrl = url else { fatalError() }
    // Prepare URL Request Object
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
     
    // HTTP Request Parameters which will be sent in HTTP Request Body
    let postString = "image=" + imgAddress;
    // Set HTTP Request Body
    request.httpBody = postString.data(using: String.Encoding.utf8);
    // Perform HTTP Request
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
     
            // Convert HTTP Response Data to a String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("Response data string:\n \(dataString)")
                
            }
            
    }
    task.resume()
    return apiResponse
}

let response = requestOcr(imgAddress: "https://jeroen.github.io/images/testocr.png");

print(response)


//
//  CloudVisionAPI.swift
//  Boundri IOS
//
//  Created by Tanner York on 6/24/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation

func ocrScript(json: String) {
    print(json)
    struct Responses: Codable {
        var responses: [Annotations]
    }
    struct Annotations: Codable {
        var textAnnotations: [Text]
    }
    struct Text: Codable {
        var description:String
    }
    let jsonData = json.data(using: .utf8)!
    let text = try! JSONDecoder().decode(Responses.self, from: jsonData)
    print(text)
}

func imageEvaluate(evaluation: String, image: String) {
    // PREPARE URL
    let url = URL(string: "https://vision.googleapis.com/v1/images:annotate?key=AIzaSyCfFj3M9gB89AyiwOh7evIb_xbtj6pc5_A")
    guard let requestUrl = url else { fatalError() }
    
    // PREPARE URL REQUEST OBJECT
    var request = URLRequest(url: requestUrl)
    request.httpMethod = "POST"
    request.allHTTPHeaderFields = [
        "Content-Type": "application/json",
        "Accept": "application/json"
    ]
    
    // PREPARE REQUEST BODY
    let jsonRequest = [
      "requests":[
        [
          "image":[
            "source":[
              "imageUri":
                image
            ]
          ],
          "features":[
            [
              "type":evaluation,
              "maxResults":1
            ]
          ]
        ]
      ]
    ] as [String : Any]
    let encodedRequest = try! JSONSerialization.data(withJSONObject: jsonRequest, options: .prettyPrinted)
    request.httpBody = encodedRequest;

    
    // EXECUTE REQUEST
    let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // CHECK FOR ERRORS
            if let error = error {
                print("Error took place \(error)")
                return
            }
     
            // CONVERT HTTP REQUEST INTO STRING
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
//                print("Response data string:\n \(dataString)")
                ocrScript(json: dataString)
            }
    }
    task.resume()
}

imageEvaluate(evaluation: "TEXT_DETECTION",image:"https://www.yeschinesefood.com/images/menu1.jpg")




 

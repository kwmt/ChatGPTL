//
//  ChatGPTAPI.swift
//  ChatGPTL
//
//  Created by Yasutaka Kawamoto on 2023/04/11.
//

import Foundation

private let endpointUrl = URL(string: "https://api.openai.com/v1/chat/completions")!

class ChatGPTAPI {
    lazy var chatGPTAPIKey: String = {
        
        guard let infoDictionary: [String: Any] = Bundle.main.infoDictionary else { return "" }
        guard let mySecretApiKey: String = infoDictionary["CHATGPT_API_KEY"] as? String else { return  ""}
//        chatGPTAPIKey = mySecretApiKey
        return mySecretApiKey
    }()
    
   
  
    
    // ChatGPT APIのエンドポイントURL
    
    func request(text: String, completion: @escaping (Result<ChatCompletion, Error>) -> Void) {
        
        
        
        // ChatGPT APIに送信するデータ
        let requestData: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "system", "content": "You are a translator from English to Japanease."],
                ["role": "user", "content": text]
            ]
        ]
        
        // ChatGPT APIへのHTTPリクエストを作成する
        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "POST"
        request.addValue("Bearer \(String(describing: chatGPTAPIKey))", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestData, options: [])
        } catch {
            print("Failed to serialize request data: \(error)")
            return
        }
        
        // HTTPリクエストを送信する
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // レスポンスを処理する
            if let error = error {
                print("Failed to complete request: \(error)")
                completion(.failure(NSError(domain: "Failed to complete request: \(error)", code: -1, userInfo: nil)))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: -1, userInfo: nil)))
                return
            }
            
            guard let jsonString = String(data: data, encoding: .utf8) else {
                print("Failed to convert response data to string.")
                return
            }
            do {
                let jsonData = jsonString.data(using: .utf8)!
                // パース後のデータを使って何か処理をする
                let chatCompletion = try JSONDecoder().decode(ChatCompletion.self, from: jsonData)
                completion(.success(chatCompletion))
                
            } catch {
                print("Failed to parse JSON data: \(error)")
                completion(.failure(NSError(domain: "Failed to parse JSON data: \(error)", code: -2, userInfo: nil)))
            }
        }
        task.resume()
    }
    
}


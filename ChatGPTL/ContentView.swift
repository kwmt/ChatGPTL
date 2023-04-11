//
//  ContentView.swift
//  ChatGPTL
//
//  Created by Yasutaka Kawamoto on 2023/04/10.
//

import SwiftUI

struct ContentView: View {
    @State var responseText: String = ""
    var body: some View {
        VStack {
            Text(responseText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .onAppear {
            let window = NSApplication.shared.windows.first
            window?.setContentSize(NSSize(width: 600, height: 600))
            window?.center()
            NotificationCenter.default.addObserver(forName: .didReceiveResponse, object: nil, queue: nil) { notification in
                if let result = notification.userInfo?["result"] as? Result<ChatCompletion, Error> {
                    switch result {
                    case .success(let response):
                        // 成功した場合は変数に格納
                        responseText = response.choices.first?.message.content ?? ""
                    case .failure(let error):
                        // 失敗した場合はエラーを表示
                        print("API request failed: \(error.localizedDescription)")
                    }
                    
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

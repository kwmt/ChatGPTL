import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var timer: Timer!
    let pasteboard: NSPasteboard = .general
    var lastChangeCount: Int = 0
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (t) in
            let changeCount = self.pasteboard.changeCount
            if self.lastChangeCount != changeCount && changeCount - self.lastChangeCount >= 2 {
                self.lastChangeCount = self.pasteboard.changeCount
                NotificationCenter.default.post(name: .NSPasteboardDidChange, object: self.pasteboard)
            }
        }
        
        let pasteboard = NSPasteboard.general
        pasteboard.declareTypes([.string], owner: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pasteboardDidChange), name: .NSPasteboardDidChange, object: pasteboard)
        
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        timer.invalidate()
    }
    
    @objc func pasteboardDidChange(_ notification: Notification) {
        if let pasteboard = notification.object as? NSPasteboard, let copiedString = pasteboard.string(forType: .string) {
            print("Copied string: \(copiedString)")
            let chatGPTAPI = ChatGPTAPI()
            chatGPTAPI.request(text: copiedString) { result in
                NotificationCenter.default.post(name: .didReceiveResponse, object: nil, userInfo: ["result": result])

            }
            // ここで必要な処理を行う
        }
    }
}
extension NSNotification.Name {
    public static let NSPasteboardDidChange: NSNotification.Name = .init(rawValue: "pasteboardDidChangeNotification")
    public static let didReceiveResponse = Notification.Name("didReceiveResponse")
}


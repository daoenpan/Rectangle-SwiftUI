//
//  PasteboardWatcher.swift
//  Rectangle
//
//  Created by Daoen Pan on 21.03.25.
//  Copyright © 2025 Daoen Pan. All rights reserved.
//

import Foundation

class PasteboardWatcher {
    
    private let pattern = "“(.+)”\n\nExcerpt From(.+)This material may be protected by copyright."
    private var timer: Timer?
    
    func stopMonitorBook() {
        timer?.invalidate()
    }
    
    func startMonitorBook() {
        watch { string in
            if let newString = try! self.matchBooksnExcerpt(string: string) {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(newString, forType: .string)
            }
        }
    }
    
    private func matchBooksnExcerpt(string: String) throws -> String? {
        let regex = try NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        
        let matches = regex.matches(in: string, range: NSRange(location: 0, length: string.count))
        
        if let match = matches.first {
            let range = match.range(at: 1)
            if let swiftRange = Range(range, in: string) {
                return String(string[swiftRange])
            }
        }
        
        return nil
    }
    
    func watch(using block: @escaping (String) -> Void) {
        var changeCount = NSPasteboard.general.changeCount
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            let pasteboard = NSPasteboard.general
            let newCount = pasteboard.changeCount
            
            guard newCount != changeCount else { return }
            
            defer {
                changeCount = newCount
            }
            
            guard let string = pasteboard.string(forType: .string) else { return }
            
            block(string)
        }
    }
}

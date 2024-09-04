//
//  AboutWindowDelegate.swift
//  Cerulean
//
//  Created by WhitetailAni on 7/26/24.
//

import AppKit

class CRWindowDelegate: NSObject, NSWindowDelegate {
    var window: NSWindow!
    
    init(window: NSWindow) {
        self.window = window
    }
    
    func windowDidResignKey(_ notification: Notification) {
        window.close()
    }
}

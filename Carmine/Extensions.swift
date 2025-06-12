//
//  Extensions.swift
//  Carmine
//
//  Created by WhitetailAni on 7/26/24.
//

import AppKit
import CoreLocation
import Foundation

extension NSMenuItem {
    convenience init(title: String, action: Selector?) {
        self.init(title: title, action: action, keyEquivalent: "")
    }
    
    @MainActor class func progressWheel() -> NSMenuItem {
        let rect = NSRect(x: 0, y: 0, width: 16, height: 16)
        let view = NSView(frame: rect)
        let progressIndicator = NSProgressIndicator(frame: rect)
        progressIndicator.frame.origin.x = 7
        progressIndicator.style = .spinning
        progressIndicator.isIndeterminate = true
        progressIndicator.controlSize = .small
        view.addSubview(progressIndicator)
        
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        let progressMenuItem = NSMenuItem()
        progressMenuItem.view = view
        
        progressIndicator.startAnimation(nil)
        return progressMenuItem
    }
}

extension NSColor {
    convenience init(r: Int, g: Int, b: Int, a: CGFloat = 1.0) {
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a)
    }
}

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = self.copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceAtop)

        image.unlockFocus()

        return image
    }
}

extension CLLocationCoordinate2D {
    init(_ latitude: Double, _ longitude: Double) {
        self.init(latitude: latitude, longitude: longitude)
    }
}

extension Array {
    func chunked(by chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

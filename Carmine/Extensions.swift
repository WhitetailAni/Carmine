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

@propertyWrapper
struct NSColorCodable {
    var wrappedValue: NSColor
}

extension NSColorCodable: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let data = try container.decode(Data.self)
        guard let color = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid color"
            )
        }
        wrappedValue = color
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try NSKeyedArchiver.archivedData(withRootObject: wrappedValue, requiringSecureCoding: true)
        try container.encode(data)
    }
} //https://stackoverflow.com/a/50934846

extension Array {
    func reorder<T: Equatable>(by preferredOrder: [T], using keyPath: KeyPath<Element, T>) -> [Element] {
        return self.sorted { (a, b) -> Bool in
            guard let first = preferredOrder.firstIndex(of: a[keyPath: keyPath]) else {
                return false
            }
            guard let second = preferredOrder.firstIndex(of: b[keyPath: keyPath]) else {
                return true
            }
            
            return first < second
        }
    }
} //https://stackoverflow.com/a/51683055

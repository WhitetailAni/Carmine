//
//  YOUDIED.swift
//  Carmine
//
//  Created by WhitetailAni on 1/2/25.
//

import Cocoa

class YOUDIED: NSView {
    private let lazer = CATextLayer()
    private var originalText: String = ""
        
    init(text: String) {
        self.originalText = text
        super.init(frame: .zero)
        setup(text: text)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(text: "")
    }
    
    private func setup(text: String) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 68, weight: .bold),
            .foregroundColor: NSColor.white
        ]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        
        lazer.string = attributedText
        lazer.alignmentMode = .center
        lazer.fontSize = 72
        lazer.foregroundColor = NSColor.white.cgColor
        lazer.backgroundColor = .clear
        
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor
        layer?.addSublayer(lazer)
        
        updateTextLayerFrame()
    }
    
    private func updateTextLayerFrame() {
        let textSize = lazer.preferredFrameSize()
        lazer.frame = CGRect(
            x: (bounds.width - textSize.width) / 2,
            y: (bounds.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
    }
    
    override func layout() {
        super.layout()
        updateTextLayerFrame()
    }
    
    func animate() {
        let grow = CABasicAnimation(keyPath: "transform.scale")
        grow.fromValue = 0.5
        grow.toValue = 1.0
        grow.duration = 2.0
        
        let appear = CABasicAnimation(keyPath: "opacity")
        appear.fromValue = 0.0
        appear.toValue = 1.0
        appear.duration = 2.0
        
        let group = CAAnimationGroup()
        group.animations = [grow, appear]
        group.duration = 2.0
        group.fillMode = .forwards
        group.isRemovedOnCompletion = false
        
        lazer.opacity = 1.0
        lazer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        lazer.add(group, forKey: "textAnimation")
    }
}

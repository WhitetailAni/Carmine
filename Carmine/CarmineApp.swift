//
//  CarmineApp.swift
//  Carmine
//
//  Created by WhitetailAni on 7/23/24.
//

import AppKit

class CarmineApp: NSApplication {
    let strongDelegate = AppDelegate()

    override init() {
        super.init()
        self.delegate = strongDelegate
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

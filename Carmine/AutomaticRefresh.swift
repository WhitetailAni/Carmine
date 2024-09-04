//
//  AutomaticRefresh.swift
//  Carmine
//
//  Created by WhitetailAni on 7/27/24.
//

import Foundation

class AutomaticRefresh {
    var timer: Timer?
    var interval: TimeInterval
    var action: (() -> ())
    
    init(interval: TimeInterval, action: @escaping (() -> ())) {
        self.interval = interval
        self.action = action
    }

    func start() {
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }

    @objc func timerFired() {
        action()
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}

//
//  ProcessMonitor.swift
//  Vitals
//
//  Created by Harry Marr on 16/01/2021.
//

import Foundation
import Combine

class ProcessMonitor: ObservableObject {
    var didUpdate = PassthroughSubject<Void, Never>()
    var totalMemoryUsage: Float = 0.0
    var networkStats: Bool = true
    
    private var statsWindowsByPid: [Int : ProcessStatsWindow] = [:]
    private var timer: Timer?
    
    func start() {
        update()
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stop() {
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    @objc func fireTimer() {
        DispatchQueue.global().async {
            self.update()
        }
    }
    
    func update() {
        guard let latestSamples = sampleProcessStats(networkStats: networkStats) else {
            print("error retreiving process stats sample")
            return
        }
        let sampleTime = DispatchTime.now()

        for (pid, statsWindow) in statsWindowsByPid {
            if let sample = latestSamples[pid] {
                statsWindow.addSample(sample: sample, sampleTime: sampleTime)
            } else {
                statsWindow.addSample(sample: nil, sampleTime: sampleTime)
                if statsWindow.isStale() {
                    statsWindowsByPid.removeValue(forKey: pid)
                }
            }
        }
        
        totalMemoryUsage = 0.0
        for (pid, sample) in latestSamples {
            totalMemoryUsage += sample.memoryResidentSet
            if !statsWindowsByPid.keys.contains(pid) {
                statsWindowsByPid[pid] = ProcessStatsWindow(pid: pid, sample: sample, sampleTime: sampleTime)
            }
        }
        
        DispatchQueue.main.async {
            self.didUpdate.send()
        }
    }
    
    func topProcesses(forResourceType: ResourceType, maxResults: Int) -> [ProcessStatsWindow] {
        let sortedProcesses = statsWindowsByPid.values.sorted { (lhs, rhs) -> Bool in
            lhs.sortValue(forResourceType: forResourceType) > rhs.sortValue(forResourceType: forResourceType)
        }
        let numResults = min(sortedProcesses.count, maxResults)
        return Array(sortedProcesses[..<numResults])
    }
}

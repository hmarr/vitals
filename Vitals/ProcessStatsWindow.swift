//
//  ProcessStatsWindow.swift
//  Vitals
//
//  Created by Harry Marr on 23/01/2021.
//

import Foundation

let WindowSize = 60

class ProcessStatsWindow {
    let pid: Int
    let name: String?
    var isAlive: Bool
    private var cpuStatWindow = StatWindow()
    private var memoryStatWindow = StatWindow()
    private var lastSample: ProcessStatsSample
    private var lastSampleTime: DispatchTime
    
    init(pid: Int, sample: ProcessStatsSample, sampleTime: DispatchTime) {
        self.pid = pid
        name = sample.command
        isAlive = true
        lastSample = sample
        lastSampleTime = sampleTime
    }
    
    func addSample(sample: ProcessStatsSample?, sampleTime: DispatchTime) {
        if let sample = sample {
            let timeDelta = Float(sampleTime.uptimeNanoseconds - lastSampleTime.uptimeNanoseconds) / 1e9
            let cpuDelta = sample.cpuTimeTotal - lastSample.cpuTimeTotal
            let cpuUsage = Float(cpuDelta) / Float(timeDelta)
            cpuStatWindow.add(element: cpuUsage)
            
            memoryStatWindow.add(element: sample.memoryResidentSet)
        
            lastSample = sample
            lastSampleTime = sampleTime
            isAlive = true
        } else {
            cpuStatWindow.add(element: nil)
            memoryStatWindow.add(element: nil)
            isAlive = false
        }
    }
    
    func values(forResourceType: ResourceType) -> [Float?] {
        switch forResourceType {
        case .cpu:
            return cpuStatWindow.array()
        case .memory:
            return memoryStatWindow.array()
        default:
            return cpuStatWindow.array()
        }
    }
    
    func sortValue(forResourceType: ResourceType) -> Float {
        switch forResourceType {
        case .cpu:
            return cpuStatWindow.aggregate
        case .memory:
            return memoryStatWindow.aggregate
        default:
            return cpuStatWindow.aggregate
        }
    }
    
    func isStale() -> Bool {
        return !isAlive && cpuStatWindow.isEmpty()
    }
}

class StatWindow {
    private var items = [Float?](repeating: nil, count: WindowSize)
    private var index = 0
    var aggregate: Float = 0.0
    
    func add(element: Float?) {
        index = (index + 1) % WindowSize
        
        if let prevElement = items[index] {
            removeFromAggregate(element: prevElement)
        }
        if let newElement = element {
            addToAggregate(element: newElement)
        }
        
        items[index] = element
    }
    
    // Return an array of the values in the window in insertion order
    func array() -> [Float?] {
        return Array(items[(index + 1)...]) + Array(items[...index])
    }
    
    func isEmpty() -> Bool {
        items.filter { (value) -> Bool in
            value == nil
        }.count == WindowSize
    }
    
    func addToAggregate(element: Float) {
        aggregate += element
    }
    
    func removeFromAggregate(element: Float) {
        aggregate -= element
    }
}

//
//  ProcessStats.swift
//  Vitals
//
//  Created by Harry Marr on 23/01/2021.
//

import Foundation
import Dispatch

enum ResourceType: String, CaseIterable, Identifiable {
    case cpu
    case memory
    case network

    var id: String { self.rawValue }
}

struct ProcessStatsSample {
    let command: String
    let cpuTimeUser: Float
    let cpuTimeSystem: Float
    let cpuTimeTotal: Float
    let memoryResidentSet: Float
}

func sampleProcessStats() -> [Int : ProcessStatsSample]? {
    guard let psOutput = shell("/bin/ps", ["-e", "-c", "-o", "pid,cputime,utime,rss,comm"]) else { return nil }
    var samples = [Int : ProcessStatsSample]()
    for line in psOutput.components(separatedBy: .newlines).dropFirst() {
        if line == "" {
            continue
        }
        
        let parts = line.split(separator: " ", maxSplits: 4, omittingEmptySubsequences: true)
        guard parts.count == 5 else {
            print("expected 5 parts in ps output: \(parts)")
            continue
        }
        guard let pid = Int(parts[0]) else {
            print("error parsing pid from ps output: \(parts[0])")
            continue
        }
        guard let cpuTimeTotal = parsePsTime(String(parts[1])) else {
            print("error parsing time from ps output: \(parts[1])")
            continue
        }
        guard let cpuTimeUser = parsePsTime(String(parts[2])) else {
            print("error parsing time from ps output: \(parts[2])")
            continue
        }
        guard let memoryResidentSet = Float(parts[3]) else {
            print("error parsing memory from ps output: \(parts[3])")
            continue
        }
        samples[pid] = ProcessStatsSample(
            command: String(parts[4]),
            cpuTimeUser: cpuTimeUser,
            cpuTimeSystem: cpuTimeTotal - cpuTimeUser,
            cpuTimeTotal: cpuTimeTotal,
            memoryResidentSet: memoryResidentSet
        )
    }
    return samples
}

func shell(_ launchPath: String, _ arguments: [String]) -> String? {
    let process = Process()
    let pipe = Pipe()
    
    process.environment = ["LANG" : "en_US.UTF-8"]
    process.standardOutput = pipe
    process.launchPath = launchPath
    process.arguments = arguments
    process.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()

    process.waitUntilExit()
    if process.terminationStatus != 0 {
        return nil
    }
    
    let output = String(data: data, encoding: .utf8)
    return output
}


// Parse time in format MINS:SECS.HUNDREDTHS (e.g. 01:02.03 -> 62.03s)
func parsePsTime(_ psTime: String) -> Float? {
    var timeHundredths: UInt32 = 0
    var acc: UInt32 = 0
    var state = 0
    let digitCodeOffset = "0".unicodeScalars.first!.value
    for i in psTime.unicodeScalars {
        if i == ":" {
            // Add accumulated minutes
            state += 1
            timeHundredths += 6000 * acc
            acc = 0
            continue
        }
        if i == "." {
            // Add accumulated seconds
            state += 1
            timeHundredths += 100 * acc
            acc = 0
            continue
        }
        acc *= 10
        acc += i.value - digitCodeOffset
    }
    if state != 2 {
        return nil
    }
    
    // Add accumulated hundredths
    return Float(timeHundredths + acc) / 100.0

// Old slower implementation:
//    let fractionalParts = psTime.split(separator: ".", maxSplits: 1)
//    guard let hundredths = Int(fractionalParts[1]) else { return nil }
//
//    let minSecParts = fractionalParts[0].split(separator: ":", maxSplits: 1)
//    guard let mins = Int(minSecParts[0]) else { return nil }
//    guard let secs = Int(minSecParts[1]) else { return nil }
//
//    return Float(mins) * 60.0 + Float(secs) + Float(hundredths) / 100.0
}

//
//  Sparkline.swift
//  Vitals
//
//  Created by Harry Marr on 16/01/2021.
//

import SwiftUI

struct SparklineChart: View {
    var values: [Float]
    var color: Color

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(NSColor.controlBackgroundColor).opacity(0.8))
                .cornerRadius(2.0)
            Sparkline(values: values).fill(color.opacity(0.7))
            
            let maxValue = values.max() ?? 0.0
            if maxValue > 1.0 {
                Sparkline(values: values.map({ max($0 - 1.0, 0.0) }))
                    .fill(color.opacity(0.5))
            }
            if maxValue > 2.0 {
                Sparkline(values: values.map({ max($0 - 2.0, 0.0) }))
                    .fill(color.opacity(0.5))
            }
            if maxValue > 3.0 {
                Sparkline(values: values.map({ max($0 - 3.0, 0.0) }))
                    .fill(color.opacity(1.0))
            }
        }
    }
    
    struct Sparkline: Shape {
        var values: [Float]

        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            let segmentWidth = rect.maxX / CGFloat(values.count - 1)
            
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - (CGFloat(clamp(values[0])) * rect.maxY)))
            
            for (index, value) in values.dropFirst().enumerated() {
                let x = CGFloat(index + 1) * segmentWidth
                let y = rect.maxY - (CGFloat(clamp(value)) * rect.maxY)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            
            return path
        }
        
        func clamp(_ value: Float) -> Float {
            return max(0.0, min(1.0, value))
        }
    }
}

struct Sparkline_Previews: PreviewProvider {
    static let values: [Float] = [
        3.8,
        3.1,
        3.5,
        3.3,
        2.7,
        2.3,
        1.5,
        1.4,
        1.4,
        0.9,
        0.25,
        0.32,
        0.78,
        0.12,
        0.15,
        0.03,
        0.0
    ]
    
    static var previews: some View {
        SparklineChart(values: values, color: .blue).frame(width: 300, height: 40)
    }
}

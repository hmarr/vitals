//
//  ContentView.swift
//  Vitals
//
//  Created by Harry Marr on 16/01/2021.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    let monitor: ProcessMonitor
    var cancellable: AnyCancellable?
    
    @Published var contentVisible: Bool = false
    @Published var topProcesses: [ProcessStatsWindow] = []
    @Published var selectedResource: ResourceType = .cpu {
        didSet {
            self.refreshProcesses()
        }
    }
    
    init(monitor: ProcessMonitor, contentVisible: Bool) {
        self.monitor = monitor
        self.contentVisible = contentVisible
        self.refreshProcesses()
        self.cancellable = monitor.didUpdate.sink(receiveValue: {
            self.refreshProcesses()
        })
    }
    
    func cycleSelectedResource(direction: Int) {
        var i = ResourceType.allCases.firstIndex(of: selectedResource)! + direction
        if i < 0 {
            i += ResourceType.allCases.count
        }
        selectedResource = ResourceType.allCases[i % ResourceType.allCases.count]
    }
    
    func refreshProcesses() {
        topProcesses = monitor.topProcesses(forResourceType: selectedResource, maxResults: 20)
    }
    
    func chartValues(resourceValues: [Float?]) -> [Float] {
        switch (selectedResource) {
        case .cpu:
            return resourceValues.map { (val) -> Float in
                max(min((val ?? 0.0), 4.0), 0.0)
            }
        case .memory:
            return resourceValues.map { (val) -> Float in
                (val ?? 0.0) / (monitor.totalMemoryUsage / 4.0)
            }
        case .networkIn, .networkOut:
            return resourceValues.map { (val) -> Float in
                (val ?? 0.0) / 1e6
            }
        }
    }
    
    func formattedValue(value: Float?) -> String {
        switch (selectedResource) {
        case .cpu:
            if let v = value {
                return String(format: "%3.0f%%", v * 100.0)
            }
            return "-"
        case .memory:
            // TODO figure out a suitable y-axis scale
            if let v = value {
                return String(format: "%2.1f GB", v / 1e6)
            }
            return "-"
        case .networkIn, .networkOut:
            if let v = value {
                switch v {
                case 0..<1e6:
                    return String(format: "%3.0f kB", v / 1e3)
                case 1e6..<1e9:
                    return String(format: "%3.0f MB", v / 1e6)
                default:
                    return String(format: "%3.0f GB", v / 1e9)
                }
            }
            return "-"
        }
        
    }
}


struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    private static let processListHeight = 460
    private static let topPadding = 8
    private static let bottomPadding = 4
    private static var leftPadding: Int {
        if #available(macOS 11.0, *) {
            return 14
        }
        return 22
    }
    private static let rightPadding = 12
    static let totalHeight = topPadding + bottomPadding + processListHeight
    
    var body: some View {
        if viewModel.contentVisible {
            VStack {
                HStack {
                    Text(viewModel.selectedResource.rawValue).bold()

                    Spacer()

                    Button("􀆉") {
                        viewModel.cycleSelectedResource(direction: -1)
                    }.buttonStyle(BorderlessButtonStyle())

                    Button("􀆊") {
                        viewModel.cycleSelectedResource(direction: 1)
                    }.buttonStyle(BorderlessButtonStyle())
                }.frame(height: 20)

                VStack(spacing: 6) {
                    ForEach(viewModel.topProcesses, id: \.pid) { process in
                        HStack {
                            Group {
                                if process.isAlive {
                                    Text(process.name!)

                                } else {
                                    Text(process.name!)
                                        .foregroundColor(Color(NSColor.labelColor).opacity(0.5))
                                        .italic()
                                }
                            }.frame(maxWidth: .infinity, alignment: .leading)
                            
                            let resourceValues = process.values(forResourceType: viewModel.selectedResource)
                            
                            SparklineChart(values: viewModel.chartValues(resourceValues: resourceValues), color: .blue).frame(maxWidth: .infinity)
                            
                            Text(viewModel.formattedValue(value: resourceValues.last!))
                                .font(Font.system(.caption).monospacedDigit())
                                .frame(width: 45, alignment: .trailing)
                        }
                    }
                }.frame(
                    maxWidth: .infinity,
                    maxHeight: CGFloat(ContentView.processListHeight)
                )
            }.padding(
                EdgeInsets(
                    top: CGFloat(ContentView.topPadding),
                    leading: CGFloat(ContentView.leftPadding),
                    bottom: CGFloat(ContentView.bottomPadding),
                    trailing: CGFloat(ContentView.rightPadding)
                )
            )
        } else {
            EmptyView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let processMonitor = ProcessMonitor()
        let _ = processMonitor.update()
        let _ = processMonitor.update()
        let _ = processMonitor.update()
        let viewModel = ContentViewModel(monitor: processMonitor, contentVisible: true)
        ContentView(viewModel: viewModel)
    }
}

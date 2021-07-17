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
                (val ?? 0.0) / monitor.totalMemoryUsage
            }
        case .network:
            // TODO
            return [0.0]
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
        case .network:
            // TODO
            return "-"
        }
        
    }
}


struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    private static let processListHeight = 460
    private static let topPadding = 6
    private static let bottomPadding = 4
    static let totalHeight = topPadding + bottomPadding + processListHeight
    
    var body: some View {
        if viewModel.contentVisible {
            VStack(spacing: 6) {
//             Hide resource picker until:
//             1. Memory usage visualisation is better - the per-process bar chart doesn't work well,
//                at the very least the y-axis scaling needs to change.
//             2. Support for network IO monitoring lands.
//             ------------------------------------------------------------------------
//                Picker("Resource Type", selection: $viewModel.selectedResource) {
//                    Text("CPU").tag(ResourceType.cpu)
//                    Text("Memory").tag(ResourceType.memory)
//                    Text("Network").tag(ResourceType.network)
//                }
//                .pickerStyle(SegmentedPickerStyle())
//                .labelsHidden()
//                .frame(maxWidth: 200).padding(.bottom, 5)
//             ------------------------------------------------------------------------

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
            ).padding(
                EdgeInsets(
                    top: CGFloat(ContentView.topPadding),
                    leading: 22,
                    bottom: CGFloat(ContentView.bottomPadding),
                    trailing: 12
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

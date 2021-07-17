//
//  AppDelegate.swift
//  Vitals
//
//  Created by Harry Marr on 16/01/2021.
//

import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBar: StatusBarController?
    let processMonitor = ProcessMonitor()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        processMonitor.start()
        
        // Create the SwiftUI view that provides the contents
        let viewModel = ContentViewModel(monitor: processMonitor, contentVisible: true)
        let contentView = ContentView(viewModel: viewModel)
        
        let hostingView = NSHostingView(rootView: contentView)
        statusBar = StatusBarController(contentViewModel: viewModel, contentView: hostingView)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        processMonitor.stop()
    }
}

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
    var popover = NSPopover.init()
    var statusBar: StatusBarController?
    let processMonitor = ProcessMonitor()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        processMonitor.start()
        
        // Create the SwiftUI view that provides the contents
        let viewModel = ContentViewModel(monitor: processMonitor, contentVisible: false)
        let contentView = ContentView(viewModel: viewModel)

        // Note: we _don't_ want to make the popover's behaviour "transient" as we handle all the click
        // detection ourselves in the StatusBarController, which gives us more control
        popover.contentSize = NSSize(width: 400, height: 492)
        // Put the SwiftUI content inside the popover
        popover.contentViewController = NSHostingController(rootView: contentView)
        popover.animates = false

        statusBar = StatusBarController.init(popover, contentViewModel: viewModel)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        processMonitor.stop()
    }
}

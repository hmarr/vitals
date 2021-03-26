//
//  StatusBarController.swift
//  Vitals
//
//  Created by Harry Marr on 16/01/2021.
//

import AppKit
import LaunchAtLogin

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var launchAtLoginItem: NSMenuItem
    private var contentViewModel: ContentViewModel
    private var clickMonitor: Any?
    
    init(contentViewModel: ContentViewModel, contentView: NSView) {
        self.contentViewModel = contentViewModel
        
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: 28.0)
        
        let statusBarMenu = NSMenu(title: "Status Bar Menu")
        
        let contentItem = NSMenuItem()
        contentView.frame = NSRect(x: 0, y: 0, width: 400, height: 500)
        contentItem.view = contentView
        statusBarMenu.addItem(contentItem)
        
        statusBarMenu.addItem(.separator())
        
        launchAtLoginItem = statusBarMenu.addItem(
            withTitle: "Launch at Login",
            action: #selector(toggleLaunchAtLogin(sender:)),
            keyEquivalent: ""
        )
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        launchAtLoginItem.target = self
        
        let quitItem = statusBarMenu.addItem(
            withTitle: "Quit Vitals",
            action: #selector(quit(sender:)),
            keyEquivalent: ""
        )
        quitItem.target = self

        statusItem.menu = statusBarMenu
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(named: "MenuIcon")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
        }
    }
    
    @objc func quit(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func toggleLaunchAtLogin(sender: AnyObject) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
    }
}

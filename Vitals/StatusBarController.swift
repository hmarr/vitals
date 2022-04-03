//
//  StatusBarController.swift
//  Vitals
//
//  Created by Harry Marr on 16/01/2021.
//

import AppKit
import LaunchAtLogin

class StatusBarController: NSObject, NSMenuDelegate {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var launchAtLoginItem: NSMenuItem
    private var networkStatsItem: NSMenuItem
    private var contentViewModel: ContentViewModel
    private var clickMonitor: Any?
    
    init(contentViewModel: ContentViewModel, contentView: NSView) {
        self.contentViewModel = contentViewModel
        
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: 28.0)
        
        let statusBarMenu = NSMenu(title: "Status Bar Menu")
        
        let contentItem = NSMenuItem()
        contentView.frame = NSRect(x: 0, y: 0, width: 460, height: ContentView.totalHeight)
        contentItem.view = contentView
        statusBarMenu.addItem(contentItem)
        
        statusBarMenu.addItem(.separator())
        
        launchAtLoginItem = statusBarMenu.addItem(
            withTitle: "Launch at Login",
            action: #selector(toggleLaunchAtLogin(sender:)),
            keyEquivalent: ""
        )
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
        
        networkStatsItem = statusBarMenu.addItem(
            withTitle: "Enable Network Statistics",
            action: #selector(toggleNetworkStats(sender:)),
            keyEquivalent: ""
        )
        let networkStatsStatus = UserDefaults.standard.bool(forKey: "networkStatsEnabled")
        networkStatsItem.state = networkStatsStatus ? .on : .off
        self.contentViewModel.networkStats = networkStatsStatus
        
        let quitItem = statusBarMenu.addItem(
            withTitle: "Quit Vitals",
            action: #selector(quit(sender:)),
            keyEquivalent: ""
        )

        statusItem.menu = statusBarMenu
        
        super.init()
        
        statusBarMenu.delegate = self
        launchAtLoginItem.target = self
        networkStatsItem.target = self
        quitItem.target = self
        
        if let statusBarButton = statusItem.button {
            statusBarButton.image = NSImage(named: "MenuIcon")
            statusBarButton.image?.size = NSSize(width: 18.0, height: 18.0)
            statusBarButton.image?.isTemplate = true
        }
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        contentViewModel.contentVisible = true
    }
    
    func menuDidClose(_ menu: NSMenu) {
        contentViewModel.contentVisible = false
    }
    
    @objc func quit(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func toggleLaunchAtLogin(sender: AnyObject) {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        launchAtLoginItem.state = LaunchAtLogin.isEnabled ? .on : .off
    }
    
    @objc func toggleNetworkStats(sender: AnyObject) {
        let newValue = !UserDefaults.standard.bool(forKey: "networkStatsEnabled")
        UserDefaults.standard.set(newValue, forKey: "networkStatsEnabled")
        networkStatsItem.state = newValue ? .on : .off
        self.contentViewModel.networkStats = newValue
    }
}

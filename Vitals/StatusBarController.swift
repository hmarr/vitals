//
//  StatusBarController.swift
//  Vitals
//
//  Created by Harry Marr on 16/01/2021.
//

import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var contentViewModel: ContentViewModel
    private var clickMonitor: Any?
    
    init(_ popover: NSPopover, contentViewModel: ContentViewModel) {
        self.popover = popover
        self.contentViewModel = contentViewModel
        
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: 28.0)
        
        let statusBarMenu = NSMenu(title: "Status Bar Menu")
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

            
            // This seems to work better than setting a target and action on the button - click events
            // come through more quickly and reliably, and it doesn't seem to get stuck on double-clicks
            NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { (event) -> NSEvent? in
                if event.window == statusBarButton.window {
                    if event.type == .rightMouseDown {
                        // If the user right clicks when the popoup is visible, hide the popup and show the menu
                        if popover.isShown {
                            self.togglePopover(sender: self)
                        }
                        // Never capture right clicks as we always want the menu behaviour to work
                        return event
                    } else {
                        // Cmd + click should begin dragging the menu bar icon
                        if event.modifierFlags.contains(.command) {
                            return event
                        }
                        
                        // For left clicks, toggle the popover and capture clicks so we don't show the menu
                        self.togglePopover(sender: self)
                        return nil
                    }
                }
                return event
            }
        }
    }
    
    @objc func quit(sender: AnyObject) {
        NSApplication.shared.terminate(self)
    }
    
    @objc func togglePopover(sender: AnyObject) {
        if popover.isShown {
            hidePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    func showPopover(_ sender: AnyObject) {
        if let statusBarButton = statusItem.button {
            contentViewModel.contentVisible = true
            
            statusItem.button?.highlight(true)
            popover.show(relativeTo: statusBarButton.bounds, of: statusBarButton, preferredEdge: NSRectEdge.maxY)
            popover.contentViewController?.view.window?.becomeKey()
            
            // Hide the popover when the user clicks outside it
            clickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { (event) in
                // Ignore statusBarButton clicks as we already have a monitor for that
                if event.window != statusBarButton.window {
                    self.hidePopover(event)
                }
            }
        }
    }
    
    func hidePopover(_ sender: AnyObject) {
        statusItem.button?.highlight(false)
        popover.performClose(sender)
        popover.contentViewController?.view.window?.resignKey()
        
        contentViewModel.contentVisible = false
        
        if let clickMonitor = clickMonitor {
            NSEvent.removeMonitor(clickMonitor)
            self.clickMonitor = nil
        }
    }
}

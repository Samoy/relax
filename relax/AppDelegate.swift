//
//  AppDelegate.swift
//  relax
//
//  Created by Samoy Young on 2020/9/23.
//

import Cocoa
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    var statusBarItem: NSStatusItem!
    var lastBarItem:NSMenuItem? = nil
    var duration:Float = 60 * 60
    var times:[String] = ["30分钟","1小时","2小时"]
    var desc = "1小时"
    var timer:Timer? = nil
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        initMenuBar()
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(startTimer), name: NSWorkspace.didWakeNotification, object: nil)
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(stopTimer), name: NSWorkspace.willSleepNotification, object: nil)
    }

    @objc func startTimer() {
        initTimer(durtaion: duration)
    }
    
    @objc func stopTimer(){
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    fileprivate func initMenuBar() {
        // Insert code here to initialize your application
        let statusBar = NSStatusBar.system
        statusBarItem = statusBar.statusItem(
            withLength: NSStatusItem.squareLength)
        statusBarItem.button?.image = NSImage(named: "relax")
        
        let statusBarMenu = NSMenu(title: "休息一下吧")
        
        // 添加启停菜单
        let switchMenuItem = NSMenuItem(title: "打开提醒", action: #selector(switchTimer), keyEquivalent: "")
        switchMenuItem.state = .on
        statusBarMenu.addItem(switchMenuItem)
        
        // 添加提醒时间菜单
        let menuItem = NSMenuItem(title: "提醒频率", action: nil, keyEquivalent: "")
        let subMenu = NSMenu()
        for time in times {
            let subMenuItem = NSMenuItem(title: time, action: #selector(changeDuration), keyEquivalent: "")
            if time == "1小时" {
                lastBarItem = subMenuItem
                subMenuItem.state = .on
                startTimer()
            }
            subMenu.addItem(subMenuItem)
        }
        statusBarMenu.addItem(menuItem)
        statusBarMenu.setSubmenu(subMenu, for: menuItem)
        
        // 添加退出菜单
        let exitMenuItem = NSMenuItem(title: "退出", action: #selector(exit), keyEquivalent: "")
        statusBarMenu.addItem(exitMenuItem)
        
        statusBarItem.menu = statusBarMenu
    }
    
    @objc func switchTimer(sender:NSMenuItem){
        if sender.state == .on {
            stopTimer()
            sender.state = .off
            return
        }
        if sender.state == .off {
            startTimer()
            sender.state = .on
        }
    }
    
    @objc func exit(){
        removeAllNotifition()
        NSApplication.shared.terminate(self)
    }
    
    @objc func changeDuration(sender:NSMenuItem) {
        lastBarItem?.state = .off
        sender.state = .on
        duration = getDuration(title: sender.title)
        desc = sender.title
        lastBarItem = sender
        startTimer()
    }
    
    fileprivate func getDuration(title:String) -> Float {
        switch title {
        case times[0]:return 30 * 60
        case times[1]:return 60 * 60
        case times[2]:return 120 * 60
        default:return 60 * 60
        }
    }
    
    fileprivate func initTimer(durtaion:Float){
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(duration), repeats: true) { (t) in
            self.showNotifition()
        }
        timer?.fireDate = Date(timeInterval: TimeInterval(duration), since: Date())
    }
    
    fileprivate func showNotifition(){
        removeAllNotifition()
        let notificationCenter = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "休息提示"
        content.body = "您已经工作\(desc)了，为了保护您的视力，请远眺一会儿吧！"
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: nil)
        notificationCenter.requestAuthorization(options: .alert) { (granted, error) in
            if(granted){
                notificationCenter.delegate = self
                notificationCenter.add(request)
            }
        }
    }
    
    func removeAllNotifition() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    @objc func dismissNotifition(sender:Any){
        print(sender)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(center,notification)
        completionHandler(.alert)
    }
    
    
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}


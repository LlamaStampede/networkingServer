//
//  ViewController.swift
//  Test
//
//  Created by Tyler Chermely on 8/2/17.
//  Copyright © 2017 TylerC. All rights reserved.
//

import Cocoa
//import SwiftSocket

class ViewController: NSViewController {

    @IBOutlet weak var ServerAddressBox: NSTextField!
    @IBOutlet var consoleLog: NSTextView!
    @IBOutlet weak var sendBroadcast: NSButton!
    var timer : Timer = Timer()
    
    
    @IBAction func connectButtonPresses(_ sender: Any) {
        var result : String = ""
        var success = Server.instance.startServer(address: &result)
        //broadCast()
        if success
        {
            consoleLog.string? += "Successfully connected to " + result + "\n"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scheduledTimerWithTimeInterval()
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func broadCast() -> String
    {
        
        var broadcastText = ServerAddressBox.stringValue
        return broadcastText
    }
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateCounting), userInfo: nil, repeats: true)
    }
    
    @IBAction func enterButtonPressed(_ sender: Any) {
        
        var clientList = Server.instance.getClients()
        //print(clientList)
        for i in clientList
        {
            //print("Working")
            //print (i, broadCast())
            consoleLog.string? += "<Server> \(broadCast())\n"
            i.send(string: broadCast())//, "Message from Server"))
        }
        ServerAddressBox.stringValue = ""
    }
    
    func updateCounting(){
        if Server.instance.updateServer()
        {
            consoleLog.string? += "A new client has connected to the server\n"  //add here for client messgaes?
        }
       
    }
}


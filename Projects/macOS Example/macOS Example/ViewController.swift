//
//  ViewController.swift
//  macOS Example
//
//  Created by Richard James Stelling on 27/01/2017.
//  Copyright © 2017 Richard Stelling. All rights reserved.
//

import Cocoa
import Hostess

class ViewController: NSViewController {

    let hostess = Hostess()
    
    @IBOutlet weak var ssid: NSTextField!
    @IBOutlet weak var addresses: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.ssid.stringValue = self.hostess.name ?? "Unknown"
        
        self.addresses.stringValue = self.hostess.addresses.reduce("") { $0 + "\($1)\n" }
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}


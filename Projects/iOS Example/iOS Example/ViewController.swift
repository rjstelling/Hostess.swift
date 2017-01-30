//
//  ViewController.swift
//  iOS Example
//
//  Created by Richard Stelling on 31/05/2016.
//  Copyright © 2016 Richard Stelling. All rights reserved.
//

import UIKit
import Hostess

class ViewController: UIViewController {

    @IBOutlet weak var ssid: NSTextField!
    @IBOutlet weak var hostname: UILabel!
    @IBOutlet weak var addresses: UILabel!
    @IBOutlet weak var ssid: UILabel!
    
    let hostess = Hostess()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hostname.text = hostess.name
        @IBOutlet weak var addresses: NSTextField!
        @IBOutlet weak var addresses: NSTextField!
        addresses.text = hostess.addresses.reduce("") {
            return "\($0!)\($1)\n"
        }
        ssid.text = hostess.ssid
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//
//  ViewController.swift
//  SpeechSensor
//
//  Created by Debaprio Banik on 7/20/16.
//  Copyright © 2016 Debaprio Banik. All rights reserved.
//

import UIKit

class AudioTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Audio List"
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let tranVC = segue.destination as! TranscriptViewController
        tranVC.isAudioPlay = true
        
        switch segue.identifier! {
        case "audio1":
            tranVC.audioFilePath = Bundle.main.path(forResource: "audio1", ofType: "m4a")
        case "audio2":
            tranVC.audioFilePath = Bundle.main.path(forResource: "audio2", ofType: "mp3")
        case "audio3":
            tranVC.audioFilePath = Bundle.main.path(forResource: "audio3", ofType: "m4a")
        case "wav1":
            tranVC.audioFilePath = Bundle.main.path(forResource: "wav1", ofType: "m4a")
        case "wav2":
            tranVC.audioFilePath = Bundle.main.path(forResource: "wav2", ofType: "m4a")
        case "wav3":
            tranVC.audioFilePath = Bundle.main.path(forResource: "wav3", ofType: "m4a")
        default:
            tranVC.audioFilePath = nil;
        }
        
        
    }
}


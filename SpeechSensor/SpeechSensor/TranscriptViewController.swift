//
//  TranscriptViewController.swift
//  SpeechSensor
//
//  Created by Debaprio Banik on 7/20/16.
//  Copyright © 2016 Debaprio Banik. All rights reserved.
//

import Foundation
import UIKit
import Speech
import AVFoundation


public class TranscriptViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    // MARK: Properties
    
    public var isAudioPlay = false
    var transcriptSegments:[SFTranscriptionSegment]?
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var player:AVAudioPlayer?
    var audioFilePath:String?
    var timer: Timer?
    var registeredProducts = ["iPhone","iCloud","iMac","iPad","Mac","Macbook","iPod", "iCloud","iTunes", "Apple", "AppStore"]
    
    let angryKeywords = ["contemplative","disappointed","disconnected","distracted","grounded","listless","low","regretful","steady","wistful","dejected","Discouraged","Dispirited","Down","Downtrodden","Drained","Forlorn","Gloomy","Grieving","Heavy-hearted","Melancholy","Mournful","Sad","Sorrowful","Weepy","World-weary","Anguished","Bereaved","Bleak","Depressed","Despairing","Despondent","Grief-stricken","Heartbroken","Hopeless","Inconsolable","Morose"]
    
    let happyKeywords = ["happy","Amused","Calm","Encouraged","Friendly","Hopeful","Inspired","Jovial","Open","Peaceful","Smiling","Upbeat","Cheerful","Contented","Delighted","Excited","Fulfilled","Glad","Gleeful","Gratified","Happy","Healthy,Self-esteem","Joyful","Lively","Merry","Optimistic","Playful","Pleased","Proud","Rejuvenated","Satisfied","Awe-filled","Blissful","Ecstatic","Egocentric","Elated","Enthralled","Euphoric","Exhilarated","Giddy","Jubilant","Manic","Overconfident","Overjoyed","Radiant","Rapturous","Self-aggrandized","Thrilled"]
    
    var counter = 0
    
    @IBOutlet weak var textView     : UITextView!
    @IBOutlet weak var startButton  : UIButton!
    @IBOutlet weak var statusLabel  : UILabel!
    @IBOutlet weak var playButton   : UIButton!
    
    // MARK: UIViewController
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.statusLabel.text = ""
        if self.isAudioPlay == true {
            self.startButton.isHidden = true
            self.playButton.isHidden = false
        } else {
            self.playButton.isHidden = true
            self.startButton.isHidden = false
        }
        
        // Disable the start button until authorization has been granted.
        self.title = "Transcript"
        self.startButton.isEnabled = false
        
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.startButton.isEnabled = true
                    
                case .denied:
                    self.startButton.isEnabled = false
                    self.startButton.setTitle("User denied access to speech recognition", for: .disabled)
                    
                case .restricted:
                    self.startButton.isEnabled = false
                    self.startButton.setTitle("Speech recognition restricted on this device", for: .disabled)
                    
                case .notDetermined:
                    self.startButton.isEnabled = false
                    self.startButton.setTitle("Speech recognition not yet authorized", for: .disabled)
                }
            }
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        
        if recognitionTask != nil {
            self.recognitionTask?.cancel()
            
            self.recognitionTask = nil
            
            if(player != nil)
            {
                self.player?.stop()
            }
            self.playButton.setTitle("Play Audio", for: [])
        }
    }
    
    
    
    // MARK: SFSpeechRecognizerDelegate
    
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            self.startButton.isEnabled = true
            self.startButton.setTitle("Start Recording", for: [])
        } else {
            self.startButton.isEnabled = false
            self.startButton.setTitle("Recognition not available", for: .disabled)
        }
    }
    
    
    @IBAction func playAudio(_ sender: UIButton) {
        
        if recognitionTask != nil {
            
            //self.recognitionTask?.cancel()
            self.recognitionTask?.finish()
            self.recognitionRequest = nil
            self.recognitionTask = nil
            
            if(player != nil || (player?.isPlaying)!)
            {
                self.player?.stop()
            }
            self.playButton.setTitle("Pausing..", for: [])
            self.playButton.isEnabled = false
        }
        else{
            if let path = self.audioFilePath {
                let recognizer = SFSpeechRecognizer()
                let request = SFSpeechURLRecognitionRequest(url: URL(fileURLWithPath: path))
                if let timer = self.timer {
                    timer.invalidate()
                }
                do{
                    self.player = try AVAudioPlayer(contentsOf:URL(fileURLWithPath: path))
                    self.player?.prepareToPlay()
                    let playing =  self.player?.play()
                    if(playing)!
                    {
                        print("Playing")
                        
                    }
                    self.playButton.setTitle("Pause Audio", for: [])
                }catch {
                    print("Error getting the audio file")
                }
                
                if let timer = self.timer {
                    timer.invalidate()
                }
                
                self.navigationController?.navigationItem.leftBarButtonItem?.isEnabled = false
                self.recognitionTask = recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
                    self.handleResult(result: result, error: error, inputnode: nil)
                })
            }
        }
    }
    
    //MARK: Result handler
    
    func handleResult(result: SFSpeechRecognitionResult?, error: NSError?, inputnode: AVAudioInputNode?) {
        var isFinal = false
        self.counter = 0
        if let result = result {
            OperationQueue.main.addOperation {
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
                if isFinal == true {
                    
                    self.transcriptSegments = result.bestTranscription.segments
                    print(self.transcriptSegments)
                    
                    if let info = self.extractInformationFromResult(result)
                    {
                        self.statusLabel.text = info
                        
                    }else{
                        
                        self.statusLabel.text = "Finished."
                        
                    }
                    // self.navigationController?.navigationItem.leftBarButtonItem?.isEnabled = true
                    self.playButton.setTitle("Play Audio", for: [])
                    self.playButton.isEnabled = true
                    self.recognitionTask = nil
                    self.timer?.invalidate()
                } else {
                    self.statusLabel.text = ""
                }
            }
        }
        
        if error != nil || isFinal {
            self.audioEngine.stop()
            
            self.recognitionTask?.finish()
            if inputnode != nil {
                inputnode?.removeTap(onBus: 0)
            }
            
            self.recognitionRequest = nil
            self.recognitionTask = nil
            self.textView.text = "Unable to receive speech"
            if (error != nil){
                
                let alertController =  UIAlertController(title:"Error", message: error?.localizedDescription, preferredStyle: .alert)
                
                let alertAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) in })
                
                alertController.addAction(alertAction)
                
                self.timer?.invalidate()
                
                if (self.player != nil) {
                    self.player?.stop()
                }
                
                self.present(alertController, animated: true, completion: nil)
            }
            self.startButton.isEnabled = true
            self.startButton.setTitle("Start Recording", for: [])
            self.playButton.setTitle("Play Audio", for: [])
            self.playButton.isEnabled = true
        }
    }
    
    func extractInformationFromResult(_ result: SFSpeechRecognitionResult?) -> String?
    {
        var keywordDict = [String:Int]()
        var information:String? = nil
        
        var products = []
        var angrykeywords = []
        var happykeywords = []
        
        //Check for the prodect mentioned in audio
        for product in registeredProducts
        {
            var count = 0
            for (_, value) in (transcriptSegments?.enumerated())!
            {
                if value.substring == product
                {
                    count += 1
                    keywordDict[product] = count
                }
            }
        }
        
        for(key, value) in keywordDict
        {
            products = products.adding("\(key) (\(value))")
        }
        
        //Check for angry keywords
        for angrykeyword in angryKeywords
        {
            for (_, value) in (transcriptSegments?.enumerated())!
            {
                if value.substring == angrykeyword
                {
                    angrykeywords = angrykeywords.adding(angrykeyword)
                    
                }
            }
        }
        
        //Check for happy keywords
        for happykeyword in happyKeywords
        {
            for (_, value) in (transcriptSegments?.enumerated())!
            {
                if value.substring == happykeyword
                {
                    happykeywords = happykeywords.adding(happykeyword)
                    break;
                }
            }
        }
        
        
        if (products.count > 0)
        {
            information = "Products: " + "\(products.componentsJoined(by: ", ")) \r"
        }
        if (angrykeywords.count > 0 )
        {
            if(information != nil)
            {
                information = information! + "Angry keywords: " + angrykeywords.componentsJoined(by: ",")
            }
            else
            {
                information = "Angry keywords: " + angrykeywords.componentsJoined(by: ",")
            }
        }
        if (happykeywords.count > 0 )
        {
            if(information != nil)
            {
                information = information! + "Happy keywords: " + happykeywords.componentsJoined(by: ",")
            }
            else
            {
                information = "happy keywords: " + happykeywords.componentsJoined(by: ",")
            }
        }
        
        return information
    }
}

extension SFTranscriptionSegment
{
    var endTime:TimeInterval {
    return timestamp + duration
    
    }

}

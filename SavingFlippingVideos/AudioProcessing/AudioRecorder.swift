//
//  AudioRecorder.swift
//  Vitcord
//
//  Created by Carlos Roig on 19/06/2019.
//  Copyright © 2019 Vitcord. All rights reserved.
//

import Foundation
import AVFoundation

final class AudioController: NSObject {
    
    var audioSession: AVAudioSession {
        return AVAudioSession.sharedInstance()
    }
    
    var audioRecorder: AVAudioRecorder!
    var audioUrl: URL!
    
    func prepare() {
        guard let _ = try? audioSession.setCategory(AVAudioSession.Category.playAndRecord),
            let _ = try? audioSession.setActive(true) else {
                return
        }
        self.audioUrl = URL.createFileURL(at: NSTemporaryDirectory(), pathExtension: "m4a")
        
    }
    
    func startRecording() {
        let audioOutputSettings: Dictionary<String, AnyObject> = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC) as AnyObject,
            AVNumberOfChannelsKey : 1 as AnyObject,
            AVSampleRateKey : AVAudioSession.sharedInstance().sampleRate as AnyObject,
            AVEncoderBitRateKey : 128000 as AnyObject
        ]
        
        guard let audioRecorder = try? AVAudioRecorder(url: audioUrl, settings: audioOutputSettings) else { return }
        
        audioRecorder.delegate = self
        self.audioRecorder = audioRecorder
        
        audioRecorder.record()
    }
    
    func stopRecording(completion: (URL) -> ()) {
        if audioRecorder != nil {
            audioRecorder.stop()
            audioRecorder = nil
            completion(audioUrl)
        }
    }
}

extension AudioController: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        print("Did finish successfully \(flag)")
    }
}

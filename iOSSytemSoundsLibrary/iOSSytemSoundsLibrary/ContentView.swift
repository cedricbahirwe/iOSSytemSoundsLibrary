//
//  ContentView.swift
//  iOSSytemSoundsLibrary
//
//  Created by Cédric Bahirwe on 19/02/2021.
//

import SwiftUI
import AudioToolbox


struct ContentView: View {
    @State private var audioFileList: [NSURL] = []
    var body: some View {
        NavigationView {
            List(audioFileList.compactMap{ $0 }, id: \.self) { audioFile in
                if let title = audioFile.lastPathComponent {
                    Text(title)
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                        .padding(.vertical, 5)
                        .onTapGesture {
                            play(at: audioFile)
                        }
                }
            }
            .navigationBarTitle("\(audioFileList.count) System Sounds")
            .redacted(reason: audioFileList.count <= 0 ? .placeholder : [])
            .onAppear(perform: loadAudioFileList)
        }
        
    }
    
    
    /// Play a specified sound for a given url
    /// - Parameter url: the path of the sound to be played
    private func play(at url: NSURL) {
        var soundID = SystemSoundID();
        AudioServicesCreateSystemSoundID(url, &soundID)
        AudioServicesPlaySystemSound(soundID);
    }
    
    /// Fetch and Load audio file find in the specified directory
    private func loadAudioFileList() {
        let fileManager = FileManager.default
        if let enumerator:FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: "/System/Library/Audio/UISounds") {
            while let element = enumerator.nextObject() as? String {
                // Check if  element has caf (Core audio file) extension
                if element.hasSuffix("caf")  {
                    let prefix = "file:///System/Library/Audio/UISounds/"
                    let link = NSURL(string: "\(prefix+element)")!
                    audioFileList.append(link)
                }
            }
            // Since we are sure that every NSURl which is added to the list
            // should have a caf extension meaning that the "lastPathComponent"
            // of NSURl will not be "nil" so we're using force unwrap for sorting
            audioFileList.sort(by: { $0.lastPathComponent! < $1.lastPathComponent!})
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

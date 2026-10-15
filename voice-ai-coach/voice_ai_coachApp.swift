//
//  voice_ai_coachApp.swift
//  voice-ai-coach
//
//  Created by Marius Maricean on 13/10/2026.
//

import SwiftUI

@main
struct voice_ai_coachApp: App {
    @State private var voiceCoach = VoiceCoach()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(voiceCoach)
        }
    }
}

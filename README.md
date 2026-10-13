# Voice AI Coach

An iOS app for voice-based speaking practice.

## Getting started

Open `voice-ai-coach.xcodeproj` in Xcode and run the `voice-ai-coach` scheme.

The app requests microphone and speech recognition access when those features are
introduced. The usage descriptions are already included in the generated app
Info.plist settings.

## Local API credentials

Keep development credentials in `Config/Secrets.xcconfig`, which is ignored by
Git. Start from `Config/Secrets.xcconfig.example` and enter credentials only in
the local file. Never commit the local file or put a production provider secret
in a distributed app; production API calls should be made through a secured
backend.

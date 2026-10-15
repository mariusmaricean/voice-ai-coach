# Voice AI Coach

An iOS app for voice-based speaking practice. The first interaction slice uses
push-to-talk speech recognition, streamed coach replies, sentence-level speech,
and an interruptible conversation state machine.

## Getting started

Open `voice-ai-coach.xcodeproj` in Xcode and run the `voice-ai-coach` scheme.

The app requests microphone and speech recognition access when you start a
practice turn. The usage descriptions are included in the generated app
Info.plist settings.

## Local API credentials

Keep development configuration in `Config/Secrets.xcconfig`, which is ignored
by Git. Start from `Config/Secrets.xcconfig.example` and add the URL of your
coaching backend as `COACH_STREAM_URL`. Keep provider credentials on that
backend; never embed a provider key in a distributed app.

The app sends `POST` JSON shaped as `{"text":"..."}` to that URL and expects
Server-Sent Events. Each event should contain `data: {"delta":"spoken text"}`;
send `data: {"error":"message"}` for a user-safe error and finish with
`data: [DONE]`. The backend should authenticate users, enforce rate limits, and
keep provider secrets server-side.

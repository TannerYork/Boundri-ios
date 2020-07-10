//
//  SiriKit.swift
//  Boundri IOS
//
//  Created by Tanner York on 6/24/20.
//  Modified by Tasfia Addrita on 07/09/20
//  Copyright © 2020 Boundri. All rights reserved.
//

import Foundation

// user must be in app, siri will not be able to
// recognize boundri commands outside of app

// no way to change "Hey Siri" to "Hey Boundri"

// siri-kit vs audio vs speech recognition frameworks
// https://developer.apple.com/documentation/speech/recognizing_speech_in_live_audio

// ----- possible user journeys -----
// JOURNEY 1
// user opens app
//      -> user presses button to start listening/access microphone
//      OR
//      -> app automatically starts listening
// user asks question
//      -> app records question
//      -> filter out keywords from question
//      -> app takes picture
//      -> call vision api
//      -> match keywords with api response
//      -> use Siri to output response
// JOURNEY 2
// user asks "hey siri, take a picture"
// JOURNEY 3
// user asks to siri "boundri, what's in front of me?"
//      -> listens for "boundri" keyword and opens app
//      ISSUES: user still has to say "hey siri" to use it


// get user question
// "Siri, what are the appetizers?"
// "Siri, what's in front of me?"

// get picture
// for now: pass in an image
// stretch: take picture of menu

// process user question
    // pick out keywords
    // "appetizers"

    // pass keywords to vision api

// return answer to user question

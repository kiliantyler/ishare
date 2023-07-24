//
//  ScreenRecording.swift
//  ishare
//
//  Created by Adrian Castro on 24.07.23.
//

import Foundation
import AppKit
import Cocoa

enum RecordingType: String {
    case SCREEN = "-t"
    case WINDOW = "-wt"
    case REGION = "-st"
}

func recordScreen(type: RecordingType, display: Int = 1) -> Void {
    print("recording")
    AppDelegate.shared.toggleIcon(AppDelegate.shared as AnyObject)
}

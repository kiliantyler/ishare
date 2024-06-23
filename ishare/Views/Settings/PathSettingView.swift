//
//  PathSettingView.swift
//  ishare
//
//  Created by Kilian Tyler on 6/23/24.
//

import Foundation
import SwiftUI

struct PathSettingsView: View {
    @Binding var path: String
    var title: String

    @State private var showAlert = false
    @State private var tempPath = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
            HStack {
                TextField("Select a path", text: $tempPath, onCommit: validateAndSavePath)
                Button(action: {
                    selectFolder(startingAt: URL(fileURLWithPath: tempPath)) { folderURL in
                        if let url = folderURL {
                            path = ensureTrailingSlash(url.path)
                            tempPath = path
                            saveBookmark(for: path)
                        }
                    }
                }) {
                    Image(systemName: "folder.fill")
                }.help("Pick a folder")
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Permission Required"),
                message: Text("To access this directory, please confirm your selection."),
                primaryButton: .default(Text("Select")) {
                    confirmPathWithFolderSelector(startingAt: URL(fileURLWithPath: NSString(string: ensureTrailingSlash(tempPath)).expandingTildeInPath))
                },
                secondaryButton: .cancel {
                    tempPath = path
                }
            )
        }
        .onAppear {
            tempPath = path // Initialize tempPath with current path
            NotificationCenter.default.addObserver(forName: .staleBookmarkDetected, object: nil, queue: .main) { _ in
                showAlert = true
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: .staleBookmarkDetected, object: nil)
        }
    }

    private func validateAndSavePath() {
        let correctedValue = NSString(string: ensureTrailingSlash(tempPath)).expandingTildeInPath
        print("Directory: \(correctedValue)")
        if !FileManager.default.fileExists(atPath: correctedValue) || !checkAccess(for: correctedValue) {
            showAlert = true
        } else {
            path = correctedValue
            saveBookmark(for: correctedValue)
        }
    }

    private func confirmPathWithFolderSelector(startingAt directoryURL: URL? = nil) {
        selectFolder(startingAt: directoryURL) { folderURL in
            if let url = folderURL {
                path = ensureTrailingSlash(url.path)
                saveBookmark(for: path)
            } else {
                path = accessSavedDirectory() ?? ""
            }
        }
    }
}

extension Notification.Name {
    static let staleBookmarkDetected = Notification.Name("staleBookmarkDetected")
}

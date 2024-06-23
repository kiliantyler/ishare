//
//  BookmarkFolder.swift
//  ishare
//
//  Created by Kilian Tyler on 6/23/24.
//

import Foundation
import SwiftUI

func ensureTrailingSlash(_ path: String) -> String {
    return path.hasSuffix("/") ? path : path + "/"
}

func saveBookmark(for directory: String) {
    let directoryURL = URL(fileURLWithPath: ensureTrailingSlash(directory))
    do {
        let bookmarkData = try directoryURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        UserDefaults.standard.set(bookmarkData, forKey: "savedDirectoryBookmark")
    } catch {
        print("Failed to create bookmark: \(error)")
    }
}

func accessSavedDirectory() -> String? {
    guard let bookmarkData = UserDefaults.standard.data(forKey: "savedDirectoryBookmark") else {
        return nil
    }

    var isStale = false
    do {
        let directoryURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        if isStale {
            handleStaleBookmark()
        } else if directoryURL.startAccessingSecurityScopedResource() {
            return directoryURL.path
        } else {
            print("Failed to access security-scoped resource")
            return nil
        }
    } catch {
        print("Failed to resolve bookmark: \(error)")
        return nil
    }
    return nil
}

func stopAccessingSavedDirectory(directory: String) {
    let directoryURL = URL(fileURLWithPath: directory)
    directoryURL.stopAccessingSecurityScopedResource()
}

func bindingWithBookmark(_ binding: Binding<String>, showAlert: Binding<Bool>, tempPath: Binding<String>) -> Binding<String> {
    return Binding<String>(
        get: {
            return binding.wrappedValue
        },
        set: { newValue in
            let correctedValue = ensureTrailingSlash(newValue)
            binding.wrappedValue = correctedValue
            tempPath.wrappedValue = correctedValue
            
            if !FileManager.default.fileExists(atPath: correctedValue) || !checkAccess(for: correctedValue) {
                showAlert.wrappedValue = true
            } else {
                saveBookmark(for: correctedValue)
            }
        }
    )
}

func checkAccess(for path: String) -> Bool {
    let directoryURL = URL(fileURLWithPath: path)
    do {
        _ = try directoryURL.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        return true
    } catch {
        return false
    }
}

private func handleStaleBookmark() {
    NotificationCenter.default.post(name: .staleBookmarkDetected, object: nil)
}

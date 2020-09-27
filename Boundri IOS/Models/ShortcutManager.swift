//
//  ShortcutManager.swift
//  Boundri IOS
//
//  Created by Tanner York on 8/5/20.
//  Copyright © 2020 Boundri. All rights reserved.
//

import Intents
import IntentsUI

protocol ShortcutsManagerDelegate: AnyObject {
    func shortcutViewControllerDidCancel()
    func shortcutViewControllerDidFinish(with shortcut: ShortcutsManager.Shortcut)
    func shortcutViewControllerDidDeleteShortcut(_ shortcut: ShortcutsManager.Shortcut, identifier: UUID)
    func shortcutViewControllerFailed(with error: Error?)
}

class ShortcutsManager {
    enum Kind: String, Hashable, CaseIterable {
        case openReadText
        case openDescribeScene
        
        var intent: INIntent {
            let intent = intentType.init()
            intent.suggestedInvocationPhrase = suggestedInvocationPhrase
            return intent
        }
        
        var intentType: INIntent.Type {
            switch self {
            case .openReadText: return OpenReadTextCameraIntent.self
            case .openDescribeScene: return OpenDetectObjectCameraIntent.self
            }
        }
        
        var intentIcon: String {
            switch self {
            case .openReadText: return "doc.text"
            case .openDescribeScene: return "keyboard"
            }
        }
        
        var suggestedInvocationPhrase: String? {
            switch self {
            case .openReadText: return "Read Text"
            case .openDescribeScene: return "Describe Scene"
            }
        }
        
        var activityType: String? {
            switch self {
            case .openReadText: return "OpenReadTextCameraIntent"
            case .openDescribeScene: return "OpenDetectObjectCameraIntent"
            }
        }
        
        var gestureType: String? {
            switch self {
            case .openReadText: return "tap"
            case .openDescribeScene: return "swipe"
            }
        }
        
    }
    
    struct Shortcut: Hashable {
        var kind: Kind
        var intent: INIntent
        var voiceShortcut: INVoiceShortcut?
        
        var invocationPhrase: String? {
            voiceShortcut?.invocationPhrase
        }
    }
    
    private init() { }
    static let shared = ShortcutsManager()
    
    // MARK: - Shortcuts View Controller
    
    private var delegates = [String: DelegateProxy]()
    
    /// Shows either a `INUIAddVoiceShortcutViewController` or `INUIEditVoiceShortcutViewController` based on whether the user has already added the shortcut to Siri
    public func showShortcutsPhraseViewController(for shortcut: Shortcut, on viewController: UIViewController, delegate: ShortcutsManagerDelegate) {
        let delegateProxy = DelegateProxy(shortcut: shortcut, delegate: delegate) { [weak self] in
            self?.delegates[shortcut.kind.rawValue] = nil
        }
        delegates[shortcut.kind.rawValue] = delegateProxy
        
        if let voiceShortcut = shortcut.voiceShortcut {
            let editController = INUIEditVoiceShortcutViewController(voiceShortcut: voiceShortcut)
            editController.delegate = delegateProxy
            viewController.present(editController, animated: true)
        } else {
            guard let shortcut = INShortcut(intent: shortcut.kind.intent) else { return }
            let addController = INUIAddVoiceShortcutViewController(shortcut: shortcut)
            addController.delegate = delegateProxy
            viewController.present(addController, animated: true)
        }
    }
    
    // MARK: - Loading Shortcuts
    
    /// Checks whether the `INVoiceShortcut`'s intent is the same type as an intent type
    private func isVoiceShortcut<IntentType>(_ voiceShortcut: INVoiceShortcut, intentOfType type: IntentType.Type) -> Bool where IntentType: INIntent {
        voiceShortcut.shortcut.intent?.isKind(of: type) ?? false
    }
    
    /// Creates an array of `Shortcut` objects, which may contain a voice shortcut if they have been added to Siri
    func loadShortcuts(kinds: [Kind], completion: @escaping ([Shortcut]) -> Void) {
        INVoiceShortcutCenter.shared.getAllVoiceShortcuts { [weak self] voiceShortcuts, error in
            guard let self = self, let voiceShortcuts = voiceShortcuts, error == nil else {
                completion(kinds.map { Shortcut(kind: $0, intent: $0.intent) })
                return
            }
            
            var shortcuts = [Shortcut]()
            for kind in kinds {
                let filteredVoiceShortcuts = voiceShortcuts.filter({ self.isVoiceShortcut($0, intentOfType: kind.intentType) })
                
                guard !filteredVoiceShortcuts.isEmpty else {
                    let shortcut = Shortcut(kind: kind, intent: kind.intent)
                    shortcuts.append(shortcut)
                    continue
                }
                
                for voiceShortcut in filteredVoiceShortcuts {
                    let shortcut = Shortcut(kind: kind, intent: kind.intent, voiceShortcut: voiceShortcut)
                    shortcuts.append(shortcut)
                }
            }
            
            completion(shortcuts)
        }
    }
    
    // MARK: - Delegate Proxy
    
    private class DelegateProxy: NSObject, INUIAddVoiceShortcutViewControllerDelegate, INUIEditVoiceShortcutViewControllerDelegate {
        
        var shortcut: Shortcut
        weak var delegate: ShortcutsManagerDelegate?
        var completion: () -> Void
        
        init(shortcut: Shortcut, delegate: ShortcutsManagerDelegate, completion: @escaping () -> Void) {
            self.shortcut = shortcut
            self.delegate = delegate
            self.completion = completion
        }
        
        // MARK: - INUIAddVoiceShortcutViewControllerDelegate
        
        func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
            controller.dismiss(animated: true)
            delegate?.shortcutViewControllerDidCancel()
            completion()
        }
        
        func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
            defer { completion() }
            controller.dismiss(animated: true)
            
            guard let voiceShortcut = voiceShortcut else {
                delegate?.shortcutViewControllerFailed(with: error)
                return
            }
            
            shortcut.voiceShortcut = voiceShortcut
            delegate?.shortcutViewControllerDidFinish(with: shortcut)
        }
        
        // MARK: - INUIEditVoiceShortcutViewControllerDelegate
        
        func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
            controller.dismiss(animated: true)
            delegate?.shortcutViewControllerDidCancel()
            completion()
        }
        
        func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
            defer { completion() }
            controller.dismiss(animated: true)
            
            guard let voiceShortcut = voiceShortcut else {
                delegate?.shortcutViewControllerFailed(with: error)
                return
            }
            
            shortcut.voiceShortcut = voiceShortcut
            delegate?.shortcutViewControllerDidFinish(with: shortcut)
        }
        
        func editVoiceShortcutViewController( _ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
            controller.dismiss(animated: true)
            delegate?.shortcutViewControllerDidDeleteShortcut(shortcut, identifier: deletedVoiceShortcutIdentifier)
            completion()
        }
    }
}

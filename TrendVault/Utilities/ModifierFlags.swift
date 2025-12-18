//
//  ModifierFlags.swift
//  TrendVault
//
//  Created by Christian Ruppelt on 18.12.25.
//

import AppKit

enum ModifierFlags {
    static func current() -> NSEvent.ModifierFlags {
        NSEvent.modifierFlags
    }
}

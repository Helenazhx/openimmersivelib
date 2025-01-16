//
//  Config.swift
//  OpenImmersive
//
//  Created by Anthony Maës on 1/16/25.
//

import Foundation
import SwiftUI

/// Fetches custom values in the application's openimmersive.plist
public class Config {
    /// Tint for the scrubber (String): RGB or RGBA color in hexadecimal in the #RRGGBB or #RRGGBBAA format.
    public var scrubberTint: Color = .orange.opacity(0.7)
    
    /// Shared config object with values that can be overridden by the app.
    @MainActor
    public static var shared: Config = Config()
    
    /// Private initializer, parses openimmersive.plist in the enclosing app bundle.
    private init() {
        guard let url = Bundle.main.url(forResource: "openimmersive", withExtension: "plist") else {
            print("OpenImmersive loaded with default configuration")
            return
        }
        guard let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
              let config = plist as? [String: Any] else {
            print("OpenImmersive could not parse the configuration file, loaded with default configuration")
            return
        }
        
        if let scrubberTintValue = config["scrubberTint"] as? String,
           let color = color(from: scrubberTintValue) {
            scrubberTint = color
        }
        print("OpenImmersive loaded with custom configuration")
    }
    
    /// Parses a string hexadecimal representation and returns the corresponding Color.
    /// - Parameters:
    ///   - colorString: text to be parsed, expected to be a hex color literal in the #RRGGBB or #RRGGBBAA format.
    /// - Returns: the corresponding Color, if the string is well formatted, otherwise nil.
    private func color(from colorString: String) -> Color? {
        let trimmedString = colorString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let colorSearch = /#(?<red>[0-9A-F]{2})(?<green>[0-9A-F]{2})(?<blue>[0-9A-F]{2})(?<alpha>[0-9A-F]{2})?/
        
        guard let color = try? colorSearch.firstMatch(in: trimmedString),
              let red256 = Int(color.red, radix: 16),
              let green256 = Int(color.green, radix: 16),
              let blue256 = Int(color.blue, radix: 16) else {
            print("OpenImmersive could not parse the color: \(colorString). Accepted formats: #RRGGBB or #RRGGBBAA")
            return nil
        }
        
        let red = Double(red256) / 255.0
        let green = Double(green256) / 255.0
        let blue = Double(blue256) / 255.0
        var alpha = 1.0
        if let alphaHex = color.alpha,
           let alpha256 = Int(alphaHex, radix: 16) {
            alpha = Double(alpha256) / 255.0
        }

        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}

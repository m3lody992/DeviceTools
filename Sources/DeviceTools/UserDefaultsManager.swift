//
//  UserDefaultsManager.swift
//
//
//  Created by Melody Polenta on 15/01/2022.
//  Copyright © 2022 Melody Polenta All rights reserved.
//

import Foundation

public class UserDefaultsManager {

    // MARK: - Standard UserDefaults

    private static let userDefaults: UserDefaults = .standard

    private static var supportedTypes: [Any.Type] = [
        URL?.self, String?.self, Data?.self, Bool?.self, Int?.self, Int8?.self, Int16?.self, Int32?.self, Int64?.self,
        UInt?.self, UInt8?.self, UInt16?.self, UInt32?.self, UInt64?.self, Float?.self, Float32?.self, Float64?.self,
        Double?.self, URL.self, String.self, Data.self, Bool.self, Int.self, Int8.self, Int16.self, Int32.self,
        Int64.self, UInt.self, UInt8.self, UInt16.self, UInt32.self, UInt64.self, Float.self, Float32.self,
        Float64.self, Double.self]

    private static func isSupported<T>(type: T.Type) -> Bool {
        supportedTypes.contains { $0 == type }
    }

    // MARK: - User Defaults Interface

    public static func set<T: Codable>(_ value: T?, forKey key: String) {
        isSupported(type: T.self) ? userDefaults.set(value, forKey: key) : storeObject(value, forKey: key)
    }

    public static func object<T>(forKey key: String) -> T? where T: Any, T: Codable {
        if isSupported(type: T.self) {
            switch T.self {
            case is Bool.Type: return userDefaults.bool(forKey: key) as? T
            case is Int.Type: return userDefaults.integer(forKey: key) as? T
            case is Float.Type: return userDefaults.float(forKey: key) as? T
            case is Double.Type: return userDefaults.double(forKey: key) as? T
            case is String.Type: return userDefaults.string(forKey: key) as? T
            default:
                return userDefaults.object(forKey: key) as? T
            }
        } else {
            return getObject(forKey: key)
        }
    }

    // MARK: - Key check

    public static func valueExists(forKey key: String) -> Bool {
        userDefaults.object(forKey: key) != nil
    }

    // MARK: - Deleting

    public static func deleteValue(forKey key: String) {
        userDefaults.set(nil, forKey: key)
    }

    // MARK: - Wipe

    /// removes all data stored in the standard user defaults
    public static func wipeStandardUserDefaults() {
        guard let domain = Bundle.main.bundleIdentifier else { return }
        userDefaults.removePersistentDomain(forName: domain)
        userDefaults.synchronize()
    }

    // MARK: - Codable Objects (Private)

    private static func storeObject<T: Codable>(_ object: T?, forKey key: String) {
        guard let data = try? JSONEncoder().encode(object) else { return }
        return userDefaults.set(data, forKey: key)
    }

    private static func getObject<T: Codable>(forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

}

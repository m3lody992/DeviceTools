//
//  Keychain
//
//  Created by Eric Cartmenez on 06/12/2021.
//  Copyright © 2021 Eric Cartmenez. All rights reserved.
//

import Foundation
import KeychainAccess

// Used becasue encoding primitives on <iOS13 results in an error.
public struct KeychainValueWrapper<T: Codable>: Codable {
    public let value: T
}

public struct KeychainManager {

    private static let shared = KeychainManager()
    private let keychain = Keychain(service: DeviceTools.appName + "Keychain") // "Keychain" 

    public static func value<T: Codable>(for key: String) -> T? {
		let name = key

		switch T.self {
        case is String.Type:
            return shared.keychain[string: name] as? T
		case is Data.Type:
			return shared.keychain[data: name] as? T
		case is UUID.Type:
			guard let uuidString = shared.keychain[string: name]
			else {
				return nil
			}

			return UUID(uuidString: uuidString) as? T
		default:
			guard let data = shared.keychain[data: name]
			else {
				return nil
			}

			do {
				return try JSONDecoder().decode(KeychainValueWrapper<T>.self, from: data).value
			}
			catch {
				print("\(String(describing: T.self)) \(error)")
			}
		}

		return nil
	}

    public static func set<T: Codable>(value: T, for key: String) {
		if let value = value as? Data {
            shared.keychain[data: key] = value
		}
		else if let value = value as? String {
			shared.keychain[string: key] = value
		}
		else if let value = value as? UUID {
			shared.keychain[string: key] = value.uuidString
		}
		else {
			do {
				let data = try JSONEncoder().encode(KeychainValueWrapper(value: value))
				shared.keychain[data: key] = data
			}
			catch {
				print("\(String(describing: type(of: value))) \(error)")
			}
		}
	}

    public static func remove(key: String) {
		shared.keychain[key] = nil
	}

}


//
//  File.swift
//  
//
//  Created by Eric Cartmenez on 16/03/2022.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        index >= startIndex && index < endIndex ? self[index] : nil
    }

}


public struct Device {

    public static var id: String {
        guard let deviceID: String = UserDefaultsManager.object(forKey: DeviceTools.idKey) else {
            let uuidString = UUID().uuidString
            UserDefaultsManager.set(uuidString, forKey: DeviceTools.idKey)
            return uuidString
        }
        return deviceID
    }

    public static func resetDeviceID() {
        UserDefaultsManager.deleteValue(forKey: DeviceTools.idKey)
    }

    public static var wasTampered: Bool {
        KeychainManager.value(for: DeviceTools.tamperedKey) ?? false
    }

    public static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    public static var hardwareModelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    public static var isOld: Bool = {
        if hardwareModelName.contains("iPhone"), // "iPhone"
           let firstNumberString = hardwareModelName.compactMap({ String($0) })[safe: 6],
           let firstNumber = Int(firstNumberString),
           (3...8).contains(firstNumber) {
            return true
        } else if hardwareModelName.contains("iPad"), // "iPad"
                  let firstNumberString = hardwareModelName.compactMap({ String($0) })[safe: 4],
                  let firstNumber = Int(firstNumberString),
                  (2...5).contains(firstNumber) {
            return true
        } else if hardwareModelName.contains("iPod") { // "iPod"
            return true
        } else {
            return false
        }
    }()

    // isJailbroken
    public static var hasKorenina: Bool {

        #if arch(i386) || arch(x86_64)
        // This is a Simulator not an idevice
        return false
        #endif

        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: "/Applications/Cydia.app") || // "/Applications/Cydia.app"
            fileManager.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") || // "/Library/MobileSubstrate/MobileSubstrate.dylib"
            fileManager.fileExists(atPath: "/bin/bash") || // "/bin/bash"
            fileManager.fileExists(atPath: "/usr/sbin/sshd") || // "/usr/sbin/sshd"
            fileManager.fileExists(atPath: "/etc/apt") || // "/etc/apt"
            fileManager.fileExists(atPath: "/usr/bin/ssh") || // "/usr/bin/ssh"
            fileManager.fileExists(atPath: "/private/var/lib/apt") { // "/private/var/lib/apt"
            return true
        }

        if canOpen(path: "/Applications/Cydia.app") || // "/Applications/Cydia.app"
            canOpen(path: "/Library/MobileSubstrate/MobileSubstrate.dylib") || // "/Library/MobileSubstrate/MobileSubstrate.dylib"
            canOpen(path: "/bin/bash") || // "/bin/bash"
            canOpen(path: "/usr/sbin/sshd") || // "/usr/sbin/sshd"
            canOpen(path: "/etc/apt") || // "/etc/apt"
            canOpen(path: "/usr/bin/ssh"){ // "/usr/bin/ssh"
            return true
        }

        let path = "/private/" + NSUUID().uuidString // "/private/"
        do {
            try "anyString".write(toFile: path, atomically: true, encoding: String.Encoding.utf8) // "anyString"
            try fileManager.removeItem(atPath: path)
            return true
        } catch {
            return false
        }
    }

    // isDebuggerAttached
    public static var hasRazhroscevalnik: Bool {
        var entomoIsAttached = false

        var name: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var info: kinfo_proc = kinfo_proc()
        var infoSize = MemoryLayout<kinfo_proc>.size

        let success = name.withUnsafeMutableBytes { (nameBytePtr: UnsafeMutableRawBufferPointer) -> Bool in
            guard let nameBytesBlindMemory = nameBytePtr.bindMemory(to: Int32.self).baseAddress else { return false }
            return -1 != sysctl(nameBytesBlindMemory, 4, &info, &infoSize, nil, 0)
        }

        if !success {
            entomoIsAttached = false
        }

        if !entomoIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0 {
            entomoIsAttached = true
        }

        return entomoIsAttached
    }

    public static func canOpen(path: String) -> Bool {
        let file = fopen(path, "r") // "r"
        guard file != nil else { return false }
        fclose(file)
        return true
    }

}

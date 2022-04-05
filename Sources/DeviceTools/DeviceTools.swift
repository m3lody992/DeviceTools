//
//  File.swift
//  
//
//  Created by Melody Polenta on 18/03/2022.
//

import Foundation

public struct DeviceTools {
    
    internal static var shared = DeviceTools()
    
    internal var appName: String!
    internal static var appName: String {
        shared.appName
    }
    
    internal var tamperedKey: String!
    internal static var tamperedKey: String {
        shared.tamperedKey
    }
    
    internal var idKey: String!
    internal static var idKey: String {
        shared.idKey
    }

    public static func configure(appName: String, tamperedKey: String, idKey: String) {
        shared.appName = appName
        shared.tamperedKey = tamperedKey
        shared.idKey = idKey
    }
    
}

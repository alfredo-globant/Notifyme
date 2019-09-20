//
//  PayloadDecoder.swift
//  Notifications
//
//  Created by Ben RIAZY on 07/03/2018.
//  Copyright © 2018 HSBC. All rights reserved.
//

import Foundation

/**
 The type that will define the Schema to enable the Framework to internally parse and check wether the incoming payload is meant for which specific feature
 
 ## Usage:
 
 Define the type inside an extension where the feature receiver conforms to the PayloadDecoder type, this will take care of parsing automatically
 
 ```
 extension MobileChatReceiver: PayloadDecoder {
 typealias PayloadType = MobileChatMessage
 var decodableType: MobileChatMessage.Type = MobileChatMessage.self
 }
 ```
 
 */
public protocol PayloadDecoder {
    associatedtype PayloadType: Decodable
    
    var decodableType: PayloadType.Type { get }
}

public extension NotificationReceivable where Self: PayloadDecoder {
    
    func decode(_ userInfo: [AnyHashable: Any]) -> Decodable? {
        guard let data = try? JSONSerialization.data(withJSONObject: userInfo, options: []) else { return nil }
        return try? JSONDecoder().decode(decodableType, from: data)
    }
    
}

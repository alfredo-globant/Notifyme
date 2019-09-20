//
//  CodiNotification.swift
//  NotificationsExample
//
//  Created by Jesus2 HERNANDEZ on 9/20/19.
//  Copyright © 2019 Jesus2 HERNANDEZ. All rights reserved.
//

import Foundation

struct CodiNotification: Codable {
    var serial: Int
    var messageCrypt: String
    var messageID: String
    
    enum CodingKeys: String, CodingKey {
        case serial = "s"
        case messageCrypt = "mc"
        case messageID = "id"
    }
    
    init() {
        serial = 0
        messageCrypt = ""
        messageID = ""
    }
}

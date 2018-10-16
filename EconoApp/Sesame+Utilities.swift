//
//  Sesame+Extensions.swift
//  Depressed?
//
//  Created by Akash Desai on 10/11/18.
//  Copyright © 2018 Christian Lobach. All rights reserved.
//

import Foundation

struct SesameProperties {
    static let file: SesameProperties = {
        guard let path = Bundle.main.path(forResource: "Sesame", ofType: "plist"),
            let plist = NSDictionary(contentsOfFile: path) as? [String: Any],
            let sesameProperties = SesameProperties(dict: plist)
            else { fatalError() }
        return sesameProperties
    }()

    let appId: String
    let auth: String
    let versionId: String
    let userId: String

    init?(dict: [String: Any]) {
        guard let appId = dict["appId"] as? String, !appId.isEmpty,
            let auth = dict["auth"] as? String, !auth.isEmpty,
            let versionId = dict["versionId"] as? String, !versionId.isEmpty,
            let userId = dict["userId"] as? String, !userId.isEmpty
            else { return nil }
        self.appId = appId
        self.auth = auth
        self.versionId = versionId
        self.userId = userId
    }
}

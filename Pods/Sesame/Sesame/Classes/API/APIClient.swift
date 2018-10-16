//
//  SesameConfig.swift
//  Sesame
//
//  Created by Akash Desai on 7/23/18.
//

import UIKit

class APIClient: HTTPClient {

    enum Endpoint {
        case boot, reinforce

        var url: URL {
            switch self {
            case .boot:
//                return URL(string: "https://reinforce.boundless.ai/v6/app/boot")!
                return URL(string: "https://reinforcement.boundless.ai/v1/boot")!
//                return URL(string: "http://192.168.1.12:8080/v1/boot")!
            case .reinforce:
//                return URL(string: "https://reinforce.boundless.ai/v6/app/report")!
                return URL(string: "https://reinforcement.boundless.ai/v1/reinforce")!
//                return URL(string: "http://192.168.1.12:8080/v1/reinforce")!
            }
        }
    }

    func post(endpoint: Endpoint, auth: AuthorizationHeader, jsonBody: [String: Any], timeout: TimeInterval = 3.0, completion: @escaping ([String: Any]?) -> Void) {
        post(url: endpoint.url, auth: auth, jsonBody: jsonBody, timeout: timeout, completion: completion)
    }

    func createPayload(appId: String, versionId: String?, revision: Int, primaryIdentity: String? = nil) -> [String: Any] {
        var payload: [String: Any] =
            ["appId": appId,
             "appVersionId": versionId ?? "nil",
             "revision": revision,
             "device": ["osName": "iOS",
                        "osVersion": UIDevice.current.systemVersion,
                        "buildVersion": Bundle.main.shortVersionString ?? "UNKNOWN",
                        "clientVersion": Bundle(for: APIClient.self).shortVersionString ?? "UNKNOWN"],
             "utc": NSNumber(value: Int64(Date().timeIntervalSince1970) * 1000),
             "timezoneOffset": NSNumber(value: Int64(NSTimeZone.default.secondsFromGMT()) * 1000)
        ]
        if let externalId = primaryIdentity {
            payload["externalId"] = externalId
        }
        return payload
    }

}

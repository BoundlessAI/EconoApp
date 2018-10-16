//
//  HTTPClient.swift
//  Sesame
//
//  Created by Akash Desai on 2/21/18.
//

import Foundation

class HTTPClient: NSObject {

    private let session = URLSession.shared

    func post(url: URL, auth: AuthorizationHeader, jsonBody: [String: Any], timeout: TimeInterval = 3.0, completion: @escaping ([String: Any]?) -> Void) {

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(auth.type) \(auth.credentials)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.timeoutInterval = timeout
        do {
            let httpBody = try JSONSerialization.data(withJSONObject: jsonBody)
            request.httpBody = httpBody
            BMSLog.info("Sending request to <\(url.absoluteString)>")
            if BMSLog.level == .verbose {
                BMSLog.verbose("with payload:\n<\(String(data: httpBody, encoding: .utf8) as AnyObject)>...")
            }
        } catch {
            BMSLog.error("Canceled request to \(url.absoluteString) for non-JSON request <\(jsonBody as AnyObject)>")
        }
        session.dataTask(with: request) { responseData, responseURL, error in
            BMSLog.info("Received response from <\(request.url?.absoluteString ?? "url:nil")>")
            if BMSLog.level == .verbose {
                if let responseData = responseData {
                    BMSLog.verbose("with response body <\(String(data: responseData, encoding: .utf8) ?? "nil")>")
                } else {
                    BMSLog.verbose("Received no response data from <\(request.url?.absoluteString ?? "url:nil")>")
                }
            }
            let response = self.convertResponseToJSON(url, responseData, responseURL, error)
            completion(response)
        }.resume()
    }

    fileprivate func convertResponseToJSON(_ url: URL, _ responseData: Data?, _ responseURL: URLResponse?, _ error: Error?) -> [String: Any]? {
        guard responseURL != nil else {
            BMSLog.error("\(url.absoluteString) call got invalid response with error:<\(error as AnyObject)>")
            return nil
        }

        guard let response = responseData else {
            BMSLog.verbose("\(url.absoluteString) call got no response data")
            return nil
        }

        if response.isEmpty {
            BMSLog.verbose("\(url.absoluteString) called and got empty response")
            return nil
        } else if let jsonResponse = try? JSONSerialization.jsonObject(with: response) as? [String: AnyObject] {
            BMSLog.verbose("\(url.absoluteString) call got json response")
            return jsonResponse
        } else {
            let dataString = responseData.flatMap({ NSString(data: $0, encoding: String.Encoding.utf8.rawValue) }) ?? ""
            BMSLog.error("\(url.absoluteString) call got invalid response\n\t<\(dataString)>")
            return nil
        }
    }
}

extension HTTPClient {
    struct AuthorizationHeader {
        let type: String
        let credentials: String

        static func basic(_ username: String, _ password: String) -> AuthorizationHeader {
            return AuthorizationHeader(type: "Basic",
                                       credentials: "\(username):\(password)".toBase64())
        }
    }
}

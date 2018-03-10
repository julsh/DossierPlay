//
//  PersistenceService.swift
//  DossierPlay
//
//  Created by Julia Roggatz on 10.03.18.
//  Copyright © 2018 Julia Roggatz. All rights reserved.
//

import Foundation
import SwiftyDropbox

public class PersistenceService {

    public var isAuthorized: Bool {
        return DropboxClientsManager.authorizedClient != nil
    }

    public func authorize(from viewController: UIViewController) {
        DropboxClientsManager.authorizeFromController(
            UIApplication.shared,
            controller: viewController,
            openURL: { (url: URL) -> Void in
                UIApplication.shared.openURL(url)
        })
    }

    public func saveModels() {
        guard let client = DropboxClientsManager.authorizedClient else {
            return
        }
        let fileData = "testing data example".data(using: String.Encoding.utf8, allowLossyConversion: false)!
        client.files.upload(path: "/testData", input: fileData)
            .response { response, error in
                if let response = response {
                    print(response)
                } else if let error = error {
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
        }
    }

}

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

    public func saveModels(_ models: [SquareModel]) {
        guard let client = DropboxClientsManager.authorizedClient else {
            return
        }

        let modelDicts = models.map { $0.toDict }
        do {
            print(modelDicts)
           let jsonData = try JSONSerialization.data(withJSONObject: modelDicts, options: .prettyPrinted)
            client.files.upload(path: "/squares.json", input: jsonData)
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
            let jsonString = String(data: jsonData, encoding: String.Encoding.utf8)
            print(jsonString)
            print("json: \(jsonData)")
        } catch {
            print("error")
        }
    }

}

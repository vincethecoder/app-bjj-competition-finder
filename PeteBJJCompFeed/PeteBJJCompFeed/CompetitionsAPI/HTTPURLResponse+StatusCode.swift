//
//  HTTPURLResponse+StatusCode.swift
//  PeteBJJCompFeed
//
//  Created by Kobe Sam on 11/20/24.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }

    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
}

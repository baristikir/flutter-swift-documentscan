//
//  SecureStoreActionsEnum.swift
//  Runner
//
//  Created by Baris Tikir on 11.04.21.
//

import Foundation

enum SecureStoreActions: String {
    case getFromSecureKeychain = "getSecureKeychainValue"
    case setToSecureKeychain = "setSecureKeychainValue"
    case removeFromSecureKeychain = "removeSecureKeychainValue"
}

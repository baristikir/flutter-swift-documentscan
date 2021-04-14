//
//  SecureStore.swift
//  Runner
//
//  Created by Baris Tikir on 11.04.21.
//

import Foundation
import Security

enum SecureStoreError: Error {
    case invalidContent
    case failure(OSStatus)
}

class SecureStore {
    private func setupQueryDictionary(forKey key: String) throws -> [CFString: Any] {
        guard let keyData = key.data(using: .utf8) else {
            print("Data could not be converted to the expected format")
            throw SecureStoreError.invalidContent
        }
        
        let queryDictionary: [CFString: Any] = [kSecClass: kSecClassGenericPassword, kSecAttrAccount: keyData]
        
        return queryDictionary
    }
    
    func set(entry: String, forKey key: String) throws {
        guard !entry.isEmpty && !key.isEmpty else {
            print("Can't add an empty string to the keychain!")
            throw SecureStoreError.invalidContent
        }
        
        try removeEntry(forkey: key)
        
        var queryDictionary = try setupQueryDictionary(forKey: key)
        queryDictionary[kSecValueData] = entry.data(using: .utf8)
        
        let status = SecItemAdd(queryDictionary as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw SecureStoreError.failure(status)
        }
    }
    
    func entry(forKey key: String) throws -> String? {
        guard !key.isEmpty else {
            print("Key must be valid")
            throw SecureStoreError.invalidContent
        }
        
        var queryDictionary = try setupQueryDictionary(forKey: key)
        queryDictionary[kSecReturnData] = kCFBooleanTrue
        queryDictionary[kSecMatchLimit] = kSecMatchLimitOne
        
        var data: AnyObject?
        
        let status = SecItemCopyMatching(queryDictionary as CFDictionary, &data)
        guard status == errSecSuccess else {
            throw SecureStoreError.failure(status)
        }
        
        guard let itemData = data as? Data,
              let result = String(data: itemData, encoding: .utf8) else {
            return nil
        }
        
        return result
    }
    
    func removeEntry(forkey key: String) throws {
        guard !key.isEmpty else {
            print("Key must be valid")
            throw SecureStoreError.invalidContent
        }
        
        let queryDictionary = try setupQueryDictionary(forKey: key)
        
        SecItemDelete(queryDictionary as CFDictionary)
    }
}

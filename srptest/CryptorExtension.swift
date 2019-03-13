//
//  CryptorExtension.swift
//  srptest
//
//  Created by 小福 on 2019/1/8.
//  Copyright © 2019 小福. All rights reserved.
//

import Foundation
import Cryptor

extension Digest {
    static func hasher(_ algorithm: Algorithm) -> (Data) -> Data {
        return { data in
            let digest = Digest(using: algorithm)
            _ = digest.update(data: data)
            return Data(bytes: digest.final())
        }
    }
    
    static func hasherArray(_ algorithm: Algorithm) -> ([UInt8]) -> Data {
        return { byteArray in
            let digest = Digest(using: algorithm)
            _ = digest.update(byteArray: byteArray)
            return Data(bytes: digest.final())
        }
    }
    
}

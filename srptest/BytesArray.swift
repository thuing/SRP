//
//  BytesArray.swift
//  srptest
//
//  Created by 小福 on 2019/3/12.
//  Copyright © 2019 小福. All rights reserved.
//

import Foundation
import BigInt

extension BigUInt {
    
//    public func makeBytes() -> [Int8] {
//        var bytes: [Int8] = []
//        for w in self.words {
//            let wordBytes = w.makeBytes()
//            for i in (0..<wordBytes.count).reversed() {
//                bytes.insert(wordBytes[i], at: 0)
//            }
//        }
//        return bytes
//    }
//    
    public init(bytes: [Int8]) {
        var bytes = bytes
        var words: [Word] = []
        let wordSize = MemoryLayout<Word>.size
        let paddingNeeded = (wordSize - (bytes.count % wordSize)) % wordSize
        for _ in 0..<paddingNeeded {
            bytes.insert(0x00, at: 0)
        }

        for i in Swift.stride(from: 0, to: bytes.count, by: wordSize) {
            
            //let word = BigUInt.init(bytes: Array(bytes[i..<(i + wordSize)]))
            
            let word = BigUInt.Word(bitPattern: Array(bytes[i..<(i + wordSize)]))
            //let word = BigUInt.Word(bytes: Array(bytes[i..<(i + wordSize)]))
            words.insert(word, at: 0)
        }

        self.init(words: words)
    }
}



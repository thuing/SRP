//
//  bigint.swift
//  srptest
//
//  Created by 小福 on 2019/3/15.
//  Copyright © 2019 小福. All rights reserved.
//

import BigInt

extension BigInt {
    
    public func serialize() -> Data {
        var array = Array(BigUInt.init(self.magnitude).serialize())
        
        if array.count > 0 {
            if self.sign == BigInt.Sign.plus {
                if array[0] >= 128 {
                    array.insert(0, at: 0)
                }
            } else if self.sign == BigInt.Sign.minus {
                if array[0] <= 127 {
                    array.insert(255, at: 0)
                }
            }
        }
        
        return Data.init(bytes: array)
    }
    
    public init(_ data: Data) {
        var dataArray = Array(data)
        var sign: BigInt.Sign = BigInt.Sign.plus
        var magnitude :BigUInt = 0
        
        if dataArray.count > 0 {
            if dataArray[0] >= 128 {
                sign = BigInt.Sign.minus
                magnitude = BigUInt.init(Data.init(bytes: dataArray))
                let flag :BigUInt = BigUInt(BigUInt(2) << BigUInt((data.count * 8) - 1))
                magnitude = flag - magnitude
                if dataArray.count > 1 {
                    if dataArray[0] == 255, dataArray.count > 1 {
                        dataArray.remove(at: 0)
                    }
//                    } else {
//                        dataArray[0] = UInt8(256 - Int(dataArray[0]))
//                        print("dataA",dataArray[0])
//                    }
                }
            }else{
                magnitude = BigUInt.init(Data.init(bytes: dataArray))
            }
        }
//        print("dataAA",dataArray[0],dataArray[1])
//        var magnitude = BigUInt.init(Data.init(bytes: dataArray))
//        let flag :BigUInt = BigUInt(2 << ((data.count * 8) - 1))
//        magnitude = flag - magnitude
//        self .init(sign: sign, magnitude: magnitude)
        self .init(sign: sign, magnitude: magnitude)
}
}

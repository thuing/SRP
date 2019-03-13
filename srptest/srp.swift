//
//  srp.swift
//  srptest
//
//  Created by 小福 on 2019/1/7.
//  Copyright © 2019 小福. All rights reserved.
//

import Foundation
import BigInt
import Cryptor
import Alamofire
import SwiftyJSON

public class srpClient {
    

    
    func stringToArray(input:String) -> Array<Any> {
        return  input.map { String($0) }
    }
    
    let TABLE:Array<Any> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", ".", "/"]
    
    // 整数转字节数组
    func intToByte(int:Int)-> UInt8 {
        return [UInt8](String(int).data(using: .utf8)!)[0]
    }
    
    
    
    enum Error01:Error{
        case Error01NoFile
        case Error01NoContent
        case Error01ContentNotAvailable
    }
    
    
    // 无符号右移>>>
    func relizeRight(value:Int, bit: Int) -> Int {
        //将十进制转为二进制
        var caculate = String.init(value, radix:2)
        
        if caculate.first == "-" {
            let index = caculate.index(caculate.startIndex, offsetBy:1)
            caculate = String(caculate[index...])
            // caculate = caculate.substring(from: index)
        }
        
        
        for _ in 0..<8-caculate.count {
            caculate = "0" + caculate
        }
        
        //如果是负数位移那么要对二进制数取反然后+1
        if value < 0 {
            let becomeTwo = caculate.replacingOccurrences(of:"1", with: "2")
            let becomeOne = becomeTwo.replacingOccurrences(of:"0", with: "1")
            caculate = becomeOne.replacingOccurrences(of:"2", with: "0")
            if caculate.last == "0" {
                let index = caculate.index(caculate.startIndex, offsetBy: caculate.count - 1)
                caculate = String(caculate[..<index]) + "1"
            }else{
                let index = caculate.index(caculate.startIndex, offsetBy: caculate.count - 2)
                caculate = String(caculate[..<index]) + "10"
            }
            
        }
        for _ in 0..<bit {
            caculate = "0" + caculate
            
        }
        let index = caculate.index(caculate.startIndex, offsetBy:8)
        caculate = String(caculate[..<index])
        let myResult = Int32.init(caculate, radix:2)
        return Int(myResult ?? 0)
    }
    
    func fromb64(var0:String) throws -> [Int8] {
        let var0Array = stringToArray(input: var0)
        let var1 = var0.count
        var var2 = [Int8](repeating: 0, count: var1 + 1) //= new byte[var1 + 1]
        var var4:Int = 0
        var var5:Int = 0
        if (var1 == 0) {
            throw Error01.Error01NoFile
        } else {
            for var4 in var4..<var1 {
                let var3 :String = var0Array[var4] as! String
                
                while var3 != TABLE[var5] as! String {
                    var5 = var5 + 1
                }
                var2[var4] = Int8(var5)
                var5 = 0
            }
            
            var4 = var1 - 1
            var5 = var1
            
            repeat {
                var2[var5] = var2[var4]
                var4 = var4 - 1
                if (var4 < 0) {
                    break
                }
                
                var2[var5] = Int8((var2[var5]  | (var2[var4] & 3) << 6))
                var5 = var5 - 1
                var2[var5] = Int8(relizeRight(value: (Int)(var2[var4] & 60), bit: 2))
                var4 = var4 - 1
                if (var4 < 0) {
                    break;
                }
                
                var2[var5] = Int8(var2[var5] | (var2[var4] & 15) << 4)
                var5 = var5 - 1
                var2[var5] = Int8(relizeRight(value: (Int(var2[var4] & 48)), bit: 4))
                var4 = var4 - 1
                if (var4 < 0) {
                    break;
                }
                
                var2[var5] = Int8(var2[var5] | var2[var4] << 2)
                var2[var5 - 1] = 0;
                var5 = var5 - 1
                var4 = var4 - 1
            } while(var4 >= 0)
            
            while var2[var5] == 0 {
                var5 = var5 + 1
            }
            
            var var6 = [Int8](repeating: 0, count: var1 - var5 + 1)
            let i = 0
            for i in i..<var1 - var5 + 1{
                var6[i] = var2[var5 + i]
            }
            return var6
        }
    }
    
    

    
}


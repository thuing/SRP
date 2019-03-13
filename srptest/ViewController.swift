//
//  ViewController.swift
//  srptest
//
//  Created by 小福 on 2019/1/7.
//  Copyright © 2019 小福. All rights reserved.
//

import UIKit
import BigInt
import Cryptor

class ViewController: UIViewController {

    // 用户名 I,传给服务器
    let I = "15001950262"
    // 用户密码
    let p = "jingxi123456"
    // 计算x=H（s，P）
    // P是登录时服务器传过来存储的。
    var x :BigUInt?
    
    // 服务器端传来的盐值。s
    let salt = "jjj123456"
    
    // 服务器传值 N ，g ，s 盐值
    let N :BigUInt = 9223372036854775817
    let g :BigUInt = 33391
    let k :BigUInt = 3
    
    // 随机生成的a值
    var a :BigUInt = ""
    
    
    // 计算得到的A值 A=g^a (mod n) 并且传递这个A值  传给服务器端
    // g值是从服务器端获取得到的
    var A :BigUInt = ""
    // 得到服务器端传来的B值
    var B :BigUInt = ""

    var HAMK1: Data?
    var HAMK2: Data?
    var K: BigUInt = ""

    // 将A变成data类型
    public var publicKey: Data {
        return A.serialize()
    }

    // 将B变成data类型
    public var serverPublicKey: Data {
        return B.serialize()
    }
    
    // 将K变成data类型
    public var KData: Data {
        return K.serialize()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("@发送给服务器端用户名I：",I)
        // 随机生成了一个64位的随机a值
        a = 3283669605040562457
            // BigUInt(Data(bytes: try! Random.generate(byteCount: 64)))
        // 计算得到的A值 A=g^a (mod n) 
        A = doneInN(value: g.power(a, modulus: N))
        print("@发送给服务器端A值为:",A)
        
        // 计算u=H(A+B) sha1算法
        let u = doneInN(value: calculate_u(algorithm: .sha1, A: publicKey, B: serverPublicKey))
        print("用户的盐为:",salt)
        print("共同计算u的值为:",u)
        
        // 将salt 和 p 转化为data
        let sData = bigintCData(str: salt).serialize()
        let pData = bigintCData(str: p).serialize()
        
        // 计算x
        x = doneInN(value: calculate_x(algorithm: .sha1, salt: sData, password: pData))
        print("@发送给服务器x的值为:",x!)
        
        // 计算v
        let v = doneInN(value: calculate_v(x: x!))
        print("v的值为:",v)
        
        // 从服务器得到B
        B = 8713189604502447298


        // 计算 S=（B-k*g^x）^(a+u*x)
        let S = (B + N - k * v % N).power(a + u * x!, modulus: N)
        print("客户端S值:",S)
        
        // 计算 K=H(S) sha1 算法
        let H = Digest.hasher(.sha1)
        K = doneInN(value: BigUInt(H(S.serialize())))
        print("客户端K值:",K as Any)

        // 计算M
        let Idata = bigintCData(str: I).serialize()
        let M = doneInN(value: calculate_M(algorithm: .sha1, username: Idata, salt: sData, A: publicKey, B: serverPublicKey, K: K.serialize()))
        print("客户端计算的M:",M)
        
    }
    
    func test(algorithm: Digest.Algorithm,salt:Data,password:Data) -> BigUInt {
        let H = Digest.hasher(algorithm)
        return BigUInt(H(salt+password))
    }
    
    // 大整数转字节数组
    func bigUintToByte(bigUInt:BigUInt) -> [UInt8] {
        return [[UInt8](String(bigUInt).data(using: .utf8)!)[0]]
    }
    
    // 大整数转biguint
    func bigintCData(str:String) -> BigUInt {
        let srp = srpClient()
        let array  = try! srp.fromb64(var0: str)
        let data = NSData(bytes: array, length: array.count)
        let sBigUInt = doneInN(value: BigUInt.init(data as Data))
        return sBigUInt
    }
    
    
    // 大整数 mod N
    func doneInN(value:BigUInt) -> BigUInt {
        return value % N
    }
    
    
    //M1 = H(H(N) XOR H(g) | H(I) | s | A | B | K)
    func calculate_M(algorithm: Digest.Algorithm, username: Data, salt: Data, A: Data, B: Data, K: Data) -> BigUInt {
        let H = Digest.hasher(algorithm)
        let Ndata = H(N.serialize())
        let gData = H(g.serialize())
        let HI = H(username)
        let nxorg = xor(var0: Ndata, var1: gData, var2: 20)
        let hashM = Digest.hasher(algorithm)
        return BigUInt(hashM(nxorg + HI + salt + A + B + K))
    }
    
    func xor(var0:Data,var1:Data,var2:Int) -> Data {
        var var3 = [UInt8](repeating: 0, count: var2)
        let var4 = 0
        for var4 in var4..<var2{
            var3[var4] = UInt8(var0[var4] ^ var1[var4])
        }
        
        let data = NSData(bytes: var3, length: var3.count)
        return data as Data
    }
    
    // 计算x x = hash(salt + p)
    func calculate_x(algorithm: Digest.Algorithm,salt:Data,password:Data) -> BigUInt {
        let H = Digest.hasher(algorithm)
        return BigUInt(H(salt+password))
    }

    // 计算u u = hash(a+b)
    func calculate_u(algorithm: Digest.Algorithm,A:Data,B:Data) -> BigUInt {
        let H = Digest.hasher(algorithm)
        return BigUInt(H(A+B))
    }

    // 计算v v = g^x % n
    func calculate_v(x: BigUInt) -> BigUInt {
        return g.power(x, modulus: N)
    }
    
    /**
     *   base64编码
     */
    func base64Encoding(str:String)->String{
        let strData = str.data(using: String.Encoding.utf8)
        let base64String = strData?.base64EncodedString(options: NSData.Base64EncodingOptions.init(rawValue: 0))
        return base64String ?? ""
    }
    
    /**
     *   base64解码
     */
    func base64Decoding(encodedStr:String)->String{
        let decodedData = NSData(base64Encoded: encodedStr, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        let decodedString = NSString(data: decodedData! as Data, encoding: String.Encoding.utf8.rawValue)! as String
        return decodedString
    }

}


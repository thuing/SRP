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
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {


    // 用户密码
    let p = "13818120453"
    // 计算x=H（s，P）
    // P是登录时服务器传过来存储的。
    var x :BigInt = ""
    
    let a = BigInt(BigUInt.randomInteger(withMaximumWidth: 64))

    
    // 服务器传值 N ，g ，s 盐值
    let N :BigInt = BigInt("9223372036854775817")
    let g :BigInt = BigInt("9223372036854775889")
    let k :BigInt = BigInt("3")
    
    // 随机生成的a值
    
    // 计算得到的A值 A=g^a (mod n) 并且传递这个A值  传给服务器端
    // g值是从服务器端获取得到的
    //var A :BigInt = ""
    // 得到服务器端传来的B值
    //var B :BigInt = ""

    var HAMK1: Data?
    var HAMK2: Data?

//    // 将A变成data类型
//    public var publicKey: Data {
//        return A.serialize()
//    }
//
//    // 将B变成data类型
//    public var serverPublicKey: Data {
//        return B.serialize()
//    }
//
//    // 将K变成data类型
//    public var KData: Data {
//        return K.serialize()
//    }
//
    // 大整数转biguint
    func bigintCData(str:String) -> BigInt {
        let srp = srpClient()
        let array  = try! srp.fromb64(var0: str)
        let data = NSData(bytes: array, length: array.count)
        let sBigInt = doneInNU(value: BigInt.init(data as Data))
        return sBigInt
    }
    
    // string转data
    func stringToData(str:String) -> Data {
        let srp = srpClient()
        let array  = try! srp.fromb64(var0: str)
        let data = NSData(bytes: array, length: array.count)
        return data as Data
    }
    
    func doneInNU(value:BigInt) -> BigInt {
        return value.modulus(BigInt(N))
    }
    
    // 计算校验的 H
    func calculate_H(algorithm: Digest.Algorithm,A: Data, M: Data, K: Data) -> BigInt {
        let H = Digest.hasher(algorithm)
        return BigInt(H(A + M + K))
    }
    
    
    //M1 = H(H(N) XOR H(g) | H(I) | s | A | B | K)
    func calculate_M(algorithm: Digest.Algorithm, username: Data, salt: Data, A: Data, B: Data, K: Data) -> BigInt {
        let H = Digest.hasher(algorithm)
        let Ndata = H(N.serialize())
        let gData = H(g.serialize())
        let HI = H(username)
        let nxorg = xor(var0: Ndata, var1: gData, var2: 20)
        let hashM = Digest.hasher(algorithm)
        return BigInt(hashM(nxorg + HI + salt + A + B + K))
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
    func calculate_x(algorithm: Digest.Algorithm,salt:Data,password:Data) -> BigInt {
        let H = Digest.hasher(algorithm)
        return BigInt(H(salt+password))
    }
    
    // 计算u u = hash(a+b)
    func calculate_u(algorithm: Digest.Algorithm,A:Data,B:Data) -> BigInt {
        let H = Digest.hasher(algorithm)
        return BigInt(H(A+B))
    }
    
    // 计算v v = g^x % n
    func calculate_v(x: BigInt) -> BigInt {
        return g.power(x, modulus: N)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(bigintCData(str: "J"))

//        let phone = I.substingInRange(0..<10)
//        print("string from 4 - 6 : \(phone ?? "")")

        
        func dy_getDeviceUUID() -> String? {
            let uuid = CFUUIDCreate(nil)
            let uuidStr = CFUUIDCreateString(nil, uuid)
            print("uuidStr------》%@", uuidStr!)
            return (uuidStr)! as String
        }
        dy_getDeviceUUID()

        
        // 随机生成了一个64位的随机a值
       
        print("a的值为：" ,a)
            //BigInt("4020924540494586078")
            // BigInt(Data(bytes: try! Random.generate(byteCount: 64)))
//        // 计算得到的A值 A=g^a (mod n)
//        A = doneInNU(value: g.power(a, modulus: N))
//        print("@发送给服务器端A值为:",A)
//
//        // 从服务器得到B
//        B = BigInt("1244232474483207705")

        // 用户名 I,传给服务器
        let I = "13818120453"
        print("@发送给服务器端用户名I：",I)
        
        // 服务器端传来的盐值。s
        let salt = "739148ef9aa64c58abf1dafd5bccf98f"
        
        let cid = "8aac99bfdff6870b28f74fcfb191a2e9"
        
        let phone = "13818120453"
        
        let reqUrlSrp1 = "http://101.91.223.96:9000/taisecurity/check/register"
        
        let phoneFirst = phone.substingInRange(0..<10)
        let UUID = dy_getDeviceUUID()!.substingInRange(0..<4)
        let password = "13818120450B671381812045" //phoneFirst! + UUID! + phoneFirst!
        print("password is ", password)
        
        // 将salt 和 p 转化为data
        let sData = bigintCData(str: salt).serialize()
        let pData = bigintCData(str: password).serialize()
        
        // 计算x
        x = doneInNU(value: calculate_x(algorithm: .sha1, salt: sData, password: pData))
        print("@发送给服务器x的值为:",x)
        
        // 计算v
        let v = doneInNU(value: calculate_v(x: x))
        print("@发送给服务器v的值为:",v)
        
        let paraDicSrp:Dictionary<String, Any> = ["phone": phone,"cid": cid, "v":v]
        
        Alamofire.request(reqUrlSrp1, method: .post, parameters:paraDicSrp , encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            if(response.error == nil){
                print("请求成功")
                let jsonValue = response.result.value
                // 得到info
                if jsonValue != nil {
                    print(jsonValue as Any)
                    let json = JSON(jsonValue!)
                    let code = json["code"].intValue
                    if code == 200 {
                        print("truetrue")
                        
                        let A = self.doneInNU(value: self.g.power(self.a, modulus: self.N))
                        print("@发送给服务器端A值为:",A)
                        
                        let reqUrlSrp2 = "http://101.91.223.96:9000/taisecurity/check/checkStart"
                        let paraDicSrp:Dictionary<String, Any> = ["paramA":A,"cid":cid, "userName":phone]
                        Alamofire.request(reqUrlSrp2, method: .post, parameters:paraDicSrp , encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
                            if(response.error == nil){
                                print("请求成功")
                                let jsonValue = response.result.value
                                // 得到info
                                if jsonValue != nil {
                                    print(jsonValue as Any)
                                    if code == 200 {
                                        let json = JSON(jsonValue!)
                                        let B = BigInt(json["data"]["B"].stringValue)!
                                        print("B is ",B,"A is ",A)
                                        print("srp2")
                                        
                                        // 计算u=H(A+B) sha1算法
                                        let u = self.doneInNU(value: self.calculate_u(algorithm: .sha1, A: A.serialize(), B: B.serialize()))
                                        print("共同计算u的值为:",u)
                                        
                                        let reqUrlSrp3 = "http://101.91.223.96:9000/taisecurity/check/verify"
                                        // 计算 S=（B-k*g^x）^(a+u*x)
                                        let S = self.doneInNU(value: (B - self.k * self.g.power(self.x, modulus: self.N)).power(self.a + u * self.x, modulus: self.N))
                                        print("客户端S值:",S)
                                        
                                        // 计算 K=H(S) sha1 算法
                                        let H = Digest.hasher(.sha1)
                                        let K = self.doneInNU(value: BigInt(H(S.serialize())))
                                        print("客户端K值:",K as Any)
                                        
                                        // 计算M
                                        let IData = self.stringToData(str: I)
                                        let SData = self.stringToData(str: salt)
                                        
                                        let M = self.doneInNU(value: self.calculate_M(algorithm: .sha1, username: IData, salt: SData, A: A.serialize(), B: B.serialize(), K: K.serialize()))
                                        print("客户端计算的M:",M)
                                        
                                        let paraDicSrp:Dictionary<String, Any> = ["userName":phone,"paramM":String(M)]
                                        Alamofire.request(reqUrlSrp3, method: .post, parameters:paraDicSrp , encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
                                            if(response.error == nil){
                                                print("请求成功")
                                                let jsonValue = response.result.value
                                                // 得到info
                                                if jsonValue != nil {
                                                    print(jsonValue as Any)
                                                    if code == 200 {
                                                        let json = JSON(jsonValue!)
                                                        let info = json["info"].stringValue
                                                        let HService = BigInt(json["data"]["H"].stringValue)!
                                                        
                                                        // 校验H
                                                        let HClient = self.doneInNU(value: self.calculate_H(algorithm: .sha1, A: A.serialize(), M: M.serialize(), K: K.serialize()))
                                                        print("H is " ,HClient)
                                                        if HService == HClient {
                                                            print("true !!")
                                                        }
                                                        
                                                        
                                                        print("srp3  ", info)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        
        


    }
    
    // 大整数转字节数组
    func bigUintToByte(bigUInt:BigUInt) -> [UInt8] {
        return [[UInt8](String(bigUInt).data(using: .utf8)!)[0]]
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

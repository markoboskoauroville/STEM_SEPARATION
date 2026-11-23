// Orders to Live through AbletonOSC (UDP 127.0.0.1:11010). Send only: answers go to 11011, which belongs to Ableton Live
// Actions, so this app never waits for one; it watches the disk for the stems instead.
import Foundation

enum OSC {
    static func pad(_ d: inout Data) { while d.count % 4 != 0 { d.append(0) } }
    static func str(_ s: String) -> Data { var d = Data(s.utf8); d.append(0); pad(&d); return d }
    static func message(_ addr: String, _ args: [Any]) -> Data {
        var d = str(addr), tags = ",", body = Data()
        for a in args {
            switch a {
            case let i as Int: tags += "i"; var v = Int32(i).bigEndian; body.append(Data(bytes: &v, count: 4))
            case let f as Double: tags += "f"; var v = Float(f).bitPattern.bigEndian; body.append(Data(bytes: &v, count: 4))
            case let s as String: tags += "s"; body.append(str(s))
            default: break
            }
        }
        d.append(str(tags)); d.append(body); return d
    }
    @discardableResult static func send(_ addr: String, _ args: [Any] = []) -> Bool {
        let s = socket(AF_INET, SOCK_DGRAM, 0); guard s >= 0 else { return false }
        defer { close(s) }
        var to = sockaddr_in(); to.sin_family = sa_family_t(AF_INET); to.sin_port = UInt16(11010).bigEndian
        to.sin_addr.s_addr = inet_addr("127.0.0.1")
        let d = message(addr, args)
        let n = d.withUnsafeBytes { p in withUnsafePointer(to: &to) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            sendto(s, p.baseAddress, d.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) } } }
        appendLog("osc \(addr) \(args)")
        return n == d.count
    }
}

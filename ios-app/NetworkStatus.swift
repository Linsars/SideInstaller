import Foundation
import Darwin

/// Network diagnostics for the loopback-based RSD transport. We keep interface
/// scanning for human-readable detail, but readiness is decided by a real TCP
/// probe to the RSD endpoint rather than by a specific VPN app or subnet guess.
enum NetworkStatus {

    struct Interface {
        let name: String
        let ipv4: String
    }

    static func interfaces() -> [Interface] {
        var result: [Interface] = []
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddr) == 0, let first = ifaddr else { return [] }
        defer { freeifaddrs(ifaddr) }

        var ptr: UnsafeMutablePointer<ifaddrs>? = first
        while let cur = ptr {
            defer { ptr = cur.pointee.ifa_next }
            guard let addr = cur.pointee.ifa_addr else { continue }
            guard addr.pointee.sa_family == sa_family_t(AF_INET) else { continue }
            let name = String(cString: cur.pointee.ifa_name)

            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let r = getnameinfo(addr, socklen_t(addr.pointee.sa_len),
                                &host, socklen_t(host.count),
                                nil, 0, NI_NUMERICHOST)
            guard r == 0 else { continue }
            result.append(Interface(name: name, ipv4: String(cString: host)))
        }
        return result
    }

    /// `(reachable, wifiUp, detail)` — reachable when the app can actually open a
    /// TCP connection to the RSD endpoint on `deviceIP:49152`.
    static func summarize(deviceIP: String, port: UInt16 = 49152) async -> (vpn: Bool, wifi: Bool, detail: String) {
        let ifs = interfaces()
        let reachable = await LoopbackProbe.canReach(host: deviceIP, port: port)
        let wifi = ifs.contains { $0.name == "en0" }
        let detail = ifs.map { "\($0.name)=\($0.ipv4)" }.joined(separator: ", ")
        return (reachable, wifi, detail)
    }
}

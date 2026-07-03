import Foundation
import Network

/// Real transport readiness probe for the RSD endpoint. Unlike interface-name or
/// subnet heuristics, this tests the thing we actually need: can the app reach
/// `deviceIP:port` right now.
enum LoopbackProbe {
    static func canReach(host: String, port: UInt16, timeout: TimeInterval = 1.2) async -> Bool {
        guard let nwPort = NWEndpoint.Port(rawValue: port) else { return false }
        let connection = NWConnection(host: NWEndpoint.Host(host), port: nwPort, using: .tcp)
        let queue = DispatchQueue(label: "sideinstaller.loopbackprobe")

        return await withCheckedContinuation { cont in
            var finished = false
            func resolve(_ ok: Bool) {
                guard !finished else { return }
                finished = true
                connection.stateUpdateHandler = nil
                connection.cancel()
                cont.resume(returning: ok)
            }

            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    resolve(true)
                case .failed(_), .cancelled:
                    resolve(false)
                default:
                    break
                }
            }

            connection.start(queue: queue)
            queue.asyncAfter(deadline: .now() + timeout) {
                resolve(false)
            }
        }
    }
}

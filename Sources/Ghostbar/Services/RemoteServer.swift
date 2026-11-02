import Foundation
import Network
import CoreImage
import AppKit

func getLocalIPAddress() -> String? {
    var address: String?
    var ifaddr: UnsafeMutablePointer<ifaddrs>?
    guard getifaddrs(&ifaddr) == 0 else { return nil }
    guard let firstAddr = ifaddr else { return nil }
    defer { freeifaddrs(ifaddr) }

    for ptr in sequence(first: firstAddr, next: { $0.pointee.ifa_next }) {
        let interface = ptr.pointee
        let addrFamily = interface.ifa_addr.pointee.sa_family
        if addrFamily == UInt8(AF_INET) {
            let name = String(cString: interface.ifa_name)
            if name == "en0" || name == "en1" || name.starts(with: "en") {
                var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                getnameinfo(interface.ifa_addr, socklen_t(interface.ifa_addr.pointee.sa_len),
                            &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST)
                address = String(cString: hostname)
                if let a = address, !a.isEmpty, a != "127.0.0.1" {
                    return a
                }
            }
        }
    }
    return address
}

func generateQRCodeBase64(from string: String) -> String? {
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    filter.setValue(string.data(using: .utf8), forKey: "inputMessage")
    filter.setValue("M", forKey: "inputCorrectionLevel")
    guard let outputImage = filter.outputImage else { return nil }
    
    let transform = CGAffineTransform(scaleX: 8, y: 8)
    let scaled = outputImage.transformed(by: transform)
    let rep = NSCIImageRep(ciImage: scaled)
    let nsImage = NSImage(size: rep.size)
    nsImage.addRepresentation(rep)
    guard let tiffData = nsImage.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else { return nil }
    return "data:image/png;base64," + pngData.base64EncodedString()
}

class RemoteServer {
    private var listener: NWListener?
    private let queue = DispatchQueue(label: "com.ghostbar.remoteserver", qos: .userInitiated)
    private var sseConnections: [NWConnection] = []
    private var keepAliveTimer: DispatchSourceTimer?
    let port: UInt16

    var onSend: ((String, Bool) -> Void)?
    var onType: ((String) -> Void)?
    var onScreenshot: (() -> Void)?
    var onClear: (() -> Void)?
    var onStop: (() -> Void)?
    var getStatus: (() -> [String: Any])?

    init(port: UInt16 = 8765) {
        self.port = port
    }

    func start() {
        do {
            let params = NWParameters.tcp
            params.allowLocalEndpointReuse = true
            listener = try NWListener(using: params, on: NWEndpoint.Port(rawValue: port)!)
            listener?.stateUpdateHandler = { [weak self] state in
                switch state {
                case .ready:
                    print("[remote] Server listening on port \(self?.port ?? 8765)")
                case .failed(let err):
                    print("[remote] Server failed: \(err)")
                default: break
                }
            }
            listener?.newConnectionHandler = { [weak self] connection in
                self?.handleConnection(connection)
            }
            listener?.start(queue: queue)
            startKeepAlive()
        } catch {
            print("[remote] Failed to start listener: \(error)")
        }
    }

    func stop() {
        keepAliveTimer?.cancel()
        keepAliveTimer = nil
        listener?.cancel()
        listener = nil
        for conn in sseConnections { conn.cancel() }
        sseConnections.removeAll()
    }

    private func startKeepAlive() {
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + 15, repeating: 15)
        timer.setEventHandler { [weak self] in
            guard let self = self else { return }
            let ping = ": keepalive\n\n".data(using: .utf8) ?? Data()
            var active: [NWConnection] = []
            for conn in self.sseConnections {
                if conn.state == .ready {
                    conn.send(content: ping, completion: .contentProcessed({ _ in }))
                    active.append(conn)
                }
            }
            self.sseConnections = active
        }
        timer.resume()
        keepAliveTimer = timer
    }

    func broadcast(event: String, data: String) {
        queue.async {
            var active: [NWConnection] = []
            for conn in self.sseConnections {
                if conn.state == .ready {
                    self.sendSSEEvent(to: conn, event: event, data: data)
                    active.append(conn)
                }
            }
            self.sseConnections = active
        }
    }

    private func sendSSEEvent(to conn: NWConnection, event: String, data: String) {
        let cleanData = data.replacingOccurrences(of: "\r", with: "")
        let lines = cleanData.components(separatedBy: "\n")
        var payload = "event: \(event)\n"
        for line in lines {
            payload += "data: \(line)\n"
        }
        payload += "\n"
        if let pData = payload.data(using: .utf8) {
            conn.send(content: pData, completion: .contentProcessed({ _ in }))
        }
    }

    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: queue)
        readHTTPRequest(connection: connection, accumulated: Data())
    }

    private func readHTTPRequest(connection: NWConnection, accumulated: Data) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] content, _, isComplete, error in
            guard let self = self else { return }
            var buffer = accumulated
            if let content = content {
                buffer.append(content)
            }

            if let requestString = String(data: buffer, encoding: .utf8) {
                if requestString.contains("\r\n\r\n") {
                    self.dispatchHTTP(connection: connection, rawData: buffer, rawString: requestString)
                    return
                }
            }

            if isComplete || error != nil {
                connection.cancel()
                return
            }

            self.readHTTPRequest(connection: connection, accumulated: buffer)
        }
    }

    private func dispatchHTTP(connection: NWConnection, rawData: Data, rawString: String) {
        let parts = rawString.components(separatedBy: "\r\n\r\n")
        guard let headerPart = parts.first else {
            connection.cancel()
            return
        }
        let bodyPart = parts.count > 1 ? parts[1] : ""
        let lines = headerPart.components(separatedBy: "\r\n")
        guard let requestLine = lines.first else {
            connection.cancel()
            return
        }
        let reqComponents = requestLine.components(separatedBy: " ")
        guard reqComponents.count >= 2 else {
            connection.cancel()
            return
        }
        let method = reqComponents[0].uppercased()
        let path = reqComponents[1]

        if method == "OPTIONS" {
            self.sendHTTPResponse(connection: connection, status: "200 OK", contentType: "text/plain", body: "")
            return
        }

        if method == "GET" && (path == "/" || path == "/index.html") {
            let html = phoneRemoteHTML()
            self.sendHTTPResponse(connection: connection, status: "200 OK", contentType: "text/html; charset=utf-8", body: html)
            return
        }

        if method == "GET" && path == "/api/events" {
            self.setupSSE(connection: connection)
            return
        }

        if method == "GET" && path == "/api/status" {
            let status = self.getStatus?() ?? [:]
            let json = (try? JSONSerialization.data(withJSONObject: status)) ?? Data()
            self.sendHTTPResponse(connection: connection, status: "200 OK", contentType: "application/json", bodyData: json)
            return
        }

        if method == "GET" && path == "/api/qr" {
            let ip = getLocalIPAddress() ?? "127.0.0.1"
            let url = "http://\(ip):\(self.port)"
            let qr = generateQRCodeBase64(from: url) ?? ""
            let dict: [String: Any] = ["url": url, "qr": qr, "ip": ip, "port": self.port]
            let json = (try? JSONSerialization.data(withJSONObject: dict)) ?? Data()
            self.sendHTTPResponse(connection: connection, status: "200 OK", contentType: "application/json", bodyData: json)
            return
        }

        if method == "POST" && path == "/api/send" {
            if let data = bodyPart.data(using: .utf8),
               let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
               let text = json["text"] as? String {
                let screenshot = (json["screenshot"] as? Bool) ?? false
                DispatchQueue.main.async {
                    self.onSend?(text, screenshot)
                }
            }
            self.sendHTTPResponse(connection: connection, status: "200 OK", contentType: "application/json", body: "{\"ok\":true}")
            return
        }

        if method == "POST" && path == "/api/type" {
            if let data = bodyPart.data(using: .utf8),
               let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
               let text = json["text"] as? String {
                DispatchQueue.main.async {
                    self.onType?(text)
                }
            }
            self.sendHTTPResponse(connection: connection, status: "200 OK", contentType: "application/json", body: "{\"ok\":true}")
            return
        }

        if method == "POST" && path == "/api/screenshot" {
            DispatchQueue.main.async { self.onScreenshot?() }
            self.sendHTTPResponse(connection: connection, status: "200 OK", contentType: "application/json", body: "{\"ok\":true}")
            return
        }

        if method == "POST" && path == "/api/stop" {
            DispatchQueue.main.async { self.onStop?() }
            self.sendHTTPResponse(connection: connection, status: "200 OK", contentType: "application/json", body: "{\"ok\":true}")
            return
        }

        if method == "POST" && path == "/api/clear" {
            DispatchQueue.main.async { self.onClear?() }
            self.sendHTTPResponse(connection: connection, status: "200 OK", contentType: "application/json", body: "{\"ok\":true}")
            return
        }

        self.sendHTTPResponse(connection: connection, status: "404 Not Found", contentType: "text/plain", body: "Not Found")
    }

    private func sendHTTPResponse(connection: NWConnection, status: String, contentType: String, body: String = "", bodyData: Data? = nil) {
        let payload = bodyData ?? (body.data(using: .utf8) ?? Data())
        let header = "HTTP/1.1 \(status)\r\nContent-Type: \(contentType)\r\nContent-Length: \(payload.count)\r\nAccess-Control-Allow-Origin: *\r\nAccess-Control-Allow-Headers: *\r\nAccess-Control-Allow-Methods: GET, POST, OPTIONS\r\nConnection: close\r\n\r\n"
        var data = header.data(using: .utf8) ?? Data()
        data.append(payload)
        connection.send(content: data, completion: .contentProcessed({ _ in
            connection.cancel()
        }))
    }

    private func setupSSE(connection: NWConnection) {
        let header = "HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nCache-Control: no-cache\r\nConnection: keep-alive\r\nAccess-Control-Allow-Origin: *\r\n\r\n"
        if let hData = header.data(using: .utf8) {
            connection.send(content: hData, completion: .contentProcessed({ [weak self, weak connection] error in
                guard let self = self, let conn = connection, error == nil else {
                    connection?.cancel()
                    return
                }
                self.queue.async {
                    self.sseConnections.append(conn)
                    self.sendSSEEvent(to: conn, event: "init", data: "{\"connected\":true}")
                }
            }))
        }
    }
}


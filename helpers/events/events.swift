import Foundation
import Cocoa
import Network
import CoreBluetooth

private let monitorQueue = DispatchQueue(label: "sketchybar.events.monitor")

enum SketchybarEvent: String, CaseIterable {
    case networkUpdate = "network_update"
    case bluetoothUpdate = "bluetooth_update"
    case statsUpdate = "stats_update"
    
    case mediaUpdateContent = "media_update_content"
    case mediaUpdateStatus = "media_update_is_playing"
}

func sketchybarRegisterEvent(_ event: SketchybarEvent) {
    let message = "--add event '\(event.rawValue)'"
    
    guard var messageData = message.data(using: .utf8) else { return }
    sketchybar(messageData.withUnsafeMutableBytes({ $0.baseAddress }))
}

func sketchybarTriggerEvent(
    _ event: SketchybarEvent,
    parameters: [String: String] = [:]
) {
    var message = "--trigger '\(event.rawValue)'"
    
    if !parameters.isEmpty {
        let messageParameters = (parameters.map({ key, value -> String in
            "\(key)='\(value)'"
        }) as Array).joined(separator: " ")
        message += " \(messageParameters)"
    }
    
    guard var messageData = message.data(using: .utf8) else { return }
    sketchybar(messageData.withUnsafeMutableBytes({ $0.baseAddress }))
}

final class NetworkMonitor {
    private let monitor = NWPathMonitor()
    
    init() {
        sketchybarRegisterEvent(.networkUpdate)
    }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.handleMonitorPathChanged(path)
        }
        monitor.start(queue: monitorQueue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
    
    private func handleMonitorPathChanged(_ path: NWPath) {
        let isConnected = path.status == .satisfied
        sketchybarTriggerEvent(.networkUpdate, parameters: [
            "connected": String(isConnected)
        ])
    }
}

struct MediaStatus: Equatable {
    let artist: String?
    let title: String?
    let isPlaying: Int
}

final class MediaMonitor {
    private typealias MRMediaRemoteRegisterForNowPlayingNotificationsFunction = @convention(c) (DispatchQueue) -> Void
    private typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    
    private let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))
    private let notificationCenter = NotificationCenter.default
    
    private lazy var MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(
        bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString)
    private lazy var MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(
        bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString
    )
    
    private lazy var MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(
        MRMediaRemoteGetNowPlayingInfoPointer,
        to: MRMediaRemoteGetNowPlayingInfoFunction.self
    )
    private lazy var MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(
        MRMediaRemoteRegisterForNowPlayingNotificationsPointer,
        to: MRMediaRemoteRegisterForNowPlayingNotificationsFunction.self
    )
    
    private let MRMediaRemoteNowPlayingInfoDidChangeNotification = NSNotification.Name(rawValue: "kMRMediaRemoteNowPlayingInfoDidChangeNotification")
    private var MRMediaRemoteNowPlayingInfoDidChangeObserver: NSObjectProtocol?
    
    private var mediaStatus: MediaStatus?
    
    func startMonitoring() {
        MRMediaRemoteNowPlayingInfoDidChangeObserver = notificationCenter.addObserver(
            forName: MRMediaRemoteNowPlayingInfoDidChangeNotification,
            object: nil,
            queue: nil,
            using: { [weak self] _ in self?.updateNowPlayingInfo() }
        )
        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main);
        
        updateNowPlayingInfo()
    }
    
    func stopMonitoring() {
        guard let MRMediaRemoteNowPlayingInfoDidChangeObserver else { return }
        notificationCenter.removeObserver(MRMediaRemoteNowPlayingInfoDidChangeObserver)
    }
    
    private func updateNowPlayingInfo() {
        MRMediaRemoteGetNowPlayingInfo(monitorQueue, { (information) in
            let mediaStatus = MediaStatus(
                artist: information["kMRMediaRemoteNowPlayingInfoArtist"] as? String,
                title: information["kMRMediaRemoteNowPlayingInfoTitle"] as? String,
                isPlaying: information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Int ?? .zero
            )
            
            guard self.mediaStatus != mediaStatus else { return }
            
            if mediaStatus.title != self.mediaStatus?.title {
                sketchybarTriggerEvent(.mediaUpdateContent, parameters: [
                    "author": mediaStatus.artist ?? String(),
                    "title": mediaStatus.title ?? String()
                ])
            }
            
            if mediaStatus.isPlaying != self.mediaStatus?.isPlaying {
                sketchybarTriggerEvent(.mediaUpdateStatus, parameters: [
                    "is_playing": mediaStatus.isPlaying == .zero ? "false" : "true"
                ])
            }
            
            self.mediaStatus = mediaStatus
        })
    }
}

final class BluetoothMonitor: NSObject, CBCentralManagerDelegate {
    var centralManager: CBCentralManager?

    func startMonitoring() {
        centralManager = CBCentralManager(delegate: self, queue: monitorQueue)
    }

    func stopMonitoring() {
        centralManager?.stopScan()
        centralManager = nil
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        sketchybarTriggerEvent(.bluetoothUpdate, parameters: [
            "enabled": centralManager?.state == .poweredOn ? "true" : "false"
        ])
    }
}

final class StatsMonitor {
    private let fileManager = FileManager.default
    private var statsTimer: DispatchSourceTimer?
    private var previousCpuLoad = host_cpu_load_info()
    
    init() {
        previousCpuLoad = getCpuLoadInfo()
    }
    
    func startMonitoring() {
        statsTimer?.cancel()
        
        statsTimer = DispatchSource.makeTimerSource(queue: monitorQueue)
        statsTimer?.schedule(deadline: .now(), repeating: 5.0)
        statsTimer?.setEventHandler { [weak self] in
            self?.updateStats()
        }
        
        statsTimer?.resume()
    }
    
    func stopMonitoring() {
        statsTimer?.cancel()
    }
    
    private func getCpuLoadInfo() -> host_cpu_load_info {
        var info = host_cpu_load_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info>.stride / MemoryLayout<integer_t>.stride)
        
        let result = withUnsafeMutablePointer(to: &info) {
            host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0.withMemoryRebound(to: integer_t.self, capacity: 1, { $0 }), &count)
        }
        
        guard result == KERN_SUCCESS else {
            return host_cpu_load_info()
        }
        
        return info
    }
    
    private func getCpuUsage() -> Double {
        let cpuLoad = getCpuLoadInfo()
        
        let userDiff = cpuLoad.cpu_ticks.0 - previousCpuLoad.cpu_ticks.0
        let systemDiff = cpuLoad.cpu_ticks.1 - previousCpuLoad.cpu_ticks.1
        let idleDiff = cpuLoad.cpu_ticks.2 - previousCpuLoad.cpu_ticks.2
        let niceDiff = cpuLoad.cpu_ticks.3 - previousCpuLoad.cpu_ticks.3
        
        let totalTicks = UInt64(systemDiff + userDiff + idleDiff + niceDiff)
        let onePercent = Double(totalTicks / 100)
        
        let system = Double(systemDiff) / onePercent
        let user = Double(userDiff) / onePercent
        
        previousCpuLoad = cpuLoad
        
        return system + user
    }
    
    private func getFreeRam() -> Double {
        let totalPages = UInt(ProcessInfo.processInfo.physicalMemory) / vm_page_size
        
        var vmStats = vm_statistics_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics_data_t>.stride / MemoryLayout<integer_t>.stride)

        let result = withUnsafeMutablePointer(to: &vmStats) {
            return host_statistics(mach_host_self(), HOST_VM_INFO, $0.withMemoryRebound(to: integer_t.self, capacity: 1, { $0 }), &count)
        }
        
        if result == KERN_SUCCESS {
            let freePages = vmStats.free_count + vmStats.inactive_count
            return (Double(freePages) / Double(totalPages)) * 100
        } else {
            return .zero
        }
    }
    
    private func getFreeSsd() -> Double {
        guard let attributes = try? fileManager.attributesOfFileSystem(forPath: "/"),
              let freeSpace = attributes[FileAttributeKey.systemFreeSize] as? NSNumber,
              let totalSpace = attributes[FileAttributeKey.systemSize] as? NSNumber else { return .zero }
        return (freeSpace.doubleValue / totalSpace.doubleValue) * 100
    }
    
    private func updateStats() {
        var cpuUsage = getCpuUsage()
        if cpuUsage < .zero || cpuUsage > 100 { cpuUsage = .zero }
        
        var ramFree = getFreeRam()
        if ramFree < .zero || ramFree > 100 { ramFree = .zero }
        
        var ssdFree = getFreeSsd()
        if ssdFree < .zero || ssdFree > 100 { ssdFree = .zero }
        
        sketchybarTriggerEvent(.statsUpdate, parameters: [
            "cpu": String(format: "%02.0f", cpuUsage.rounded(.toNearestOrAwayFromZero)),
            "ram": String(format: "%02.0f", ramFree.rounded(.toNearestOrAwayFromZero)),
            "ssd": String(format: "%02.0f", ssdFree.rounded(.toNearestOrAwayFromZero)),
        ])
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    let bluetoothMonitor = BluetoothMonitor()
    let networkMonitor = NetworkMonitor()
    let mediaMonitor = MediaMonitor()
    let statsMonitor = StatsMonitor()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        registerSketchybarEvents()
        
        bluetoothMonitor.startMonitoring()
        networkMonitor.startMonitoring()
        mediaMonitor.startMonitoring()
        statsMonitor.startMonitoring()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        bluetoothMonitor.stopMonitoring()
        networkMonitor.stopMonitoring()
        mediaMonitor.stopMonitoring()
        statsMonitor.stopMonitoring()
    }
    
    func registerSketchybarEvents() {
        SketchybarEvent.allCases.forEach {
            sketchybarRegisterEvent($0)
        }
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()


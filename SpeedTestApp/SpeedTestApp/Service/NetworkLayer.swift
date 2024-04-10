
import UIKit
import SpeedcheckerSDK
import CoreLocation

class NetworkLayer: UIViewController {
    
    private var internetTest: InternetSpeedTest?
    private var locationManager = CLLocationManager()
    var downloadSpeed: Double = 0
    var uploadSpeed: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationAuthorization()
    }
}

extension NetworkLayer {
    func runSpeedTestTouched() {
        internetTest = InternetSpeedTest(delegate: self)
        internetTest?.startFreeTest() { (error) in
            if error != .ok {
                print("Error: \(error.rawValue)")
            }
        }
    }
    
    func requestLocationAuthorization() {
        DispatchQueue.global().async {
            guard CLLocationManager.locationServicesEnabled() else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.locationManager.delegate = self
                self?.locationManager.requestWhenInUseAuthorization()
                self?.locationManager.requestAlwaysAuthorization()
            }
        }
    }
}

extension NetworkLayer: InternetSpeedTestDelegate {
    
    func internetTestError(error: SpeedTestError) {
        print("Error: \(error.rawValue)")
    }
    
    func internetTestFinish(result: SpeedTestResult) {
        downloadSpeed = result.downloadSpeed.mbps
        uploadSpeed = result.uploadSpeed.mbps
        print(downloadSpeed)
        print(uploadSpeed)
    }
    
    func internetTestReceived(servers: [SpeedTestServer]) {
    }
    
    func internetTestSelected(server: SpeedTestServer, latency: Int, jitter: Int) {
        print("Latency: \(latency)")
        print("Jitter: \(jitter)")
    }
    
    func internetTestDownloadStart() {
    }
    
    func internetTestDownloadFinish() {
    }
    
    func internetTestDownload(progress: Double, speed: SpeedTestSpeed) {
        print("Download: \(speed.descriptionInMbps)")
    }
    
    func internetTestUploadStart() {
    }
    
    func internetTestUploadFinish() {
    }
    
    func internetTestUpload(progress: Double, speed: SpeedTestSpeed) {
        print("Upload: \(speed.descriptionInMbps)")
    }
}

extension NetworkLayer: CLLocationManagerDelegate {
}


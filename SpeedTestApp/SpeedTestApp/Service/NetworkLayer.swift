
import UIKit
import SpeedcheckerSDK
import CoreLocation

class NetworkLayer: UIViewController, CLLocationManagerDelegate {
    // MARK: - Properties
    private var internetTest: InternetSpeedTest? // объект для тестирования скорости интернета
    private var locationManager = CLLocationManager() // менеджер для работы с геолокацией
    var downloadSpeed: Double = 0 // скорость загрузки
    var uploadSpeed: Double = 0 // скорость выгрузки
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        requestLocationAuthorization()
    }
}
// MARK: - NetworkLayer Extension
extension NetworkLayer {
    // MARK: инициализация и запуск тестирования скорости интернета
    func runSpeedTestTouched() {
        internetTest = InternetSpeedTest(delegate: self)
        internetTest?.startFreeTest() { (error) in
            if error != .ok {
                print("Error: \(error.rawValue)")
            }
        }
    }
    // MARK: запрос на авторизацию геолокации у пользователя
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
    // обработка ошибок
    func internetTestError(error: SpeedTestError) {
        print("\(LocalConstants.errorText) \(error.rawValue)")
    }
    // передача результата теста
    func internetTestFinish(result: SpeedTestResult) {
        downloadSpeed = result.downloadSpeed.mbps
        uploadSpeed = result.uploadSpeed.mbps
    }
    
    // MARK: методы делегата
    func internetTestReceived(servers: [SpeedTestServer]) {
    }
    
    func internetTestSelected(server: SpeedTestServer, latency: Int, jitter: Int) {
        print("\(LocalConstants.latencyText) \(latency)")
        print("\(LocalConstants.jitterText) \(jitter)")
    }
    
    func internetTestDownloadStart() {
    }
    
    func internetTestDownloadFinish() {
    }
    
    func internetTestDownload(progress: Double, speed: SpeedTestSpeed) {
        print("\(LocalConstants.downloadText) \(speed.descriptionInMbps)")
    }
    
    func internetTestUploadStart() {
    }
    
    func internetTestUploadFinish() {
    }
    
    func internetTestUpload(progress: Double, speed: SpeedTestSpeed) {
        print("\(LocalConstants.uploadText) \(speed.descriptionInMbps)")
    }
}
// MARK: - Local constantnts
extension NetworkLayer {
    enum LocalConstants {
        static let errorText = "Error:"
        static let latencyText = "Latency:"
        static let jitterText = "Jitter:"
        static let downloadText = "Download:"
        static let uploadText = "Upload:"
    }
}

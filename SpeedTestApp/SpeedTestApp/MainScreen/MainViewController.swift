
import UIKit
import SnapKit
import CoreLocation
import SpeedcheckerSDK


class MainViewController: UIViewController, CLLocationManagerDelegate {
 
    // MARK: - Properties
    private let speedButton = UIButton()
    private let settingsButton = UIBarButtonItem()
    private let downloadSpeedLabel = UILabel()
    private let uploadSpeedLabel = UILabel()
    private let loader = UIActivityIndicatorView()
    private let locationManager = CLLocationManager()

    var settingsVC = SettingsViewController()
    var speedTestResultBindable = Bindable<NetworkLayer>(NetworkLayer())
    var network = NetworkLayer()
    var viewModel = MainViewModel()
    
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingsVC.delegate = self
        setupLayout()
        bindLoading()
        applySavedTheme()
        applySavedToggles()
    }
}
// MARK: - Setup layouts
private extension MainViewController {
    func setupLayout() {
        setupTitle()
        setupLocationManager()
        setupSettingButton()
        setupSpeedButton()
        setupDownloadSpeedLabel()
        setupUploadSpeedLabel()
        setupLoader()
    }
    // MARK: задаем название тайтла и цвет
    func setupTitle() {
        title = LocalConstants.title
        view.backgroundColor = .white
    }
    // MARK: устанонавливаем менеджер для определения текущего местоположения юзера
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }
    // MARK: задаем кнопку настроек в навигации
    func setupSettingButton() {
        settingsButton.title = LocalConstants.settingsButtonTitle
        navigationItem.rightBarButtonItem = settingsButton
        settingsButton.action = #selector(pushSettingButton)
        settingsButton.target = self
    }
    // MARK: добавляем кнопку "Проверки скорости" и задаем ее параметры
    func setupSpeedButton() {
        view.addSubview(speedButton)
        speedButton.setTitle(LocalConstants.speedButtonTitle, for: .normal)
        speedButton.titleLabel?.numberOfLines = LocalConstants.numberOfLines
        speedButton.titleLabel?.textAlignment = .center
        speedButton.setTitleColor(.white, for: .normal)
        speedButton.backgroundColor = .systemBlue
        speedButton.layer.cornerRadius = LocalConstants.cornerRadius
        speedButton.titleLabel?.font = UIFont.systemFont(ofSize: LocalConstants.systemFont, weight: .bold)
        speedButton.addTarget(self, action: #selector(runSpeedTestStart), for: .touchUpInside)
        
        speedButton.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(LocalConstants.speedButtonWeidhHeight)
            make.height.equalTo(LocalConstants.speedButtonWeidhHeight)
        })
    }
    // MARK: добавляем лейбл, на котором будет отображаться скорость загрузки
    func setupDownloadSpeedLabel() {
        view.addSubview(downloadSpeedLabel)
        
        downloadSpeedLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(speedButton.snp.bottom).inset(LocalConstants.downloadSpeedLabelLoaderInset)
        }
    }
    // MARK: добавляем лейбл, на котором будет отображаться скорость выгрузки
    func setupUploadSpeedLabel() {
        view.addSubview(uploadSpeedLabel)
        
        uploadSpeedLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(downloadSpeedLabel.snp.bottom).inset(LocalConstants.uploadSpeedLabelInset)
        }
    }
    // MARK: добавляем лоудер
    func setupLoader() {
        view.addSubview(loader)
        loader.isHidden = true
        loader.style = .large
        loader.color = .systemBlue
        
        loader.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(speedButton.snp.bottom).inset(LocalConstants.downloadSpeedLabelLoaderInset)
        }
    }
}
// MARK: - Methods
extension MainViewController {
    // MARK: обработка нажатия кнопки Настройки
    @objc func pushSettingButton() {
        viewModel.onSettingsButtonTapped = { [weak self] in
            self?.openSettingsScreen()
                }
        viewModel.handleSettingsButtonTapped()
    }
    // MARK: запуск теста скорости
    @objc func runSpeedTestStart() {
        speedButton.isEnabled = false
        downloadSpeedLabel.text = ""
        uploadSpeedLabel.text = ""
        network.runSpeedTestTouched()
        viewModel.isLoading.value = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + LocalConstants.timeWaiting) { [self] in
            self.viewModel.isLoading.value = false
            self.speedButton.isEnabled = true
            if settingsVC.showDownloadSpeed == true && settingsVC.showUploadSpeed == true {
                self.speedTestResultBindable.bind { [self] _ in
                    downloadSpeedLabel.text = "\(LocalConstants.downloadSpeedText) \(network.downloadSpeed)\(LocalConstants.mbpsText)"
                    uploadSpeedLabel.text = "\(LocalConstants.uploadSpeedText) \(network.uploadSpeed)\(LocalConstants.mbpsText)"
                }
            } else if settingsVC.showDownloadSpeed == false && settingsVC.showUploadSpeed == true {
                self.speedTestResultBindable.bind { [self] _ in
                    uploadSpeedLabel.text = "\(LocalConstants.uploadSpeedText) \(network.uploadSpeed)\(LocalConstants.mbpsText)"
                }
            } else if settingsVC.showDownloadSpeed == true && settingsVC.showUploadSpeed == false {
                self.speedTestResultBindable.bind { [self] _ in
                    downloadSpeedLabel.text = "\(LocalConstants.downloadSpeedText) \(network.downloadSpeed)\(LocalConstants.mbpsText)"
                }
            } else {
                uploadSpeedLabel.text = LocalConstants.checkSettings
                uploadSpeedLabel.numberOfLines = LocalConstants.numberOfLines
                uploadSpeedLabel.textAlignment = .center
            }
        }
    }
}
// MARK: - Navigation method
extension MainViewController {
    // MARK: метод отвечающий за переход на экран Настроек
    func openSettingsScreen() {
        let settingsViewController = SettingsViewController()
        settingsViewController.delegate = self
        navigationController?.pushViewController(settingsViewController, animated: true)
    }
}
// MARK: - Delegate
extension MainViewController: ThemeSelectionDelegate {
    // MARK: применение сохраненной темы оформления в приложении
    func applySavedTheme() {
        if let savedTheme = UserDefaults.standard.value(forKey: LocalConstants.selectedThemeKeyText) as? Int {
            let selectedTheme = Theme(rawValue: savedTheme) ?? .system
            applyTheme(selectedTheme)
        }
    }
    // MARK: применение конкретной темы: изменение цветовой схемы, установка соответствующих цветов для шрифтов
    func applyTheme(_ theme: Theme) {
        switch theme {
        case .light:
            view.backgroundColor = .white
            view.overrideUserInterfaceStyle = .light
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        case .dark:
            view.backgroundColor = .black
            view.overrideUserInterfaceStyle = .dark
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        case .system:
            view.overrideUserInterfaceStyle = .unspecified
        }
    }
    // MARK: состояние переключателей в приложении
    func applySavedToggles() {
        if let savedToggleDownload = UserDefaults.standard.bool(forKey: LocalConstants.keyDownloadSwitch) as? Bool {
            didToggleDownloadSpeed(savedToggleDownload)
        }
        if let savedToggleUpload = UserDefaults.standard.bool(forKey: LocalConstants.keyUploadSwitch) as? Bool {
            didToggleUploadSpeed(savedToggleUpload)
        }
    }
    
    func didToggleDownloadSpeed(_ isEnabled: Bool) {
        settingsVC.showDownloadSpeed = isEnabled
    }

    func didToggleUploadSpeed(_ isEnabled: Bool) {
        settingsVC.showUploadSpeed = isEnabled
    }
}
// MARK: - loader binding
extension MainViewController {
    // MARK: запуск лоадера
    func startLoader() {
        loader.startAnimating()
        loader.isHidden = false
    }
    // MARK: остановка лоадера
    func stopLoader() {
        loader.stopAnimating()
        loader.isHidden = true
    }
    // MARK: биндинг
    func bindLoading() {
        viewModel.isLoading.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.startLoader()
                } else {
                    self?.stopLoader()
                }
            }
        }
    }
}
// MARK: Local constants
extension MainViewController {
    enum LocalConstants {
        static let title = "Speed Test"
        static let settingsButtonTitle = "Настройки"
        static let speedButtonTitle = "Проверить скорость Интернета"
        static let downloadSpeedText = "Download Speed:"
        static let uploadSpeedText = "Upload Speed:"
        static let mbpsText = "Mbps"
        static let checkSettings = "Зайдите в настройки и выберите, \nкакую скорость хотите узнать"
        static let keyDownloadSwitch = "downloadSpeedSwitchState"
        static let keyUploadSwitch = "uploadSpeedSwitchState"
        static let selectedThemeKeyText = "selectedThemeKey"
        static let numberOfLines = 2
        static let cornerRadius: CGFloat = 125
        static let systemFont: CGFloat = 20
        static let timeWaiting: CGFloat = 25
        static let speedButtonWeidhHeight = 250
        static let downloadSpeedLabelLoaderInset = -40
        static let uploadSpeedLabelInset = -20
    }
}

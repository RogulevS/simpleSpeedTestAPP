
import UIKit

protocol ThemeSelectionDelegate: AnyObject {
    func applyTheme(_ theme: Theme)
    func didToggleDownloadSpeed(_ isEnabled: Bool)
    func didToggleUploadSpeed(_ isEnabled: Bool)
}

class SettingsViewController: UIViewController{
    
    // MARK: - Properties
    weak var delegate: ThemeSelectionDelegate? // Слабая ссылка на делегата для обработки выбора темы
    let settingsViewModel = SettingsViewModel() // ViewModel для управления настройками
    let themeKey = LocalConstants.selectedThemeKey  // Ключ для сохранения выбранной темы
    var selectedTheme: Theme = .light // Выбранная тема (по умолчанию светлая)
    var themeSelectionHandler: ((Theme) -> Void)? // Обработчик выбора темы
    var showDownloadSpeedSwitch: UISwitch! // Переключатель для отображения скорости загрузки
    var showUploadSpeedSwitch: UISwitch! // Переключатель для отображения скорости выгрузки
    var showDownloadSpeed: Bool = true // Флаги для отображения скорости загрузки
    var showUploadSpeed: Bool = true // Флаги для отображения скорости выгрузки
    var themeSelectionCallback: ((Theme) -> Void)? // Callback для выбора темы
    var segmentedControlTheme = UISegmentedControl(items: [LocalConstants.segmentedControlThemeWhite, // SegmentedControl для выбора темы
                                                           LocalConstants.segmentedControlThemeDark,
                                                           LocalConstants.segmentedControlThemeLight])
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadSavedTheme() // Загрузка сохраненной темы
        setupLayout() // Настройка интерфейса
        applyTheme() // Применение темы
        savedSwitch() // Загрузка сохраненных настроек переключателей
    }
}
// MARK: - Private Methods
private extension SettingsViewController {
    // MARK: настройка интерфейса
    func setupLayout() {
        setupSegmentedControl()
        setupDownloadLable()
        setupUploadLable()
        setupDownloadSwitch()
        setupUploadSwitch()
    }
    // MARK: Настройка метки для отображения скорости загрузки
    func setupDownloadLable() {
        let showDownloadSpeedLabel = UILabel(frame: LocalConstants.setupDownloadLable)
        showDownloadSpeedLabel.text = LocalConstants.showDownloadSpeedLabel
        view.addSubview(showDownloadSpeedLabel)
    }
    // MARK: Настройка метки для отображения скорости выгрузки
    func setupUploadLable() {
        let showUploadSpeedLabel = UILabel(frame: LocalConstants.setupUploadLable)
        showUploadSpeedLabel.text = LocalConstants.showUploadSpeedLabel
        view.addSubview(showUploadSpeedLabel)
    }
    // MARK: Настройка переключателя для отображения скорости загрузки
    func setupDownloadSwitch() {
        showDownloadSpeedSwitch = UISwitch(frame: LocalConstants.setupDownloadSwitch)
        view.addSubview(showDownloadSpeedSwitch)
    }
    // MARK: Настройка переключателя для отображения скорости выгрузки
    func setupUploadSwitch() {
        showUploadSpeedSwitch = UISwitch(frame: LocalConstants.setupUploadSwitch)
        showUploadSpeedSwitch.isOn = true
        view.addSubview(showUploadSpeedSwitch)
    }
    // MARK: загрузка сохраненных настроек переключателей
    func savedSwitch() {
        showDownloadSpeedSwitch.isOn = UserDefaults.standard.bool(forKey: LocalConstants.downloadSpeedSwitchState)
        showDownloadSpeedSwitch.addTarget(self, action: #selector(downloadSpeedSwitchChanged), for: .valueChanged)
        showUploadSpeedSwitch.isOn = UserDefaults.standard.bool(forKey: LocalConstants.uploadSpeedSwitchState)
        showUploadSpeedSwitch.addTarget(self, action: #selector(uploadSpeedSwitchChanged), for: .valueChanged)
    }
    // MARK: установка параметров и настроек для UISegmentedControl
    func setupSegmentedControl() {
        segmentedControlTheme.frame = CGRect(x: LocalConstants.segmentedControlThemeX, y: LocalConstants.segmentedControlThemeY, width: view.bounds.width - LocalConstants.segmentedControlThemeWidth, height: LocalConstants.segmentedControlThemeHeight)
        segmentedControlTheme.selectedSegmentIndex = selectedTheme.rawValue
        segmentedControlTheme.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        view.addSubview(segmentedControlTheme)
    }
}
    // MARK: - Methods
private extension SettingsViewController {
    // MARK: вызывается при изменении значения UISegmentedControl
    @objc func segmentedControlValueChanged() {
        selectedTheme = Theme(rawValue: segmentedControlTheme.selectedSegmentIndex) ?? .light
        applyTheme()
        
        if let delegate = delegate {
            delegate.applyTheme(selectedTheme)
        }
    }
    // MARK: применение выбранной темы
    func applyTheme() {
        switch selectedTheme {
        case .light:
            view.backgroundColor = .white
            view.overrideUserInterfaceStyle = .light
    
        case .dark:
            view.backgroundColor = .black
            view.overrideUserInterfaceStyle = .dark
            
        case .system:
            view.overrideUserInterfaceStyle = .unspecified
            if view.backgroundColor == .white {
                view.backgroundColor = .white
                view.overrideUserInterfaceStyle = .light
            } else {
                view.backgroundColor = .black
                view.overrideUserInterfaceStyle = .dark
            }
        }
        saveSelectedTheme() // сохранение выбранной темы
        delegate?.applyTheme(selectedTheme) // передаем через делегата
    }
    // MARK: сохраняет выбранную тему в UserDefaults по ключу
    func saveSelectedTheme() {
           UserDefaults.standard.set(selectedTheme.rawValue, forKey: themeKey)
       }
    // MARK: загружает раннее сохраненную тему из UserDefaults по ключу
    func loadSavedTheme() {
        if let savedTheme = UserDefaults.standard.value(forKey: themeKey) as? Int {
            selectedTheme = Theme(rawValue: savedTheme) ?? .system
        }
    }
}

extension SettingsViewController {
    // MARK: вызывается при изменении состояния переключателя загрузки
    @objc func downloadSpeedSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: LocalConstants.downloadSpeedSwitchState)
        delegate?.didToggleDownloadSpeed(sender.isOn)
    }
    // MARK: вызывается при изменении состояния переключателя выгрузки
    @objc func uploadSpeedSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: LocalConstants.uploadSpeedSwitchState)
        delegate?.didToggleUploadSpeed(sender.isOn)
    }
}

// MARK: Local constants
extension SettingsViewController {
    enum LocalConstants {
        static let segmentedControlThemeWhite = "Светлая"
        static let segmentedControlThemeDark = "Темная"
        static let segmentedControlThemeLight = "Системная"
        static let selectedThemeKey = "selectedThemeKey"
        static let showDownloadSpeedLabel = "Показывать скорость загрузки"
        static let showUploadSpeedLabel = "Показывать скорость отдачи"
        static let downloadSpeedSwitchState = "downloadSpeedSwitchState"
        static let uploadSpeedSwitchState = "uploadSpeedSwitchState"
        static let setupDownloadLable = CGRect(x: 80, y: 150, width: 250, height: 30)
        static let setupUploadLable = CGRect(x: 80, y: 200, width: 250, height: 30)
        static let setupDownloadSwitch = CGRect(x: 20, y: 150, width: 50, height: 30)
        static let setupUploadSwitch = CGRect(x: 20, y: 200, width: 50, height: 30)
        static let segmentedControlThemeX: CGFloat = 20
        static let segmentedControlThemeY: CGFloat = 100
        static let segmentedControlThemeWidth: CGFloat = 40
        static let segmentedControlThemeHeight: CGFloat = 30
    }
}


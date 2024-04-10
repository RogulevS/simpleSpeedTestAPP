
import UIKit

protocol ThemeSelectionDelegate: AnyObject {
    func applyTheme(_ theme: Theme)
    func didToggleDownloadSpeed(_ isEnabled: Bool)
    func didToggleUploadSpeed(_ isEnabled: Bool)
}

class SettingsViewController: UIViewController{
    
    // MARK: - Properties
    weak var delegate: ThemeSelectionDelegate?
    
    let settingsViewModel = SettingsViewModel()
    let themeKey = LocalConstants.selectedThemeKey
    var selectedTheme: Theme = .light
    var themeSelectionHandler: ((Theme) -> Void)?
    var showDownloadSpeedSwitch: UISwitch!
    var showUploadSpeedSwitch: UISwitch!
    var showDownloadSpeed: Bool = true
    var showUploadSpeed: Bool = true
    var themeSelectionCallback: ((Theme) -> Void)?
    var segmentedControlTheme = UISegmentedControl(items: [LocalConstants.segmentedControlThemeWhite,
                                                           LocalConstants.segmentedControlThemeDark,
                                                           LocalConstants.segmentedControlThemeLight])
    //MARK: - Lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedTheme()
        setupLayout()
        applyTheme()
        savedSwitch()
    }
}
// MARK: - Setup layouts
private extension SettingsViewController {
    func setupLayout() {
        setupSegmentedControl()
        setupDownloadLable()
        setupUploadLable()
        setupDownloadSwitch()
        setupUploadSwitch()
    }
    
    func setupDownloadLable() {
        let showDownloadSpeedLabel = UILabel(frame: LocalConstants.setupDownloadLable)
        showDownloadSpeedLabel.text = LocalConstants.showDownloadSpeedLabel
        view.addSubview(showDownloadSpeedLabel)
    }
    
    func setupUploadLable() {
        let showUploadSpeedLabel = UILabel(frame: LocalConstants.setupUploadLable)
        showUploadSpeedLabel.text = LocalConstants.showUploadSpeedLabel
        view.addSubview(showUploadSpeedLabel)
    }
    
    func setupDownloadSwitch() {
        showDownloadSpeedSwitch = UISwitch(frame: LocalConstants.setupDownloadSwitch)
        
        view.addSubview(showDownloadSpeedSwitch)
    }
    
    func setupUploadSwitch() {
        showUploadSpeedSwitch = UISwitch(frame: LocalConstants.setupUploadSwitch)
        showUploadSpeedSwitch.isOn = true
        view.addSubview(showUploadSpeedSwitch)
    }
    
    func savedSwitch() {
        showDownloadSpeedSwitch.isOn = UserDefaults.standard.bool(forKey: LocalConstants.downloadSpeedSwitchState)
        showDownloadSpeedSwitch.addTarget(self, action: #selector(downloadSpeedSwitchChanged), for: .valueChanged)
        showUploadSpeedSwitch.isOn = UserDefaults.standard.bool(forKey: LocalConstants.uploadSpeedSwitchState)
        showUploadSpeedSwitch.addTarget(self, action: #selector(uploadSpeedSwitchChanged), for: .valueChanged)
    }
    
    func setupSegmentedControl() {
        segmentedControlTheme.frame = CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 30)
        segmentedControlTheme.selectedSegmentIndex = selectedTheme.rawValue
        segmentedControlTheme.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
        view.addSubview(segmentedControlTheme)
    }
}
    // MARK: - Methods
private extension SettingsViewController {
    func themeSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        settingsViewModel.selectTheme(index: sender.selectedSegmentIndex)
    }
   
    @objc func segmentedControlValueChanged() {
        selectedTheme = Theme(rawValue: segmentedControlTheme.selectedSegmentIndex) ?? .light
        applyTheme()
        
        if let delegate = delegate {
            delegate.applyTheme(selectedTheme)
        }
    }

    func applyTheme() {
        saveSelectedTheme()
        
        switch selectedTheme {
        case .light:
            view.backgroundColor = .white
        case .dark:
            view.backgroundColor = .darkGray
        case .system:
            view.backgroundColor = .lightGray
        }
        saveSelectedTheme()
        delegate?.applyTheme(selectedTheme) 
    }
    
    func saveSelectedTheme() {
           UserDefaults.standard.set(selectedTheme.rawValue, forKey: themeKey)
       }

    func loadSavedTheme() {
        if let savedTheme = UserDefaults.standard.value(forKey: themeKey) as? Int {
            selectedTheme = Theme(rawValue: savedTheme) ?? .system
        }
    }
}

extension SettingsViewController {
    @objc func downloadSpeedSwitchChanged(_ sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: LocalConstants.downloadSpeedSwitchState)
        delegate?.didToggleDownloadSpeed(sender.isOn)
    }
    
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
    }
}

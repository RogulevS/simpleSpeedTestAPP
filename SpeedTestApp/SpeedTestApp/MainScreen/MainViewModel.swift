
import Foundation

class MainViewModel {

    var mainModel: MainModel?
    var loadingState: Bindable<Bool> = Bindable(false) 
    var onSettingsButtonTapped: (() -> Void)?
    var openSettingsScreen: (() -> Void)?
    var isLoading: Bindable<Bool> = Bindable(false)
    var selectedTheme: Theme = .system {
        didSet {
            applyTheme(selectedTheme)
        }
    }
    
    func startLoading() {
        isLoading.value = true
    }
        
    func stopLoading() {
        isLoading.value = false
    }
    
    func handleSettingsButtonTapped() {
        onSettingsButtonTapped?()
       }
       
    func applyTheme(_ theme: Theme) {
        switch theme {
        case .light:
            break
        case .dark:
            break
        case .system:
            break
        }
    }
    
    func startLoader() {
        mainModel?.loader.startAnimating()
        mainModel?.loader.isHidden = false
    }
    
    func stopLoader() {
        mainModel?.loader.stopAnimating()
        mainModel?.loader.isHidden = true
    }
}

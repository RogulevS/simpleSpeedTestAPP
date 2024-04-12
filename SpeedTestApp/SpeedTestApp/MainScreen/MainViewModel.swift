
import Foundation

class MainViewModel {
    // MARK: - Properties
    var mainModel: MainModel? //экземпляр модели
    var onSettingsButtonTapped: (() -> Void)? // ответ на нажатие на кнопку настроек
    var isLoading: Bindable<Bool> = Bindable(false) // отслеживание состояния загрузки
    var selectedTheme: Theme = .light { // информация о выбранной теме
        didSet {
            applyTheme(selectedTheme)
        }
    }
    // MARK: связываем начало загрузки
    func startLoading() {
        isLoading.value = true
    }
    // MARK: связываем окончание загрузки
    func stopLoading() {
        isLoading.value = false
    }
    // MARK: обработка нажатия кнопки Настройки
    func handleSettingsButtonTapped() {
        onSettingsButtonTapped?()
       }
    // MARK: применение темы
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
    // MARK: запуск лоадера
    func startLoader() {
        mainModel?.loader.startAnimating()
        mainModel?.loader.isHidden = false
    }
    // MARK: остановка лоадера
    func stopLoader() {
        mainModel?.loader.stopAnimating()
        mainModel?.loader.isHidden = true
    }
}

import XCTest

final class ImageFeedUITests: XCTestCase {
    @MainActor
    func testAuth() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Кнопка входа
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
        authButton.tap()
        
        // WebView
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        // Логин
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        loginTextField.tap()
        Thread.sleep(forTimeInterval: 1)
        loginTextField.typeText(" ")
        
        // Пароль
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        passwordTextField.tap()
        Thread.sleep(forTimeInterval: 1)
        
        // Вставка пароля из буфера обмена
        UIPasteboard.general.string = " "
        passwordTextField.press(forDuration: 1.0)
        
        let pasteMenuItem = app.menuItems["Paste"]
        XCTAssertTrue(pasteMenuItem.waitForExistence(timeout: 2))
        pasteMenuItem.tap()
        
        webView.swipeUp()
        
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5))
        loginButton.tap()
        
        // Проверка, что перешли на экран ленты
        let feedTable = app.tables.firstMatch
        XCTAssertTrue(feedTable.waitForExistence(timeout: 10))
        
    }
    
    @MainActor
    func testFeed() throws {
        let app = XCUIApplication()
        app.launch()
        
        let feedTable = app.tables["ImagesListTable"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 10), "Таблица ленты не загрузилась")
        
        feedTable.swipeUp()
        
        let firstCell = feedTable.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Верхняя ячейка не найдена")

        let likeButtonOff = firstCell.buttons["like button off"]
        XCTAssertTrue(likeButtonOff.waitForExistence(timeout: 5), "Кнопка лайка (off) не найдена")
        likeButtonOff.tap()

        let likeButtonOn = firstCell.buttons["like button on"]
        XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 5), "Кнопка лайка (on) не появилась после нажатия")
        likeButtonOn.tap()

        let cellImage = firstCell.images.firstMatch
        XCTAssertTrue(cellImage.waitForExistence(timeout: 5), "Изображение в ячейке не найдено")
        cellImage.tap()

        let fullScreenImage = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(fullScreenImage.waitForExistence(timeout: 5), "Полноэкранное изображение не появилось")

        fullScreenImage.pinch(withScale: 3.0, velocity: 1.0)

        fullScreenImage.pinch(withScale: 0.5, velocity: -1.0)

        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка 'Назад' не найдена")
        backButton.tap()

        XCTAssertTrue(feedTable.waitForExistence(timeout: 5), "Не удалось вернуться на экран ленты")
    }
    
    @MainActor
    func testProfile() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Переход на экран профиля через TabBar по индексу
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.exists)
        profileTab.tap()
        
        // Проверить персональные данные
        let nameLabel = app.staticTexts["Name"]
        let loginLabel = app.staticTexts["Login"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(loginLabel.waitForExistence(timeout: 5))
        
        // Нажать кнопку логаута
        let logoutButton = app.buttons["Logout"]
        XCTAssertTrue(logoutButton.exists)
        logoutButton.tap()
        
        // Подтвердить выход
        let confirmLogoutButton = app.alerts["LogoutAlert"].scrollViews.otherElements.buttons["Yes"]
        XCTAssertTrue(confirmLogoutButton.waitForExistence(timeout: 5))
        confirmLogoutButton.tap()
        
        // Проверить, что открылся экран авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5))
    }
}

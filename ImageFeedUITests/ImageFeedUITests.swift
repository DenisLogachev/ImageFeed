import XCTest

final class ImageFeedUITests: XCTestCase {
    @MainActor
    func testAuth() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Нажать кнопку авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка авторизации не найдена")
        authButton.tap()
        
        // 2. Подождать, пока экран авторизации открывается и загружается
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10), "Экран авторизации не загрузился")
        
        // 3. Ввести данные в форму
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5), "Поле логина не найдено")
        loginTextField.tap()
        Thread.sleep(forTimeInterval: 1)
        loginTextField.typeText("_")
        
        app.toolbars.buttons["Done"].tap()
        Thread.sleep(forTimeInterval: 1)
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5), "Поле пароля не найдено")
        
        Thread.sleep(forTimeInterval: 1)
        passwordTextField.tap()
        Thread.sleep(forTimeInterval: 1)
        
        passwordTextField.typeText("_")
        
        app.toolbars.buttons["Done"].tap()
        Thread.sleep(forTimeInterval: 1)
        
        // 4. Нажать кнопку логина
        webView.swipeUp()
        let loginButton = webView.buttons["Login"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 5), "Кнопка логина не найдена")
        loginButton.tap()
        
        // 5. Подождать, пока открывается экран ленты
        let feedTable = app.tables["ImagesListTable"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 10), "Экран ленты не загрузился")
    }
    
    @MainActor
    func testFeed() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Подождать, пока открывается и загружается экран ленты
        let feedTable = app.tables["ImagesListTable"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 10), "Таблица ленты не загрузилась")
        
        // 2. Сделать жест «смахивания» вверх по экрану для его скролла
        feedTable.swipeUp()
        
        // 3. Поставить лайк в ячейке верхней картинки
        let firstCell = feedTable.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5), "Первая ячейка не найдена")
        
        let likeButton = firstCell.buttons.firstMatch
        XCTAssertTrue(likeButton.waitForExistence(timeout: 5), "Кнопка лайка не найдена")
        
        Thread.sleep(forTimeInterval: 1)
        likeButton.tap()
        
        // 4. Отменить лайк в ячейке верхней картинки
        let updatedLikeButton = firstCell.buttons.firstMatch
        XCTAssertTrue(updatedLikeButton.waitForExistence(timeout: 5), "Обновлённая кнопка лайка не найдена")
        XCTAssertTrue(updatedLikeButton.isHittable, "Обновленная кнопка лайка недоступна")
        
        Thread.sleep(forTimeInterval: 1)
        updatedLikeButton.tap()
        
        // 5. Нажать на верхнюю ячейку
        firstCell.tap()
        
        // 6. Подождать, пока картинка открывается на весь экран
        let fullScreenImage = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(fullScreenImage.waitForExistence(timeout: 5), "Изображение не найдено")
        
        // 7. Увеличить картинку
        fullScreenImage.pinch(withScale: 3, velocity: 1)
        
        // 8. Уменьшить картинку
        fullScreenImage.pinch(withScale: 0.5, velocity: -1)
        
        // 9. Вернуться на экран ленты
        let backButton = app.buttons["BackButton"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5), "Кнопка назад не найдена")
        backButton.tap()
        XCTAssertTrue(feedTable.waitForExistence(timeout: 5), "Не вернулись на экран ленты")
    }
    
    @MainActor
    func testProfile() throws {
        let app = XCUIApplication()
        app.launch()
        
        // 1. Подождать, пока открывается и загружается экран ленты
        let feedTable = app.tables["ImagesListTable"]
        XCTAssertTrue(feedTable.waitForExistence(timeout: 10), "Экран ленты не загрузился")
        
        // 2. Перейти на экран профиля
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5), "Кнопка профиля не найдена")
        profileTab.tap()
        
        // 3. Проверить, что на нём отображаются ваши персональные данные
        let nameLabel = app.staticTexts["Name"]
        let loginLabel = app.staticTexts["Login"]
        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5), "Имя пользователя не отображается")
        XCTAssertTrue(loginLabel.waitForExistence(timeout: 5), "Логин пользователя не отображается")
        
        // 4. Нажать кнопку логаута
        let logoutButton = app.buttons["Logout"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5), "Кнопка выхода не найдена")
        logoutButton.tap()
        
        let confirmLogoutButton = app.alerts["LogoutAlert"].scrollViews.otherElements.buttons["Yes"]
        XCTAssertTrue(confirmLogoutButton.waitForExistence(timeout: 5), "Кнопка подтверждения выхода не найдена")
        confirmLogoutButton.tap()
        
        // 5. Проверить, что открылся экран авторизации
        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Экран авторизации не открылся")
    }
}

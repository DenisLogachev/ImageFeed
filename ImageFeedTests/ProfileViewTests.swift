import XCTest
@testable import ImageFeed
import UIKit

final class ProfileViewControllerTests: XCTestCase {

    class MockPresenter: ProfilePresenterProtocol {
        weak var view: ProfileViewProtocol?
        var viewDidLoadCalled = false
        var didTapLogoutButtonCalled = false
        var logoutConfirmedCalled = false

        func viewDidLoad() {
            viewDidLoadCalled = true
        }

        func didTapLogoutButton() {
            didTapLogoutButtonCalled = true
        }
        
        func logoutConfirmed() {
            logoutConfirmedCalled = true
        }
    }

    var sut: ProfileViewController!
    var mockPresenter: MockPresenter!

    override func setUp() {
        super.setUp()
        sut = ProfileViewController()
        mockPresenter = MockPresenter()
        sut.configure(mockPresenter)
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        sut = nil
        mockPresenter = nil
        super.tearDown()
    }

    func testViewDidLoad_CallsPresenterViewDidLoad() {
        sut.viewDidLoad()
        XCTAssertTrue(mockPresenter.viewDidLoadCalled, "viewDidLoad() должен вызвать presenter.viewDidLoad()")
    }

    func testDisplayProfile_UpdatesLabels() {
        let testName = "Test Name"
        let testLogin = "@testlogin"
        let testBio = "Test bio"

        sut.displayProfile(name: testName, loginName: testLogin, bio: testBio)

        XCTAssertEqual(sut.nameLabel.text, testName)
        XCTAssertEqual(sut.loginNameLabel.text, testLogin)
        XCTAssertEqual(sut.descriptionLabel.text, testBio)
    }

    func testDisplayAvatar_SetsPlaceholderWhenURLIsNil() {
        sut.displayAvatar(url: nil)
        XCTAssertNotNil(sut.avatarImageView.image)
    }

    func testLogoutButtonTap_CallsPresenterDidTapLogoutButton() {
        sut.didTapLogoutButton()
        XCTAssertTrue(mockPresenter.didTapLogoutButtonCalled, "Нажатие кнопки выхода должно вызвать presenter.didTapLogoutButton()")
    }

    func testShowLogoutConfirmation_PresentsAlert() {
        // Given
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = sut
        window.makeKeyAndVisible()
        
        // When
        sut.showLogoutConfirmation()
        
        // Then
        XCTAssertTrue(sut.presentedViewController is UIAlertController)
        let alert = sut.presentedViewController as? UIAlertController
        XCTAssertEqual(alert?.title, "Пока, пока!")
        XCTAssertEqual(alert?.message, "Уверены, что хотите выйти?")
        XCTAssertEqual(alert?.actions.count, 2)
        XCTAssertEqual(alert?.actions[0].title, "Нет")
        XCTAssertEqual(alert?.actions[1].title, "Да")
    }
}

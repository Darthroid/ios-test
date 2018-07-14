//
//  ThemeableSpec.swift
//  Rocket.ChatTests
//
//  Created by Samar Sunkaria on 5/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class ThemeableSpec: XCTestCase {

    class MockThemeableView: UIView {
        var themeApplied = false

        override func applyTheme() {
            super.applyTheme()
            themeApplied = true
        }

        override var theme: Theme? { return internalTheme }
        var internalTheme: Theme? = Theme.light
    }

    func testApplyThemeCalledOnSubview() {
        let view = MockThemeableView()
        let subview = MockThemeableView()
        view.addSubview(subview)
        view.applyTheme()
        XCTAssert(subview.themeApplied, "Apply theme should be called on subview.")
    }

    func testSettingThemeOnSuperview() {
        let view = MockThemeableView()
        let subview = UIView()
        view.addSubview(subview)
        view.internalTheme = .dark
        XCTAssertEqual(subview.theme, view.internalTheme, "View should acquire its superview's theme.")
    }

    func testSettingThemeOnSubview() {
        let view = UIView()
        let subview = MockThemeableView()
        view.addSubview(subview)
        subview.internalTheme = nil
        XCTAssertNil(subview.theme, "View should be able to override its parent's theme.")
    }

    func testNotThemeableView() {
        let view = NotThemeableView()
        XCTAssertNil(view.theme, "NotThemeableView should have a nil theme.")
    }

    func testApplyThemeOnViewController() {
        let controller = UIViewController()
        let view = MockThemeableView()
        controller.view.addSubview(view)
        controller.applyTheme()
        XCTAssert(view.themeApplied, "View controller should call applyTheme on its view.")
    }

    func testBaseViewController() {
        let controller = BaseViewController()
        controller.viewDidLoad()
        XCTAssert(ThemeManager.observers.contains { $0.value === controller }, "BaseViewController should add itself as an observer")
    }
}

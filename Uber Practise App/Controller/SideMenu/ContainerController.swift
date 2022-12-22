//
//  ContainerController.swift
//  Uber Practise App
//
//  Created by Shubham on 12/23/22.
//

import UIKit

class ContainerController: UIViewController {
    // MARK: - Properties
    private let homeController = HomeViewController()
    private let menuController = MenuController()
    private final var isShowingSideMenu = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHomeController()
        configureMenuController()
    }

    // MARK: - Selectors
    
    // MARK: - Helper Functions
    func configureHomeController(){
        // This is how you add child controller to another controller
        addChild(homeController)
        homeController.didMove(toParent: self)
        view.addSubview(homeController.view)
        homeController.delegate = self
    }
    
    func configureMenuController() {
        addChild(menuController)
        menuController.didMove(toParent: self)
        view.insertSubview(menuController.view, at: 0)
    }
    
    func animateMenu(shouldExpand: Bool) {
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut ,animations: {
                self.homeController.view.frame.origin.x = self.view.frame.width - 80.0
            }, completion: nil)
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut ,animations: {
                self.homeController.view.frame.origin.x = 0.0
            }, completion: nil)
        }
    }
}

extension ContainerController: HomeViewControllerDelegate {
    func handleMenuToggle() {
        isShowingSideMenu.toggle()
        animateMenu(shouldExpand: isShowingSideMenu)
    }
}

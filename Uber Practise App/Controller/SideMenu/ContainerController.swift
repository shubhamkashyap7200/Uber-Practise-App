//
//  ContainerController.swift
//  Uber Practise App
//
//  Created by Shubham on 12/23/22.
//

import UIKit
import FirebaseAuth

class ContainerController: UIViewController {
    // MARK: - Properties
    private let homeController = HomeViewController()
    private var menuController: MenuController!
    private final var isShowingSideMenu = false
    private var user: User? {
        didSet {
            guard let user = user else { return }
            homeController.user = user
            configureMenuController(withUser: user)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .backgroundColor
        fetchUserData()
        configureHomeController()
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
    
    func configureMenuController(withUser user: User) {
        menuController = MenuController(user: user)
        addChild(menuController)
        menuController.view.frame = CGRect(x: 0, y: 40, width: self.view.frame.width, height: self.view.frame.height - 40)
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
    
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { print("Current uid is nil"); return }
        Service.shared.fetchUserData(uid: uid) { (user) in
            self.user = user
        }
    }

}

extension ContainerController: HomeViewControllerDelegate {
    func handleMenuToggle() {
        isShowingSideMenu.toggle()
        animateMenu(shouldExpand: isShowingSideMenu)
    }
}

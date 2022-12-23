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
    private let deepShadeView = UIView()
    private lazy var xOrigin = view.frame.width - 80.0

    
    private var user: User? {
        didSet {
            guard let user = user else { return }
            homeController.user = user
            configureMenuController(withUser: user)
        }
    }
    
    // MARK: - Lifecycle
    override var prefersStatusBarHidden: Bool {
        return isShowingSideMenu
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DEBUG:: This is logged in")
        checkIfUserIsLoggedIn()
    }

    // MARK: - Selectors
    @objc func dismissMenu() {
        isShowingSideMenu = false
        animateMenu(shouldExpand: isShowingSideMenu)
    }
    
    // MARK: - API
    func checkIfUserIsLoggedIn() {
        let currentUser = Auth.auth().currentUser // Getting current user
        if currentUser?.uid == nil {
            // Navigating to login controller
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                if #available(iOS 13.0, *) {
                    nav.isModalInPresentation = true
                }
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
        else {
            print("DEBUG: User is LOGGED in...")
            print("DEBUG: User id is ::: \(currentUser?.uid)")
            configureAll()
        }
    }

    // MARK: - Helper Functions
    func configureDeepShadeView() {
        deepShadeView.frame = CGRect(x: xOrigin, y: 0, width: 80, height: self.view.frame.height)
        deepShadeView.backgroundColor = .black.withAlphaComponent(0.25)
        deepShadeView.alpha = 0.0
        view.addSubview(deepShadeView)
        
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(dismissMenu))
        deepShadeView.addGestureRecognizer(tap)
    }
    
    func configureAll() {
        view.backgroundColor = .backgroundColor
        fetchUserData()
        configureHomeController()
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            let navLogin = UINavigationController(rootViewController: LoginController())
            navLogin.modalPresentationStyle = .fullScreen
            present(navLogin, animated: true)
        }
        catch {
            print("DEBUG: Error in Signout is here ::: \(error.localizedDescription)")
        }
    }

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
        menuController.delegate = self
        view.insertSubview(menuController.view, at: 0)
    }
    
    func animateMenu(shouldExpand: Bool, completion: ((Bool) -> Void)? = nil) {
        if shouldExpand {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut ,animations: {
                self.homeController.view.frame.origin.x = self.xOrigin
            }) { _ in
                UIView.animate(withDuration: 0.3) {
                    self.deepShadeView.alpha = 1.0
                }
            }
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut ,animations: {
                self.homeController.view.frame.origin.x = 0.0
                self.deepShadeView.alpha = 0.0
            }, completion: completion)
        }
        
        animateStatusBar()
    }
    
    func animateStatusBar() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    func fetchUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { print("Current uid is nil"); return }
        Service.shared.fetchUserData(uid: uid) { (user) in
            self.user = user
        }
    }

}

// MARK: - HomeViewControllerDelegate

extension ContainerController: HomeViewControllerDelegate {
    func handleMenuToggle() {
        isShowingSideMenu.toggle()
        configureDeepShadeView()
        animateMenu(shouldExpand: isShowingSideMenu)
    }
}


// MARK: - MenuControllerDelegate

extension ContainerController: MenuControllerDelegate {
    func didSelectOption(option: MenuOptions) {
        isShowingSideMenu.toggle()
        print("DEBUG:: PRESSED :: \(isShowingSideMenu)")

        animateMenu(shouldExpand: isShowingSideMenu) { _ in
            switch option {
            case .yourTrips:
                break
            case .settings:
                break
            case .logout:
                print("DEBUG:: PRESSED")
                let alert = UIAlertController(title: nil, message: "Are you sure you want to logout ?", preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { _ in
                    self.signOut()
                }))
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                self.present(alert, animated: true)

            }
        }
    }
}

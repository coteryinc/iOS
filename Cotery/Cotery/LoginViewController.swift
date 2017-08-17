//
//  LoginViewController.swift
//  Cotery
//
//  Created by Kenneth Chen on 7/11/17.
//  Copyright © 2017 Cotery. All rights reserved.
//
import UIKit
import AccountKit
import FBSDKCoreKit
import FBSDKLoginKit

// MARK: - LoginViewController: UIViewController

final class LoginViewController: UIViewController {
    
    // MARK: Properties
    
    fileprivate var accountKit = AKFAccountKit(responseType: .accessToken)
    fileprivate var dataEntryViewController: AKFViewController? = nil
    fileprivate var showAccountOnAppear = false
    
//    // MARK: Outlets
//    
//    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    // MARK: View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showAccountOnAppear = accountKit.currentAccessToken != nil
        dataEntryViewController = accountKit.viewControllerForLoginResume() as? AKFViewController
        
        // Facebook Login
        
//        // Create the login button
//        let loginButton = FBSDKLoginButton()
//        loginButton.center = view.center
//        loginButton.delegate = self
//        view.addSubview(loginButton)
//
//        // Check if user is logged in
//        if ((FBSDKAccessToken.current()) != nil) {
//            presentWithSegueIdentifier("showAccount", animated: false)
//        }
//        
//        // Set read permissions
//        loginButton.readPermissions = ["public_profile"]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if showAccountOnAppear {
            showAccountOnAppear = false
            presentWithSegueIdentifier("showAccount", animated: animated)
        } else if let viewController = dataEntryViewController {
            if let viewController = viewController as? UIViewController {
                present(viewController, animated: animated, completion: nil)
                dataEntryViewController = nil
            }
        }

        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: Actions
    
    @IBAction func loginWithPhone(_ sender: AnyObject) {
        FBSDKAppEvents.logEvent("loginWithPhone clicked")
        if let viewController = accountKit.viewControllerForPhoneLogin() as? AKFViewController {
            prepareDataEntryViewController(viewController)
            if let viewController = viewController as? UIViewController {
                present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginWithEmail(_ sender: AnyObject) {
        FBSDKAppEvents.logEvent("loginWithEmail clicked")
        if let viewController = accountKit.viewControllerForEmailLogin() as? AKFViewController {
            prepareDataEntryViewController(viewController)
            if let viewController = viewController as? UIViewController {
                present(viewController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func loginWithFacebook(_ sender: Any) {
        let readPermissions = ["public_profile"]
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: readPermissions, from: self) { (result, error) in
            if ((error) != nil){
                print("login failed with error: \(String(describing: error))")
            } else if (result?.isCancelled)! {
                print("login cancelled")
            } else {
                //present the account view controller
                self.presentWithSegueIdentifier("showAccount",animated: true)
            }
        }
    }
    
    @IBAction func requestMorePermissions(_ sender: Any) {
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        
        fbLoginManager.logIn(withReadPermissions: ["user_friends"], from: self)
        { (result, error) in
            
            if let error = error {
                print("Login failed with error: \(error)")
            } else if (result?.isCancelled)!{
                print("permission request cancelled")
            } else {
                let grantedPermissions = result?.grantedPermissions
                
                // Request the data you have been granted permission to access
                
            }
        }
    }
    
    // MARK: Helper Methods
    func prepareDataEntryViewController(_ viewController: AKFViewController){
        viewController.delegate = self
    }
    
    fileprivate func presentWithSegueIdentifier(_ segueIdentifier: String, animated: Bool) {
        if animated {
            performSegue(withIdentifier: segueIdentifier, sender: nil)
        } else {
            UIView.performWithoutAnimation {
                self.performSegue(withIdentifier: segueIdentifier, sender: nil)
            }
        }
    }
}

// MARK: - LoginViewController: AKFViewControllerDelegate
extension LoginViewController: AKFViewControllerDelegate {
    func viewController(_ viewController: UIViewController!, didCompleteLoginWith accessToken: AKFAccessToken, state: String!) {
        presentWithSegueIdentifier("showAccount", animated: false)
    }
    
    func viewController(_ viewController: UIViewController, didFailWithError error: Error!) {
        print("\(viewController) did fail with error: \(error)")
    }
}

// MARK: - LoginViewController: FBSDKLoginButtonDelegate
extension LoginViewController: FBSDKLoginButtonDelegate {
    
    public func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith
        result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print("Login failed with error: \(error)")
        }
        
        // The FBSDKAccessToken is expected to be available, so we can navigate
        // to the account view controller
        if result.token != nil {
            presentWithSegueIdentifier("showAccount", animated: true)
        }
    }
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // On logout, we just remain on the login view controller
    }
}


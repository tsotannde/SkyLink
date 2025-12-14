//
//  NavigationManager.swift
//  SkyLink
//
//  Created by Adebayo Sotannde on 10/22/25.
//
//

    import UIKit
    @_exported import Hero

    class NavigationManager
    {
        static let shared = NavigationManager()
        
        private init() {}
        
        func toggleNavigationBar(on navigationController: UINavigationController?, animated: Bool = false, shouldShow: Bool = true)
        {
            navigationController?.setNavigationBarHidden(!shouldShow, animated: animated)
        }
       
        func navigate(to viewController: UIViewController,on navigationController: UINavigationController?,clearStack: Bool = true,animation: HeroDefaultAnimationType? = nil)
        {
            if let animation = animation
            {
                navigationController?.hero.isEnabled = true
                navigationController?.hero.navigationAnimationType = animation
            }
            
            if clearStack
            {
                navigationController?.setViewControllers([viewController], animated: true)
            } else
            {
                navigationController?.pushViewController(viewController, animated: true)
            }
        }
        
        func dismiss(to viewController: UIViewController? = nil,on navigationController: UINavigationController?,animation: HeroDefaultAnimationType? = nil,animated: Bool = true)
        {
            guard let navigationController = navigationController else { return }

            if let animation = animation
            {
                navigationController.hero.isEnabled = true
                navigationController.hero.navigationAnimationType = animation
            }

            if let viewController = viewController,
               navigationController.viewControllers.contains(viewController)
            {
                navigationController.popToViewController(viewController, animated: animated)
            }
            else
            {
                navigationController.popToRootViewController(animated: animated)
            }
        }
    }

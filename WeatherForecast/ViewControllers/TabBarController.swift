//
//  TabBarController.swift
//  WeatherForecast
//
//  Created by Maxim Kucherov on 24/11/2023.
//

import UIKit

protocol TabBarBadgeDelegate: AnyObject {
    func updateTabBarBadge(count: Int)
}

class TabBarController: UITabBarController {
    
//    static let shared = TabBarController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabs()
        setupUI()
    }
    
    // MARK: - Tab Setup
    private func setupTabs() {
        let map = createNav(with: NSLocalizedString("Map", comment: ""), and: UIImage(systemName: "map"), vc: MapViewController())
        let search = createNav(with: NSLocalizedString("Search", comment: ""), and: UIImage(systemName: "magnifyingglass"), vc: SearchViewController(delegate: self))
        let favorites = createNav(with: NSLocalizedString("Favorites", comment: ""), and: UIImage(systemName: "star"), vc: FavoritesViewController(delegate: self))
    
        // Устанавливаем делегата
        if let mapViewController = map.viewControllers.first as? MapViewController {
            mapViewController.delegate = self
        }
        if let selectedVC = self.selectedViewController as? SearchViewController {
            selectedVC.delegate = self
        }
        if let selectedVC = self.selectedViewController as? FavoritesViewController {
            selectedVC.delegate = self
        }
        
        setViewControllers([map, search, favorites], animated: true)
    }
    
    private func createNav(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nc = UINavigationController(rootViewController: vc)
        nc.tabBarItem.title = title
        nc.tabBarItem.image = image
        
        if !(vc is MapViewController) {
            vc.navigationItem.title = title
        }
        nc.navigationBar.prefersLargeTitles = true
        nc.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        return nc
    }
    
    private func setupUI() {
        tabBar.barTintColor = .black
        tabBar.tintColor = .purple
        tabBar.unselectedItemTintColor = .gray
        tabBar.isTranslucent = false
    }
}

extension TabBarController: TabBarBadgeDelegate {
    func updateTabBarBadge(count: Int) {
        tabBar.items?[2].badgeValue = count > 0 ? "\(count)" : nil
    }
}

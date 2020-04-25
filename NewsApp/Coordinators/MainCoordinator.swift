//
//  MainCoordinator.swift
//  NewsApp
//
//  Created by Macbook Pro 15 on 4/24/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        setupNavigationController()
    }
    
    func start() {
        let vc = HomeVC.instantiate() //we can do this because of HomeVC conformed to Storyboarded protocol
        vc.coordinator = self //assign vc's coordinator to self
        navigationController.pushViewController(vc, animated: false)
    }
    
    func goToNewsList(category: String) {
        let vc = NewsListVC.instantiate()
        vc.coordinator = self
        vc.category = category //must pass category instead so back button on details will have category name as its back button
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToNewsDetails(article: Article) {
        let vc = NewsDetailVC.instantiate()
        vc.coordinator = self
        vc.title = article.title
        vc.article = article
        navigationController.pushViewController(vc, animated: true)
    }
    
    fileprivate func setupNavigationController() {
        self.navigationController.isNavigationBarHidden = false
        self.navigationController.navigationBar.prefersLargeTitles = true
//        navigationController.navigationBar.tintColor = SettingsService.shared.grayColor //button color
//        navigationController.setStatusBarColor(backgroundColor: kMAINCOLOR)
    }
}

//
//  NewsDetailVC.swift
//  NewsApp
//
//  Created by Macbook Pro 15 on 4/23/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class NewsDetailVC: UIViewController, Storyboarded {
    
//MARK: Properties
    weak var coordinator: MainCoordinator?
    var article: Article?
    
//MARK: Views
    
    
//MARK: App LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupViews()
    }

//MARK: Private Methods
    fileprivate func setupViews() {
        
    }
    
//MARK: IBActions
    
    
//MARK: Helper Methods

}

//MARK: Extensions

//
//  HomeVC.swift
//  NewsApp
//
//  Created by Macbook Pro 15 on 4/23/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, Storyboarded {
    
//MARK: Properties
    weak var coordinator: MainCoordinator?
    lazy var sections: [Section] = [
        TitleSection(title: "Categories"),
        ImageSection(categories: Category.allCases),
        TitleSection(title: "Countries"),
        LabelSection(titles: Country.allCases.map { $0.rawValue }), //since titles is an array of String, we need to map allCases to its rawValue
        TitleSection(title: "Languages"),
        LabelSection(titles: Language.allCases.map { $0.rawValue }),
        TitleSection(title: "Sources"),
//        LabelSection(titles: sources.filter{ $0.name} )
        LabelSection(titles: [] ) //create an array of sources name from sources
    ]
    lazy var collectionViewLayout: UICollectionViewLayout = {
        var sections = self.sections
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            return sections[sectionIndex].layoutSection()
        }
        return layout
    }()
    var sources: [Source] = [] {
        didSet {
            sections[7] = LabelSection(titles: sources.map{ $0.name } ) //create an array of sources name from sources
            collectionView.reloadData()
        }
    }
    
//MARK: Views
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
//MARK: App LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

//MARK: Private Methods
    fileprivate func setupViews() {
        self.title = "News Stand"
        setupCollectionView()
        setupSearchBar()
        NetworkManager.fetchSources { (result) in
            DispatchQueue.main.async {
                switch result {
                case let .success(sources):
                    self.sources.append(contentsOf: sources)
//                    for source in self.sources {
//                        print(source)
//                    }
                case let .failure(error):
                    Service.presentAlert(on: self, title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    fileprivate func setupSearchBar() {
        searchBar.searchTextField.delegate = self
        searchBar.searchTextField.placeholder = "Search for News"
        searchBar.returnKeyType = .search
    }
    
    fileprivate func setupCollectionView() {
        collectionView.collectionViewLayout = collectionViewLayout
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
//        collectionView.register(CategoryCell.self, forCellWithReuseIdentifier: String(describing: CategoryCell.self)) //no need since it's inside collectionView's story
        collectionView.register(UINib(nibName: TitleCell.identifier, bundle: .main), forCellWithReuseIdentifier: TitleCell.identifier)
        collectionView.register(UINib(nibName: ImageCell.identifier, bundle: .main), forCellWithReuseIdentifier: ImageCell.identifier)
        collectionView.register(UINib(nibName: LabelCell.identifier, bundle: .main), forCellWithReuseIdentifier: LabelCell.identifier)
    }
    
//MARK: IBActions
    
    
//MARK: Helper Methods

}

//MARK: Extensions

//MARK: CollectionView Delegate Extension
extension HomeVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell: CategoryCell = collectionView.cellForItem(at: indexPath) as! CategoryCell //to initialize the cell
        switch indexPath.section {
        case 1: //categories
            let section = sections[indexPath.section] as! ImageSection
            let category = section.categories[indexPath.row]
            let vcTitle = Category.allCases[indexPath.row].rawValue + " News"
            coordinator?.goToNewsList(endpoint: .category, vcTitle: vcTitle, parameters: [kCATEGORY: category.rawValue])
        case 3: //countries
//            let section = sections[indexPath.section] as! LabelSection
//            let country = section.titles[indexPath.row]
            let country = String(describing: Country.allCases[indexPath.row]) //convert enum case to string
            let vcTitle = Country.allCases[indexPath.row].rawValue + " News"
            coordinator?.goToNewsList(endpoint: .country, vcTitle: vcTitle, parameters: [kCOUNTRY: country])
        case 5: //languages
            let language = String(describing: Language.allCases[indexPath.row])
            let vcTitle = Language.allCases[indexPath.row].rawValue + " News"
            coordinator?.goToNewsList(endpoint: .language, vcTitle: vcTitle, parameters: [kLANGUAGE: language])
        case 7: //languages
            let source = String(describing: sources[indexPath.row])
//            let vcTitle = Language.allCases[indexPath.row].rawValue + " News"
            coordinator?.goToNewsList(endpoint: .language, vcTitle: source, parameters: [kSOURCES: source])
        default: //titles
            break
        }
    }
}

//MARK: CollectionView Data Source Extension
extension HomeVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch sections[indexPath.section] {
//        case is TitleSection:
//            let section = sections[indexPath.section] as! TitleSection
//            return section.configureCell(collectionView: collectionView, indexPath: indexPath)
//        case is ImageSection:
//            let section = sections[indexPath.section] as! ImageSection
//            return section.configureCell(collectionView: collectionView, indexPath: indexPath)
//        case is LabelSection:
//            let section = sections[indexPath.section] as! LabelSection
//            return section.configureCell(collectionView: collectionView, indexPath: indexPath)
//        default:
//            return sections[indexPath.section].configureCell(collectionView: collectionView, indexPath: indexPath)
//        }
        switch indexPath.section {
        case 0,2,4,6: //title sections
            let section = sections[indexPath.section] as! TitleSection
            return section.configureCell(collectionView: collectionView, indexPath: indexPath)
        case 1: //category
            let section = sections[indexPath.section] as! ImageSection
            return section.configureCell(collectionView: collectionView, indexPath: indexPath)
        case 3:
            let section = sections[indexPath.section] as! LabelSection
            return section.configureCell(collectionView: collectionView, indexPath: indexPath)
        case 5:
            let section = sections[indexPath.section] as! LabelSection
            return section.configureCell(collectionView: collectionView, indexPath: indexPath)
        case 7:
            let section = sections[indexPath.section] as! LabelSection
            return section.configureCell(collectionView: collectionView, indexPath: indexPath)
        default:
            return sections[indexPath.section].configureCell(collectionView: collectionView, indexPath: indexPath)
        }
    }
}

// MARK: - Search bar functions
extension HomeVC: UISearchTextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text != nil {
            coordinator?.goToNewsList(endpoint: .articles, vcTitle: "\(textField.text!) News", parameters: [kQ: textField.text!])
        }
        return true
    }
}

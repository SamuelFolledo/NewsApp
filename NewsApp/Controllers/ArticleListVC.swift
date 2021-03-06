//
//  ArticleListVC.swift
//  NewsApp
//
//  Created by Macbook Pro 15 on 4/23/20.
//  Copyright © 2020 SamuelFolledo. All rights reserved.
//

import UIKit
import Kingfisher

class ArticleListVC: UIViewController, Storyboarded {
    
//MARK: Properties
    weak var coordinator: MainCoordinator?
    var articles: [Article] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var endpoint: EndPoints!
    var page: Int = 1
    
//MARK: Views
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var sortButton: UIButton!
    @IBOutlet weak var sortTable: UITableView!
    @IBOutlet weak var fromButton: UIButton!
    @IBOutlet weak var fromTable: UITableView!
    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var toTable: UITableView!
    @IBOutlet weak var filterButtonsStackView: UIStackView!
    
//MARK: App LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getArticles()
    }

//MARK: Private Methods
    fileprivate func setupViews() {
        setupSearchBar()
        setupTableView()
        switch endpoint {
        case .articles, .language: //show filter buttons for /everything endpoint
            filterButtonsStackView.isHidden = false
        default:
            filterButtonsStackView.isHidden = true
        }
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.showsVerticalScrollIndicator = false
        tableView.tableFooterView = UIView()
        sortTable.delegate = self
        sortTable.dataSource = self
        sortTable.isHidden = true
        sortTable.showsVerticalScrollIndicator = false
        fromTable.delegate = self
        fromTable.dataSource = self
        fromTable.isHidden = true
        fromTable.showsVerticalScrollIndicator = false
        toTable.delegate = self
        toTable.dataSource = self
        toTable.isHidden = true
        toTable.showsVerticalScrollIndicator = false
//        tableView.register(NewsCell.self, forCellReuseIdentifier: String(describing: NewsCell.self)) //not needed if cell is created in storyboard
    }
    
    fileprivate func setupSearchBar() {
        searchBar.searchTextField.delegate = self
        searchBar.searchTextField.placeholder = "Search for Articles"
        searchBar.returnKeyType = .search
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let flexibleBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.handleDismissTap(_:)))
        toolBar.setItems([flexibleBar, doneButton], animated: true)
        searchBar.searchTextField.inputAccessoryView = toolBar
        searchBar.searchTextField.clearButtonMode = .always
    }
    
    func getArticles() {
        activityIndicator.shouldAnimate()
        NetworkManager.fetchNewsApi(endpoint: endpoint, parameters: [kPAGE: "\(page)"]) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(articles):
                    self.articles.append(contentsOf: articles)
                    self.activityIndicator.shouldAnimate(shouldAnimate: false)
                case let .failure(error):
                    Service.presentAlert(on: self, title: "Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    func updateParamsThenFetch(parameters: [String: String]) {
        NetworkManager.updateParameters(parameters: parameters)
        self.page = 1 //reset page
        self.articles.removeAll()
        self.tableView.reloadData()
        getArticles()
    }
    
//MARK: IBActions
    @IBAction func filterButtonsTapped(_ sender: UIButton) {
        switch sender {
        case sortButton:
            toggleButtonTables(shouldShow: sortTable.isHidden, type: sortButton) //show if table is hidden
        case fromButton:
            toggleButtonTables(shouldShow: fromTable.isHidden, type: fromButton)
        case toButton:
            toggleButtonTables(shouldShow: toTable.isHidden, type: toButton)
        default:
            break
        }
    }
    
    
//MARK: Helper Methods
    ///Hide all tables or show table depending on the UIButton selected
    fileprivate func toggleButtonTables(shouldShow: Bool, type: UIButton? = nil) {
        self.searchBar.resignFirstResponder()
        if shouldShow {
            UIView.animate(withDuration: 0.2) {
                switch type {
                case self.sortButton:
                    self.sortTable.isHidden = false
                case self.fromButton:
                    self.fromTable.isHidden = false
                case self.toButton:
                    self.toTable.isHidden = false
                default:
                    break
                }
            }
        } else { //hide everything
            UIView.animate(withDuration: 0.2) {
                self.sortTable.isHidden = true
                self.fromTable.isHidden = true
                self.toTable.isHidden = true
            }
        }
    }
    
    @objc func handleDismissTap(_ gesture: UITapGestureRecognizer) { //dismiss fields
        self.view.endEditing(false)
    }
    
    ///Ensures that fromDate is before toDate
//    func checkSelectedDate(tableView: UITableView, indexPath: IndexPath) {
//        switch tableView {
//        case fromTable:
//            print("from \(indexPath.row) \(toTable.indexPathForSelectedRow!.row)")
//        case toTable:
//            print("to \(indexPath.row) \(fromTable.indexPathForSelectedRow!.row)")
//        default:
//            break
//        }
//    }
}

//MARK: Extensions
extension ArticleListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case self.tableView: //article list
            let article = articles[indexPath.row]
            coordinator?.goToNewsDetails(article: article)
        case sortTable:
            let sortBy = SortByOptions.allCases[indexPath.row]
            sortButton.setTitle("Sort By: \(sortBy)", for: .normal) //update button's title by the selected cell
            toggleButtonTables(shouldShow: false, type: sortButton)
            updateParamsThenFetch(parameters: [kSORTBY: sortBy.asSortByParameter])
        case fromTable:
            let fromDate = DateOptions.fromAllCases[indexPath.row] //not include now case
//            checkSelectedDate(tableView: tableView, indexPath: indexPath)
            fromButton.setTitle("Past: \(fromDate.rawValue)", for: .normal)
            toggleButtonTables(shouldShow: false, type: fromButton)
            updateParamsThenFetch(parameters: [kFROM: fromDate.asDateParameter])
        case toTable:
            let toDate = DateOptions.allCases[indexPath.row]
//            checkSelectedDate(tableView: tableView, indexPath: indexPath)
            toButton.setTitle("Until: \(toDate.rawValue)", for: .normal)
            toggleButtonTables(shouldShow: false, type: toButton)
            updateParamsThenFetch(parameters: [kTO: toDate.asDateParameter])
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case self.tableView: //article list
            return 100
        case sortTable, fromTable, toTable:
            return 30
        default:
            return 0
        }
    }
}

extension ArticleListVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.tableView: //article list
            return articles.count
        case sortTable:
            return SortByOptions.allCases.count
        case fromTable:
            return DateOptions.fromAllCases.count //fromAllCase does not include now case
        case toTable:
            return DateOptions.allCases.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case self.tableView: //article list
            let cell: ArticleCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ArticleCell.self), for: indexPath) as! ArticleCell
            let article = articles[indexPath.row]
            cell.populateViews(article: article)
            if indexPath.row == articles.count - 1 && indexPath.row < NetworkManager.totalCount - 1 { //if last cell and it's not the last article, get more articles
                self.page += 1 //increment page
                getArticles()
            }
            return cell
        case sortTable:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "sortCell", for: indexPath)
            cell.textLabel?.text = SortByOptions.allCases[indexPath.row].rawValue
            cell.textLabel?.textAlignment = .center
            if indexPath.row == 1 { tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle) } //indicate selected cell on load
            return cell
        case fromTable:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "fromCell", for: indexPath)
            cell.textLabel?.text = DateOptions.fromAllCases[indexPath.row].rawValue //not include now case
            cell.textLabel?.textAlignment = .center
            if indexPath.row == 2 { tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle) } //indicate selected cell on load
            return cell
        case toTable:
            let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "toCell", for: indexPath)
            cell.textLabel?.text = DateOptions.allCases[indexPath.row].rawValue
            cell.textLabel?.textAlignment = .center
            if indexPath.row == 0 { tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle) } //indicate selected cell on load
            return cell
        default:
            return UITableViewCell()
        }
    }
}

// MARK: - Search bar functions
extension ArticleListVC: UISearchTextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if !textField.text!.isEmpty { //if textfield is not empty
            self.title = textField.text! //update title
            sortButton.setTitle("Sort By: Relevancy", for: .normal) //change sort to relevancy as it will be closer to the textField input
            let indexPath = IndexPath(row: 2, section: 0) //relevancy's index
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            updateParamsThenFetch(parameters: [kQ: textField.text!, kSORTBY: SortByOptions.relevancy.asSortByParameter])
        }
        return true
    }
}

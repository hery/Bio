//
//  ViewController.swift
//  Bio
//
//  Created by Hery Ratsimihah on 9/18/17.
//  Copyright © 2017 Ratsimihah. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

extension ViewController {
    func darkGrey() -> UIColor {
        return UIColor(colorLiteralRed: 36/255,
                       green: 36/255,
                       blue: 36/255,
                       alpha: 1.0)
    }
}

class ViewController: UIViewController {

    private let cellId = "cell"
    private let topMargin:CGFloat = 20.0

    private var dataSource: Variable<[Car]>?
    private let viewModel = ViewModel()



    let tableView = UITableView()

    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.frame = CGRect(x: 0,
                                 y: topMargin,
                                 width: self.view.frame.width,
                                 height: self.view.frame.height-topMargin)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableHeaderView = self.tableViewHeader()
        self.setUpDataSource()
        viewModel.initSocket()
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UI
    func tableViewHeader() -> UIView {
        let headerLabel = UILabel()
        headerLabel.frame.size = CGSize(width: UIScreen.main.bounds.size.width, height: 50)
        headerLabel.text = "Tap a car to start it"
        headerLabel.textAlignment = .center
        return headerLabel
    }

    // MARK: Data Source
    func setUpDataSource() {
        viewModel.carsList.asObservable().bind(to: tableView.rx.items(cellIdentifier: cellId)) { (row, car, cell) in
            let brand = car.brand != nil ? car.brand! : "Unknown brand"
            let name = car.name != nil ? car.name! : "Unknown model"
            cell.textLabel?.text = "\(brand) \(name)"
            }.disposed(by: viewModel.disposeBag)
    }

}


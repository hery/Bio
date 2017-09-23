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

extension UIColor {
    class func darkGrey() -> UIColor {
        // # 242424
        return UIColor(colorLiteralRed: 36/255,
                       green: 36/255,
                       blue: 36/255,
                       alpha: 1.0)
    }

    class func lightGrey() -> UIColor {
        // # 424242
        return UIColor(colorLiteralRed: 66/255,
                       green: 66/255,
                       blue: 66/255,
                       alpha: 1.0)
    }
}

class ViewController: UIViewController {

    private let cellId = "cell"

    private var dataSource: Variable<[Car]>?
    private let viewModel = ViewModel()

    let tableView = UITableView()

    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(tableView)
        tableView.frame = CGRect(x: 0,
                                 y: 0,
                                 width: self.view.frame.width,
                                 height: self.view.frame.height)
        tableView.register(CarTableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.delegate = self
        tableView.tableHeaderView = self.tableViewHeader()
        tableView.separatorColor = UIColor.lightGrey()
        self.setUpDataSource()
        self.observeCarSelection()
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
        headerLabel.backgroundColor = UIColor.darkGrey()
        headerLabel.frame.size = CGSize(width: UIScreen.main.bounds.size.width, height: 50)
        headerLabel.textColor = UIColor.white
        headerLabel.text = "Tap a car to start it"
        headerLabel.textAlignment = .center
        return headerLabel
    }

    // MARK: Data Source
    func setUpDataSource() {
        viewModel.carsList.asObservable().bind(to: tableView.rx.items(cellIdentifier: cellId)) { (row, car, cell) in
            let cell = cell as? CarTableViewCell
            cell?.carLabel.text = car.description()
            cell?.carLabel.textColor = UIColor.darkGrey()
            cell?.speedLabel.text = car.speed()
       }.disposed(by: viewModel.disposeBag)
    }

    func observeCarSelection() {
        tableView.rx.itemSelected.asObservable().subscribe(onNext: { (row) in
            if row.row >= self.viewModel.carsList.value.count {
                print("Invalid index \(row)")
            }
            let car = self.viewModel.carsList.value[row.row]
            if let name = car.name {
                print("Starting car \(car.description())")
                self.viewModel.startCar(name)
            } else {
                print("Missing name for car \(car). Can't start it.")
            }
            print("Disposed item selection observer")
        }).disposed(by: viewModel.disposeBag)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Can this be done reactively?
        return 80
    }
}


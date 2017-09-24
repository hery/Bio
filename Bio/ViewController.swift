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
        headerLabel.frame.size = CGSize(width: UIScreen.main.bounds.size.width, height: 80)
        headerLabel.font = UIFont.systemFont(ofSize: 13)
        headerLabel.textColor = UIColor.white
        headerLabel.text = "Tap a car to start it, tap again to stop it,\n or tap here to stop the last started car."
        headerLabel.textAlignment = .center
        headerLabel.numberOfLines = 0
        headerLabel.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer()
        headerLabel.addGestureRecognizer(tapGesture)
        tapGesture.rx.event.bind { (_) in
            self.viewModel.stopLastCar()
        }.disposed(by: viewModel.disposeBag)

        return headerLabel
    }

    // MARK: Data Source
    func setUpDataSource() {
        viewModel.carsList.asObservable().bind(to: tableView.rx.items(cellIdentifier: cellId)) { (row, car, cell) in
            let cell = cell as? CarTableViewCell
            cell?.selectionStyle = .none
            cell?.carLabel.text = car.description()
            cell?.carLabel.textColor = UIColor.darkGrey()
            cell?.speedLabel.text = car.speed()
            let status = car.started ? "RUNNING" : "STOPPED"
            let statusColor = car.started ? UIColor.green : UIColor.lightGrey()
            cell?.statusLabel.backgroundColor = statusColor
            cell?.statusLabel.setTitle(status, for: .normal)

       }
       .disposed(by: viewModel.disposeBag)
    }

    func observeCarSelection() {
        tableView.rx.itemSelected.asObservable().subscribe(onNext: { (row) in
            if row.row >= self.viewModel.carsList.value.count {
                print("Invalid index \(row)")
            }
            let car = self.viewModel.carsList.value[row.row]
            print("--> Selected car \(car.description()), started: \(car.started)")
            // If the car we selected is already running,
            // We just stop it.
            if car.started {
                self.viewModel.stopLastCar()
            } else {
            // If a car is currently running,
            // startCar will stop it and start the selected one.
                self.viewModel.startCar(car)
            }
            Car.printCarsDescription(self.viewModel.carsList.value)
        }).disposed(by: viewModel.disposeBag)
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Can this be done reactively?
        return 80
    }
}


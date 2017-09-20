//
//  ViewController.swift
//  Bio
//
//  Created by Hery Ratsimihah on 9/18/17.
//  Copyright © 2017 Ratsimihah. All rights reserved.
//

import UIKit

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
    private var dataSource: [Dictionary<String, Any>]?
    private let viewModel = ViewModel()

    let tableView = UITableView()


    // MARK: VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.viewController = self
        viewModel.initSocket()

        self.view.addSubview(tableView)
        tableView.frame = CGRect(x: 0,
                                 y: topMargin,
                                 width: self.view.frame.width,
                                 height: self.view.frame.height-topMargin)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}


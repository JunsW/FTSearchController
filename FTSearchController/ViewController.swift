//
//  ViewController.swift
//  FTSearchController
//
//  Created by 王俊硕 on 2018/3/18.
//  Copyright © 2018年 王俊硕. All rights reserved.
//

import UIKit

class ViewController: FTSearchController {

    
    var models: [String] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Demo"
        
        contentDelegate = self
        (1...19).forEach() {
            models.append(String($0))
        }
        contentView.showsVerticalScrollIndicator = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let backgroundColor = UIColor(hex: 0xffffd9)
        let tintColor = UIColor(hex: 0x603125)
        let blue = UIColor(hex: 0x2D5AE4)
        textFieldTextColor = .yellow
        textFieldBackgroundColor = .red
        
        attributedPlaceholder = NSAttributedString(string: "请输入内容", attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
//        navigationController?.navigationBar.barTintColor = .blue
//        barBackgroundColor = .blue
        universalBackgoundColor = backgroundColor
        
        cursorAndCancelButtonColor = tintColor
        leftIconColor = .white
        rightIconColor = .white
        cancelButtonTitle = "好的"
        hideBorderLines = true
        cencelButtonAttributedTitle = NSAttributedString(string: "确定", attributes: [NSAttributedStringKey.foregroundColor : blue, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)])
    }

}

extension ViewController: FTSearchControllerDataProvider {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = models[indexPath.row]
        return cell
    }
    func updateSearchResults(for searchController: UISearchController) {
        print("Updating")
    }

}



//
//  ResultTableViewController.swift
//  exifdemo-ios
//
//  Created by Farrux Hewson on 07/03/2020.
//  Copyright © 2020 bakerystud. All rights reserved.
//

import UIKit

class ResultTableViewController: UITableViewController {

    var data: [ImageModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Count: \(data.count)")
        print("Filtered Array: \(data)")
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultTabelViewCell", for: indexPath) as! ResultTableViewCell
        let index = data[indexPath.row].index
        let imageModel = data[indexPath.row]
        
        cell.usersPhotoLabel.text = "Ваше фото: \(DatabaseManager.shared.allNames[index])"
        cell.friendsPhotoLabel.text = "Фото друга: \(imageModel.name)"
        cell.coordinatesLabel.text = "Lat: \(imageModel.lat.rounded(toPlaces: 4)), Lon: \(imageModel.lon.rounded(toPlaces: 4))"
        cell.timeLabel.text = "\(imageModel.time)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(self.view.frame.height * 0.07)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Всего похожих фотографий: \(data.count)"
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.textLabel?.textAlignment = NSTextAlignment.center
    }
}

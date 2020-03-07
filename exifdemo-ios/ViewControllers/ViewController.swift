//
//  ViewController.swift
//  exifdemo-ios
//
//  Created by Farrux Hewson on 06/03/2020.
//  Copyright © 2020 bakerystud. All rights reserved.
//

import UIKit
import Photos
import CoreLocation
import Firebase

class ViewController: UIViewController {
    
    // UI
    @IBOutlet var usersIdLabel: UILabel!
    @IBOutlet var friendsId: UITextField!
    
    @IBOutlet var loadingView: UIView!
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var loadingLabel: UILabel!
    
    var ref: DatabaseReference!
    var fetchStatus = 0 // 0 - Default, 1 - Fetched all photos
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup UI
        hideKeyboardWhenTappedAround()
        usersIdLabel.text = DatabaseManager.shared.getDeviceID()
        loadingView.layer.cornerRadius = 12
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if(fetchStatus == 0){
            // Check photo library permission
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case PHAuthorizationStatus.authorized:
                fetchAllPhotos()
            case PHAuthorizationStatus.notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if (newStatus == PHAuthorizationStatus.authorized) {
                        self.fetchAllPhotos()
                    }else{
                        self.showMessage(Message: "Пожалуйста, предоставьте разрешение на доступ к вашим фотографиям!", type: 1)
                    }
                })
            case PHAuthorizationStatus.restricted:
                self.showMessage(Message: "Пожалуйста, предоставьте разрешение на доступ к вашим фотографиям!", type: 1)
            default:
                self.showMessage(Message: "Пожалуйста, предоставьте разрешение на доступ к вашим фотографиям!", type: 1)
            }
        }
    }
    
    @IBAction func CopyId(_ sender: Any) {
        UIPasteboard.general.string = usersIdLabel.text
    }
    
    @IBAction func find(_ sender: Any) {
        if(friendsId.text?.isEmpty == false){
            loadingLabel.text = "ПРОВЕРКА ДАННЫХ"
            changeIndicatorState(state: 1)
            DatabaseManager.shared.findSimilarities(id: friendsId.text!, completionHandler: { filteredArray in
                self.changeIndicatorState(state: 0)
                if(filteredArray.count > 0){
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateViewController(withIdentifier: "resultTabelViewController") as! ResultTableViewController
                    controller.data = filteredArray
                    self.present(controller, animated: true, completion: nil)
                }else{
                    self.showMessage(Message: "Похоже что у вас с другом нет похожих фотографий.", type: 0)
                }
            })
        }else{
            self.showMessage(Message: "Пожайлуста введите ID вашего друга.", type: 0)
        }
    }
    
    
    func changeIndicatorState(state: Int){ // 1 - Loading, 0 - Hide
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingView.alpha = CGFloat(state)
        }, completion: { _ in
            if(state == 1){
                self.loadingIndicator.startAnimating()
            }else{
                self.loadingIndicator.stopAnimating()
            }
        })
    }
    
    private func fetchAllPhotos() {
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .fastFormat
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let results: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        if results.count > 0 {
            loadingLabel.text = "ВЫГРУЗКА ДАННЫХ НА СЕРВЕР"
            changeIndicatorState(state: 1)
            for i in 0..<results.count {
                let asset = results.object(at: i)
                if let phototLocation = asset.location {
                    DatabaseManager.shared.allAssets.append(asset)
                    DatabaseManager.shared.allNames.append(asset.originalFilename!)
                    DatabaseManager.shared.allLocations.append(phototLocation.coordinate)
                    DatabaseManager.shared.allDates.append(asset.creationDate!.timeIntervalSince1970)
                }else{
                    print("\(i) hasn't got GPS information.")
                }
            }
        } else {
            showMessage(Message: "У вас нет фотографий!", type: 0)
        }
        
        print(DatabaseManager.shared.allNames)
        print(DatabaseManager.shared.allDates)
        print(DatabaseManager.shared.allLocations)
        sendToDatabase()
    }
    
    private func sendToDatabase(){
        DatabaseManager.shared.sortArrays(completionHandler: {
            self.fetchStatus = 1
            self.changeIndicatorState(state: 0)
        })
    }
    
    func showMessage(Message: String, type: Int){ // 0 - Default message, 1 - Permission
        let alert = UIAlertController(title: Message, message: "", preferredStyle: UIAlertController.Style.alert)
        
        if(type == 0){
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        }else{
            alert.addAction(UIAlertAction(title: "Отмена", style: UIAlertAction.Style.cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Перейдите в настройки", style: UIAlertAction.Style.default, handler: { _ in
                if let url = URL.init(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
        }
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}


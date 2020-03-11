//
//  DatabaseManager.swift
//  exifdemo-ios
//
//  Created by Farrux Hewson on 06/03/2020.
//  Copyright © 2020 bakerystud. All rights reserved.
//

import Foundation
import Photos
import CoreLocation
import Firebase

class DatabaseManager {

    static let shared = DatabaseManager()

    var ref: DatabaseReference!
    var deviceID = ""

    // Arrays
    var allAssets: [[PHAsset]] = []
    var allURLs: [[URL]] = []
    var allNames: [[String]] = []
    var allDates: [Double] = []
    var allLocations: [CLLocationCoordinate2D] = []

    func getDeviceID() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }

    func sortArrays(completionHandler: @escaping (() -> Void)) {
        let sortGroup = DispatchGroup()
        ref = Database.database().reference()
        deviceID = UIDevice.current.identifierForVendor!.uuidString

        for i in 0..<self.allAssets.count {
            self.allURLs.append([])
            sortGroup.enter()
            getUrls(assets: allAssets[i], index: i, completionHandler: {
                print("Completed")
            })
            sortGroup.leave()
        }
        

        // When all sorted
        sortGroup.notify(queue: .main) {
            completionHandler()
        }
    }

    func getUrls(assets: [PHAsset], index: Int, completionHandler: @escaping (() -> Void)) {
        let urlGroup = DispatchGroup()
        for i in 0..<assets.count {
            urlGroup.enter()
            assets[i].getURL(completionHandler: { [weak self] url in
                if let url = url {
                    self?.allURLs[index].append(url)
                    self?.addToDatabase(index: index, subIndex: i, url: url)
                }
                
                urlGroup.leave()
            })
        }

        // When loop finished
        urlGroup.notify(queue: .main) {
            completionHandler()
        }
    }

    func addToDatabase(index: Int, subIndex: Int, url: URL) {
        ref.child("\(deviceID)/\(allNames[index][subIndex])/gps").setValue(["latitude": allLocations[index].latitude, "longitude": allLocations[index].longitude])
        ref.child("\(deviceID)/\(allNames[index][subIndex])/path").setValue(url.absoluteString)
        ref.child("\(deviceID)/\(allNames[index][subIndex])/time").setValue(allDates[index])
    }

    func findSimilarities(id: String, completionHandler: @escaping ((_ filteredArray: [ImageModel]) -> Void)) {
        ref.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            let responseDictionary = snapshot.value as? NSDictionary
            var responseImages = [ImageModel]()

            if (responseDictionary != nil) {
                for (key, value) in responseDictionary! {
                    let main = value as! NSDictionary
                    if (main["gps"] == nil) {
                        continue
                    }
                    let gps = main.value(forKey: "gps") as! NSDictionary

                    let lat = gps.value(forKey: "latitude") as! Double
                    let lon = gps.value(forKey: "longitude") as! Double
                    let time = main.value(forKey: "time") as! Double

                    responseImages.append(ImageModel(name: ["\(key)"], url: [nil], friendsImageNames: "", lon: lon, lat: lat, time: time))
                }
            }

            completionHandler(self.filter(inputArray: responseImages))
        })
    }

    private func filter(inputArray: [ImageModel]) -> [ImageModel] {
        var outputArray = [ImageModel]()
        for i in 0..<allNames.count {
            let l1 = CLLocation(latitude: allLocations[i].latitude, longitude: allLocations[i].longitude)
            let fArray: Array<ImageModel> = inputArray.filter {
                let distanceFit: Bool = l1.distance(from: CLLocation(latitude: $0.lat, longitude: $0.lon)) < 100
                let timeDifference: Double = abs($0.time - allDates[i])
                let timeFit = timeDifference < 3 * 60 * 60 * 1000.0
                let b: Bool = distanceFit &&
                        timeFit
                return b
            }
            if fArray.count > 0 {
                let friendsImageNames = fArray.map {
                    $0.name[0]
                }
                outputArray.append(ImageModel(name: allNames[i], url: allURLs[i], friendsImageNames: friendsImageNames.joined(separator: "\n"), lon: fArray[0].lon, lat: fArray[0].lat, time: fArray[0].time))
            }
        }
        return outputArray
    }

    func checkRecordings() {
        ref.child(deviceID).observeSingleEvent(of: .value, with: { (snapshot) in
            print("DB: \(snapshot.value ?? "No Recording")")
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

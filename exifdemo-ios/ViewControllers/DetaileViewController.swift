//
//  DetaileViewController.swift
//  exifdemo-ios
//
//  Created by Farrux Hewson on 08/03/2020.
//  Copyright © 2020 bakerystud. All rights reserved.
//

import UIKit

class DetaileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var friendsPhotoLabel: UILabel!
    @IBOutlet weak var coordinatesLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var photosTableView: UITableView!
    
    var imageData: ImageModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        friendsPhotoLabel.text = "Фотографи(я/и) вашего друга:\n\(imageData.friendsImageNames ?? "")"
        coordinatesLabel.text = "Lat: \(imageData.lat.rounded(toPlaces: 4)), Lon: \(imageData.lon.rounded(toPlaces: 4))"
        timeLabel.text = "\(imageData.time)"
        
        photosTableView.delegate = self
        photosTableView.dataSource = self
    }
    
    // Load image from URL with downsample
    private func load(imageAt imageURL: URL, to pointSize: CGSize, scale: CGFloat) -> UIImage {
       let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
       let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOptions)!
     
       let maxDimentionInPixels = max(pointSize.width, pointSize.height) * scale
     
       let downsampledOptions = [kCGImageSourceCreateThumbnailFromImageAlways: true,
     kCGImageSourceShouldCacheImmediately: true,
     kCGImageSourceCreateThumbnailWithTransform: true,
     kCGImageSourceThumbnailMaxPixelSize: maxDimentionInPixels] as CFDictionary
      let downsampledImage =     CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampledOptions)!
     
       return UIImage(cgImage: downsampledImage)
    }
    
    // Table View Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imageData.url.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "detaileTableViewCell", for: indexPath) as! DetaileTableViewCell
        
        cell.mainLabel.text = imageData.name[indexPath.row]
        cell.mainImage.image = load(imageAt: imageData.url[indexPath.row]!, to: CGSize(width: 512, height: 256), scale: 0.5)
        
        return cell
    }
    
}

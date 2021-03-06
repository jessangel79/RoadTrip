//
//  ListPlacesTableViewCell.swift
//  RoadTrip
//
//  Created by Angelique Babin on 13/02/2020.
//  Copyright © 2020 Angelique Babin. All rights reserved.
//

import UIKit
import SDWebImage

final class ListPlacesTableViewCell: UITableViewCell {
    
    // MARK: - Outlets

    @IBOutlet private weak var placeImageView: UIImageView!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var addressLabel: UILabel!
    @IBOutlet private weak var openLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var priceLevelLabel: UILabel!
    @IBOutlet private weak var ratingLabel: UILabel!
    @IBOutlet private weak var ratingView: UIView!
    @IBOutlet private var allLabels: [UILabel]!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Methods

    override func awakeFromNib() {
        super.awakeFromNib()
        customLabelsCell(labels: allLabels, radius: 5, width: 1.0, colorBackground: #colorLiteral(red: 0.7009438452, green: 0.7009438452, blue: 0.7009438452, alpha: 0.6988976884), colorBorder: UIColor.gray)
        customViewCell(view: ratingView)
    }
    
    var place: Result? {
        didSet {
            nameLabel.text = place?.name
            addressLabel.text = place?.formattedAddress
            openLabel.text = openResult(place?.openingHours?.openNow)
            loadIcon(imageString: place?.icon)
            priceLevelLabel.text = priceLevelString(place?.priceLevel ?? 0)
            ratingLabel.text = String(place?.rating ?? 0.0)
            let photo = place?.photos ?? [Photo]()
            configPhoto(photo)
        }
    }
    
    var placeEntity: PlaceEntity? {
        didSet {
            nameLabel.text = placeEntity?.name
            addressLabel.text = placeEntity?.address
            openLabel.text = openEntity(placeEntity?.openNow ?? false, placeEntity?.openDays ?? "")
            loadIcon(imageString: placeEntity?.icon)
            priceLevelLabel.text = priceLevelString(Int(placeEntity?.priceLevel ?? 0))
            ratingLabel.text = String(placeEntity?.rating ?? 0.0)
            let photo = placeEntity?.photo
            getPhotos(photoReference: photo)
        }
    }
    
    private func configPhoto(_ photo: [Photo]) {
        var photoReference = String()
        if !photo.isEmpty {
            for photoRef in photo {
                photoReference = photoRef.photoReference
            }
        } else {
            photoReference = String()
        }
        getPhotos(photoReference: photoReference)
    }
    
    private func loadIcon(imageString: String?) {
        guard let url = URL(string: imageString ?? "") else { return }
        DispatchQueue.main.async {
            self.iconImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "europe.png"))
        }
    }
    
    /// get photos with SDWebimage to load photos of places
    private func getPhotos(photoReference: String?) {
        let apiKey = valueForAPIKey(named: Constants.PlacesAPIKey)
        let placeholderImage = UIImage(named: "bruges-maison-blanche-belgique_1024x768.jpg")
        guard let photoReference = photoReference else { return }
        let stringUrl = "https://maps.googleapis.com/maps/api/place/photo?key=\(apiKey)&maxwidth=800&height=600&photoreference=\(photoReference)"
        toggleActivityIndicator(shown: true, activityIndicator: activityIndicator, imageView: placeImageView)
        DispatchQueue.main.async {
            self.toggleActivityIndicator(shown: false, activityIndicator: self.activityIndicator, imageView: self.placeImageView)
            self.placeImageView.sd_setImage(with: URL(string: stringUrl), placeholderImage: placeholderImage)
        }
    }
    
    private func openResult(_ openNow: Bool?) -> String? {
        switch openNow {
        case true:
            return Constants.open
        case false:
            return Constants.closed
        default:
            return Constants.noa
        }
    }
    
    private func openEntity(_ openNow: Bool, _ openDays: String) -> String? {
         if openNow {
            return Constants.open
         } else if !openNow && openDays != "N/A" {
            return Constants.closed
         } else {
            return Constants.noa
         }
     }
    
    private func priceLevelString(_ priceLevel: Int) -> String? {
        switch priceLevel {
        case 1:
            return PriceLevel.oneE.priceLevel()
        case 2:
            return PriceLevel.twoE.priceLevel()
        case 3:
            return PriceLevel.threeE.priceLevel()
        case 4:
            return PriceLevel.fourE.priceLevel()
        default:
            return PriceLevel.noa.priceLevel()
        }
    }

}

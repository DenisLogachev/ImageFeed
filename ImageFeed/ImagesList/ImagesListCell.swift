import UIKit

final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet var gradientView: UIView!
    
    private var gradientLayer: CAGradientLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if gradientLayer == nil {
            let layer = CAGradientLayer()
            layer.colors = [
                UIColor.clear.cgColor,
                UIColor(white: 0.1, alpha: 0.8).cgColor
            ]
            layer.locations = [0, 1]
            gradientView.layer.addSublayer(layer)
            gradientLayer = layer
        }
        
        gradientLayer?.frame = gradientView.bounds
        bringSubviewToFront(dateLabel)
    }
}

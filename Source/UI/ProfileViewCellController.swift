import UIKit
import Material

class ProfileViewCellController : ViewController {
   
    @IBOutlet weak var emblemImageView: UIImageView!
    @IBOutlet weak var rivalIdLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var designationLabel: UILabel!
    
    override func prepare() {
        super.prepare()
        
        let myUserData = GlobalUserDataStorage.instance.queryMyUserData()
        guard let myPlayDataPageCache = myUserData.playDataPageCache as? UserData.MyPlayDataPageCache else {
            return
        }
        
        rivalIdLabel.text = "RIVAL ID: \(myPlayDataPageCache.rivalId)"
        nicknameLabel.text = myPlayDataPageCache.nickname
        designationLabel.text = myPlayDataPageCache.designation
        emblemImageView.image = myPlayDataPageCache.emblemImage
    }
}

extension ProfileViewCellController {
    private func prepareEmblemImage(emblemImage: UIImage) {
        
    }
}

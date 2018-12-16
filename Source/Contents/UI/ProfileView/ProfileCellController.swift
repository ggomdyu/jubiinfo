import UIKit
import Material
import Motion

class ProfileCellController : LazyPreparedViewController {
   
    @IBOutlet weak var emblemImageView: UIImageView!
    @IBOutlet weak var rivalIdLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var designationLabel: UILabel!
    @IBOutlet weak var contentsView: UIView!
    
    override func prepare() {
        super.prepare()

        contentsView.alpha = 0.0
        emblemImageView.alpha = 0.0
    }
    
    open override func lazyPrepare(_ param: Any?) {
        super.lazyPrepare(param)
        
        let myUserData = GlobalUserDataStorage.instance.queryMyUserData()
        guard let myPlayDataPageCache = myUserData.playDataPageCache as? UserData.MyPlayDataPageCache else {
            return
        }
        
        self.prepareEmblemImage(myPlayDataPageCache: myPlayDataPageCache)
        
        self.rivalIdLabel.text = "RIVAL ID: \(myPlayDataPageCache.rivalId)"
        self.nicknameLabel.text = myPlayDataPageCache.nickname
        self.designationLabel.text = myPlayDataPageCache.designation
        
        self.contentsView.animate(.fadeIn)
    }
    
    open override func getEventNameRequiredToLazyPrepare() -> String {
        return "requestMyPlayDataComplete"
    }
}

extension ProfileCellController {
    /**@brief   Download the emblem image and set it to the user cache. */
    private func prepareEmblemImage(myPlayDataPageCache: UserData.MyPlayDataPageCache) {
        downloadImageAsync(imageUrl: myPlayDataPageCache.emblemImageUrl, onDownloadComplete: { (isDownloadSucceed: Bool, image: UIImage?) in
            if (isDownloadSucceed) {
                runTaskInMainThread {
                    self.emblemImageView.image = image
                }
                
                myPlayDataPageCache.emblemImage = image
                
                self.emblemImageView.animate(.fadeIn)
            }
        })
    }
}

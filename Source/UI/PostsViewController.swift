import UIKit
import Material

class ProfileViewCellController : UIViewController {
   
    var rivalIdLabel = UILabel()
    var nicknameLabel = UILabel()
    var designationLabel = UILabel()
//    var emblemImage: UIImage
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareRivalIdLabel(rivalId: "60930004873801")
        self.prepareNicknameLabel(nickname: "GGOMDYU")
        self.prepareDesignationLabel(designation: "おはようございます")
    }
}

extension ProfileViewCellController {
    private func prepareRivalIdLabel(rivalId: String) {
        let rgbColor: CGFloat = 153 / 255
        rivalIdLabel.textColor = UIColor(red: rgbColor, green: rgbColor, blue: rgbColor, alpha: 1)
        
        rivalIdLabel.fontSize = 9
        rivalIdLabel.text = "RIVAL ID: \(rivalId)"
        
        view.layout(rivalIdLabel).center()
    }
    
    private func prepareNicknameLabel(nickname: String) {
        
    }
    
    private func prepareDesignationLabel(designation: String) {
        
    }
    
    private func prepareEmblemImage(emblemImage: UIImage) {
        
    }
}

//class PostsViewController: UIViewController {
//  fileprivate var category: String
//
//  fileprivate var graph: Graph!
//  fileprivate var search: Search<Entity>!
//
//  fileprivate var data: [Entity] {
//    guard let category = search.sync().first else {
//      return [Entity]()
//    }
//
//    let posts = category.relationship(types: "Post").subject(types: "Article")
//
//    return posts.sorted { (a, b) -> Bool in
//      return a.createdDate < b.createdDate
//    }
//  }
//
//  fileprivate var tableView: CardTableView!
//
//  required init?(coder aDecoder: NSCoder) {
//    category = ""
//    super.init(coder: aDecoder)
//    prepareTabItem()
//  }
//
//  init(category: String) {
//    self.category = category
//    super.init(nibName: nil, bundle: nil)
//    prepareTabItem()
//  }
//
//  open override func viewDidLoad() {
//    super.viewDidLoad()
//    view.backgroundColor = Color.blueGrey.lighten5
//
//    // Model.
//    prepareGraph()
//    prepareSearch()
//
//    // Feed.
//    prepareTableView()
//  }
//
//  open override func viewDidAppear(_ animated: Bool) {
//    super.viewDidAppear(animated)
//    reloadData()
//  }
//
//  open override func viewWillLayoutSubviews() {
//    super.viewWillLayoutSubviews()
//    reloadData()
//  }
//}
//
//fileprivate extension PostsViewController {
//  func prepareGraph() {
//    graph = Graph()
//  }
//
//  func prepareSearch() {
//    search = Search<Entity>(graph: graph).for(types: "Category").where(properties: ("name", category))
//  }
//
//  func prepareTabItem() {
//    tabItem.title = category
//    tabItem.setTitleColor(Color.grey.darken3, for: .selected)
//    tabItem.setTitleColor(Color.grey.base, for: .normal)
//  }
//
//  func prepareTableView() {
//    tableView = CardTableView()
//    view.layout(tableView).edges()
//  }
//
//  func reloadData() {
//    tableView.data = data
//  }
//}

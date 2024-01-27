import UIKit

final class CategoryViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
    }
}


//MARK: - NavigationController
extension CategoryViewController {
    
    func setupNavigationController() {
        navigationController?.view.backgroundColor = .hdWhite
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Категория"
    }
}

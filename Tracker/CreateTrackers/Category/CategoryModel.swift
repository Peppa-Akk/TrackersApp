import UIKit

final class CategoryModel: Identifiable {
    
    let idCategory: UUID
    private let title: String
    
    init(idCategory: UUID, title: String) {
        self.idCategory = idCategory
        self.title = title
    }
    
    var titleBinding: Binding<String>? {
        didSet {
            titleBinding?(title)
        }
    }
    
    func getCategory() -> TrackerCategory {
        
        return TrackerCategory(
            id: self.idCategory,
            title: self.title,
            trackers: []
        )
    }
}

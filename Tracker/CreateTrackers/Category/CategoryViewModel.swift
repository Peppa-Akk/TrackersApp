import Foundation

final class CategoryViewModel {
    
    private let categoryStore: CategoryStore
    
    private (set) var categoryList: [CategoryModel] = [] {
        didSet {
            categoryBinding?(categoryList)
        }
    }
    
    var categoryBinding: Binding<[CategoryModel]>?
    
    init(categoryStore: CategoryStore) {
        
        self.categoryStore = categoryStore
        categoryStore.delegate = self
        categoryList = getCategoryList()
    }
    
    convenience init() {
        self.init(categoryStore: CategoryStore())
    }
    
    func addNewCategory(_ category: TrackerCategory) {
        
        try! categoryStore.addNewCategory(category)
    }
    
    private func getCategoryList() -> [CategoryModel] {
        
        return categoryStore.collection.map({
            CategoryModel(
                idCategory: $0.id,
                title: $0.title
            )
        })
    }
}

extension CategoryViewModel: StoreDelegate {
    
    func didUpdate() {
        categoryList = getCategoryList()
        print(categoryList.count)
    }
}

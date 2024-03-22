import UIKit

final class CategoryCell: UITableViewCell {
    
    static let reuseIdentifier = "CategoryCell"
    let title = UILabel()
    
    var viewModel: CategoryModel! {
        didSet {
            viewModel.titleBinding = { [weak self] title in
                self?.title.text = title
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        activateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        viewModel.titleBinding = nil
    }
}


//MARK: - Add UI-Elements on View
extension CategoryCell {
    
    private func activateUI() {
        
        backgroundColor = .hdBackground
        addLabelOnView()
        layer.cornerRadius = 16
        clipsToBounds = true
    }
    
    private func addLabelOnView() {
        
        title.font = .systemFont(ofSize: 17, weight: .regular)
        title.textColor = .hdBlack
        contentView.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            title.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

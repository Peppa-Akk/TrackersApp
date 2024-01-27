import UIKit

final class ButtonCell: UITableViewCell {
    
    static let reuseIdentifier = "ButtonCell"
    let title = UILabel()
    let subTitle = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        activateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Add UI-Elements on View
extension ButtonCell {
    
    private func activateUI() {
        
        backgroundColor = .hdBackground
        addLabelOnView()
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
    
    private func addSubLabelOnView() {
        
        subTitle.font = .systemFont(ofSize: 17, weight: .regular)
        subTitle.textColor = .hdGray
        subTitle.isHidden = true
        contentView.addSubview(subTitle)
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            subTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            subTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
}

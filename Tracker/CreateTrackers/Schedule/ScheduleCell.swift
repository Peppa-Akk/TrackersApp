import UIKit

final class ScheduleCell: UITableViewCell {
    
    static let reuseIdentifier = "ScheduleCell"
    let title = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        activateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Add UI-Elements on View
extension ScheduleCell {
    
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
}

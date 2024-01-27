import UIKit

final class EmojisCell: UICollectionViewCell {
    
    static let identifier = "EmojiCell"
    
    let cellView = UIView()
    let emojiLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        activateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add UI-Elements on View
extension EmojisCell {
    
    private func activateUI() {
        addCellView()
        addEmojiLabel()
    }
    
    private func addCellView() {
        cellView.layer.cornerRadius = 16
        cellView.layer.masksToBounds = true
        contentView.addSubview(cellView)
        cellView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cellView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellView.widthAnchor.constraint(equalToConstant: 46),
            cellView.heightAnchor.constraint(equalToConstant: 46)
        ])
    }
    
    private func addEmojiLabel() {
        emojiLabel.font = .systemFont(ofSize: 32, weight: .bold)
        cellView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: cellView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: cellView.centerYAnchor)
        ])
    }
}

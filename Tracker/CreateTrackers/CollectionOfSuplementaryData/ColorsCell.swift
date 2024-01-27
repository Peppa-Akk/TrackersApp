import UIKit

final class ColorsCell: UICollectionViewCell {
    
    static let identifier = "ColorCell"
    
    let cellView = UIView()
    let selectionView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        activateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Add UI-Elements on View
extension ColorsCell {
    
    private func activateUI() {
        addCellView()
        addSelectionView()
    }
    
    private func addCellView() {
        cellView.layer.cornerRadius = 8
        cellView.layer.masksToBounds = true
        contentView.addSubview(cellView)
        cellView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellView.centerXAnchor.constraint(equalTo: centerXAnchor),
            cellView.centerYAnchor.constraint(equalTo: centerYAnchor),
            cellView.widthAnchor.constraint(equalToConstant: 40),
            cellView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func addSelectionView() {
        selectionView.layer.opacity = 0.3
        selectionView.layer.cornerRadius = 8
        selectionView.layer.borderWidth = 3
        selectionView.layer.masksToBounds = true
        contentView.addSubview(selectionView)
        selectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            selectionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectionView.widthAnchor.constraint(equalToConstant: 50.5),
            selectionView.heightAnchor.constraint(equalToConstant: 50.5)
        ])
    }
}

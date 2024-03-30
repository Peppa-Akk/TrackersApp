import UIKit

final class StatisticCell: UITableViewCell {
    
    static let reuseIdentifier = "StatisticCell"
    let resultLabel = UILabel()
    let titleLabel = UILabel()
    let cellView = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        activateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Add UI-Elements on View
extension StatisticCell {
    
    private func activateUI() {
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        setGradientBackground()
        addCellView()
        addTitleLabelOnView()
        addResultLabelOnView()
    }
    
    private func addResultLabelOnView() {
        
        resultLabel.font = .systemFont(ofSize: 34, weight: .bold)
        resultLabel.textColor = .hdBlack
        cellView.addSubview(resultLabel)
        resultLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            resultLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            resultLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            resultLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12)
        ])
    }
    
    private func addTitleLabelOnView() {
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .hdBlack
        cellView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
    
    private func addCellView() {
        
        cellView.clipsToBounds = true
        cellView.layer.cornerRadius = 15
        cellView.backgroundColor = .hdWhite
        contentView.addSubview(cellView)
        cellView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 1),
            cellView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -1),
            cellView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1),
            cellView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1)
        ])
    }
    
    private func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.colorSelection1.cgColor, UIColor.colorSelection9.cgColor, UIColor.colorSelection3.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 361, height: 90)
        
        contentView.layer.insertSublayer(gradientLayer, at: 0)
    }
}

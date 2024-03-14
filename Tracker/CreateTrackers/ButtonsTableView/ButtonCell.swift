import UIKit


final class ButtonCell: UITableViewCell {
    
    static let reuseIdentifier = "ButtonCell"
    let title = UILabel()
    let subTitle = UILabel()
    let kostyl = UILabel()
    
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
        addSubLabelOnView()
        addSubLabelConstraint()
        addLabelConstraint()
        addKostylOnView()
        addKostylConstraint()
    }
    
    private func addLabelOnView() {
        
        title.font = .systemFont(ofSize: 17, weight: .regular)
        title.textColor = .hdBlack
        contentView.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addKostylOnView() {
        
        kostyl.font = .systemFont(ofSize: 17, weight: .regular)
        kostyl.textColor = .hdBlack
        contentView.addSubview(kostyl)
        kostyl.translatesAutoresizingMaskIntoConstraints = false
        kostyl.isHidden = true
    }
    
    private func addSubLabelOnView() {
        
        subTitle.font = .systemFont(ofSize: 17, weight: .regular)
        subTitle.textColor = .hdGray
        contentView.addSubview(subTitle)
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        subTitle.isHidden = true
    }
    
    private func addLabelConstraint() {
        
        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            title.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func addKostylConstraint() {
        
        NSLayoutConstraint.activate([
            kostyl.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            kostyl.topAnchor.constraint(equalTo: topAnchor, constant: 15)
        ])
    }
    
    private func addSubLabelConstraint() {
        
        NSLayoutConstraint.activate([
            subTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            subTitle.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
    
    func switchLabels() {
        
        kostyl.text = title.text
        subTitle.isHidden = false
        kostyl.isHidden = false
        title.isHidden = true
    }
    
    func switchLabelsBack() {
        
        subTitle.isHidden = true
        kostyl.isHidden = true
        title.isHidden = false
    }
}

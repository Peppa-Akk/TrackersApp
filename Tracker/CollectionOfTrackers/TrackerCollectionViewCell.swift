import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
    func uncompleted(id: UUID, at indexPath: IndexPath)
}

//MARK: - TrackerCollectionViewCell
class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "Cell"
    
    let cardView = UIView()
    let emojiView = UIView()
    let emojiImageView = UIImageView()
    let emojiLabel = UILabel()
    let nameLabel = UILabel()
    
    let managmentView = UIView()
    let dateLabel = UILabel()
    let plusButton = UIButton()
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    private var isCompletedToday: Bool = false
    private var trackerID: UUID?
    private var indexPath: IndexPath?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        activateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func trackButtonTapped() {
        
        guard let trackerID = trackerID,
              let indexPath = indexPath
        else {
            assertionFailure("No Tracker ID")
            return
        }
        
        if isCompletedToday {
            delegate?.uncompleted(id: trackerID, at: indexPath)
        }
        if !isCompletedToday {
            delegate?.completeTracker(id: trackerID, at: indexPath)
        }
    }
}

//MARK: - Add UI-Elements on View
extension TrackerCollectionViewCell {
    func activateUI() {
        addCardView()
        addEmojiView()
        addEmojiImageView()
        addEmojiLabel()
        addNameLabel()
        addManagmentView()
        addDateLabel()
        addPlusButton()
    }
    
    //MARK: - Card/Tracker
    func addCardView() {
        cardView.layer.cornerRadius = 16
        cardView.layer.masksToBounds = true
        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
    
    func addEmojiView() {
        cardView.addSubview(emojiView)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiView.heightAnchor.constraint(equalToConstant: 24),
            emojiView.widthAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func addEmojiImageView() {
        emojiImageView.image = UIImage(named: "Emoji")
        emojiImageView.layer.opacity = 0.3
        emojiView.addSubview(emojiImageView)
        emojiImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiImageView.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiImageView.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor)
        ])
    }
    
    func addEmojiLabel() {
        emojiLabel.font = .systemFont(ofSize: 16)
        emojiView.addSubview(emojiLabel)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: emojiView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiView.centerYAnchor)
        ])
    }
    
    func addNameLabel() {
        nameLabel.font = .systemFont(ofSize: 12)
        nameLabel.contentMode = .bottomLeft
        nameLabel.numberOfLines = 0
        nameLabel.textColor = .white
        cardView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //TODO: - Заебашить вниз-лево сам текст
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 44),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12)
        ])
    }
    
    //MARK: - Quantity Managment
    func addManagmentView() {
        contentView.addSubview(managmentView)
        managmentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            managmentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            managmentView.topAnchor.constraint(equalTo: cardView.bottomAnchor),
            managmentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            managmentView.heightAnchor.constraint(equalToConstant: 58)
        ])
    }
    
    func addDateLabel() {
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.textAlignment = .left
        dateLabel.numberOfLines = 1
        dateLabel.textColor = .hdBlack
        managmentView.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        //TODO: - Заебашить текст влево
        NSLayoutConstraint.activate([
            dateLabel.leadingAnchor.constraint(equalTo: managmentView.leadingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: managmentView.trailingAnchor, constant: -54),
            dateLabel.topAnchor.constraint(equalTo: managmentView.topAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: managmentView.bottomAnchor, constant: -24)
        ])
    }
    
    func addPlusButton() {
        plusButton.addTarget(self, action: #selector(trackButtonTapped), for: .touchUpInside)
        plusButton.layer.cornerRadius = 17
        plusButton.layer.masksToBounds = true
        managmentView.addSubview(plusButton)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            plusButton.trailingAnchor.constraint(equalTo: managmentView.trailingAnchor, constant: -12),
            plusButton.topAnchor.constraint(equalTo: managmentView.topAnchor, constant: 8),
            plusButton.heightAnchor.constraint(equalToConstant: 34),
            plusButton.widthAnchor.constraint(equalToConstant: 34)
        ])
        
    }
    
    func configureTrackerCompletion(
        with tracker: Tracker,
        isCompletedToday: Bool,
        completedDays: Int,
        indexPath: IndexPath
    ) {
        
        self.trackerID = tracker.id
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        
        plusButton.backgroundColor = tracker.color
        let action = isCompletedToday ? setCompleteImage: setAddTrackerImage
        action(tracker.color)
        
        dateLabel.text = "\(completedDays.days())"
    }
    
    func setCompleteImage(with tintColor: UIColor) {
        plusButton.backgroundColor = tintColor
        plusButton.setImage(.complete, for: .normal)
        plusButton.tintColor = .hdWhite
        plusButton.layer.opacity = 0.3
    }
    
    func setAddTrackerImage(with tintColor: UIColor) {
        plusButton.backgroundColor = .clear
        plusButton.setImage(.plus, for: .normal)
        plusButton.tintColor = tintColor
        plusButton.layer.opacity = 1
    }
}

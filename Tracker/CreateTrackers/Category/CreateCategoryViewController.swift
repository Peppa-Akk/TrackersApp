import UIKit

final class CreateCategoryViewController: UIViewController {
    
    private lazy var nameCategoryTextField = UITextField()
    private var readyButton = UIButton()
    
    private var viewModel: CategoryViewModel
    
    init(with viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationController()
        activateUI()
    }
    
    @objc
    private func textFieldDidChange(_ sender: UITextField) {
        
        if sender.text != "" && sender.text != nil {
            readyButton.isUserInteractionEnabled = true
            readyButton.backgroundColor = .hdBlack
        } else {
            readyButton.isUserInteractionEnabled = false
            readyButton.backgroundColor = .hdGray
        }
    }
    
    @objc
    private func addNewCategory() {
        
        viewModel.addNewCategory(TrackerCategory(
            id: UUID(),
            title: nameCategoryTextField.text!,
            trackers: [])
        )
        self.dismiss(animated: true)
    }
}


//MARK: - NavigationController
extension CreateCategoryViewController {
    
    func setupNavigationController() {
        navigationController?.view.backgroundColor = .hdWhite
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Новая категория"
    }
}

// MARK: - Add UI-Elements on View
extension CreateCategoryViewController {
    
    func activateUI() {
        
        view.backgroundColor = .hdWhite
        setupTextField()
        setupButton()
    }
    
    func setupTextField() {
        
        let placeholderTitle = NSAttributedString(
            string: "Введите название категории",
            attributes: [NSAttributedString.Key.foregroundColor:UIColor.hdGray]
        )
        nameCategoryTextField.attributedPlaceholder = placeholderTitle
        nameCategoryTextField.setLeftViewForTextField()
        nameCategoryTextField.setRightViewForTextField()
        nameCategoryTextField.borderStyle = .none
        nameCategoryTextField.layer.cornerRadius = 16
        nameCategoryTextField.backgroundColor = .hdBackground
        nameCategoryTextField.font = .systemFont(ofSize: 17, weight: .regular)
        nameCategoryTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        nameCategoryTextField.translatesAutoresizingMaskIntoConstraints = false
        nameCategoryTextField.delegate = self
        view.addSubview(nameCategoryTextField)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            nameCategoryTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            nameCategoryTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            nameCategoryTextField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            nameCategoryTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func setupButton() {
        
        readyButton.backgroundColor = .hdGray
        readyButton.setTitle("Готово", for: .normal)
        readyButton.setTitleColor(.hdWhite, for: .normal)
        readyButton.titleLabel?.contentMode = .center
        readyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        readyButton.layer.cornerRadius = 16
        readyButton.layer.masksToBounds = true
        readyButton.isUserInteractionEnabled = false
        view.addSubview(readyButton)
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        readyButton.addTarget(self, action: #selector(addNewCategory), for: .touchUpInside)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            readyButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

//MARK: - TextFieldDelegate
extension CreateCategoryViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

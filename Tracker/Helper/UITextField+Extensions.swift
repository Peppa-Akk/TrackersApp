import UIKit

extension UITextField {
    
    func setLeftViewForTextField() {
        
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        self.leftViewMode = .always
    }
    
    func setRightViewForTextField() {

        self.clearButtonMode = .whileEditing
    }
}

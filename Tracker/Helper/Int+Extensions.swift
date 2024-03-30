import Foundation

extension Int {
     func days() -> String {
         var dayString: String!
         if "1".contains("\(self % 10)")      {dayString = NSLocalizedString("Day", comment: "")}
         if "234".contains("\(self % 10)")    {dayString = NSLocalizedString("SomeDays", comment: "") }
         if "567890".contains("\(self % 10)") {dayString = NSLocalizedString("Days", comment: "")}
         if 11...14 ~= self % 100                   {dayString = NSLocalizedString("Days", comment: "")}
    return "\(self) " + dayString
    }
}

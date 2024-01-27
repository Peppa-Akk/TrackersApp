import UIKit

class EmojisAndColorsModel {
    let title: String
    let count: Int
    
    init(title: String, count: Int) {
        self.title = title
        self.count = count
    }
}

final class EmojisModel: EmojisAndColorsModel {
    var emojis: [String]
    
    init(title: String, emojis: [String]) {
        self.emojis = emojis
        
        super.init(title: title, count: emojis.count)
    }
}

final class ColorsModel: EmojisAndColorsModel {
    var colors: [UIColor]
    
    init(title: String, colors: [UIColor]) {
        self.colors = colors
        
        super.init(title: title, count: colors.count)
    }
}

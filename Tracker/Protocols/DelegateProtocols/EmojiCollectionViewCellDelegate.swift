import Foundation

protocol EmojiCollectionViewCellDelegate: AnyObject {
    func didSelectEmoji(_ emoji: String)
}

import UIKit

final class EmojiCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "EmojiCell"
    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        return view
    }()
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32)
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func configureCell() {
        contentView.addSubview(emojiBackgroundView)
        
        NSLayoutConstraint.activate([
            emojiBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 46),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 46)
        ])
    }
    
    // MARK: - Public Methods
    func setEmoji(_ emoji: String) {
        emojiLabel.text = emoji
    }
    
    func selectEmoji() {
        emojiBackgroundView.backgroundColor = .ypLightGray
    }
    
    func deselectEmoji() {
        emojiBackgroundView.backgroundColor = .ypMain
    }
}

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "EmojiCollectionViewCell"
    private weak var delegate: EmojiCollectionViewCellDelegate?
    private var emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ]
    private lazy var emojiCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsMultipleSelection = false
        
        collectionView.register(
            EmojiCell.self,
            forCellWithReuseIdentifier: EmojiCell.identifier
        )
        collectionView.register(
            EmojiCellSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EmojiCellSupplementaryView.identifier
        )
        
        return collectionView
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func setDelegate(delegate: EmojiCollectionViewCellDelegate) {
        self.delegate = delegate
    }
    
    func selectEmoji(withEmoji emoji: String) {
        guard let emojiIndex = emojis.firstIndex(of: emoji) else {
            print("[EmojiCollectionViewCell selectCell]: emojiNotFound - Unable to find emoji in emojis array")
            return
        }
        
        let indexPath = IndexPath(item: emojiIndex, section: 0)
        
        guard let cell = emojiCollectionView.cellForItem(at: indexPath) as? EmojiCell else {
            print("[ColorSchemeCollectionViewCell selectCell]: typecastError - Unable to typecast cell as ColorCell")
            return
        }
        
        cell.selectEmoji()
        
        emojiCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
    }
}

// MARK: - UICollectionViewDataSource
extension EmojiCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else {
            print("[EmojiCollectionViewCell cellForItemAt]: typecastError - Unable to dequeue cell as EmojiCell")
            return UICollectionViewCell()
        }
        
        cell.setEmoji(emojis[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EmojiCellSupplementaryView.identifier,
            for: indexPath
        ) as? EmojiCellSupplementaryView else {
            print("[EmojiCollectionViewCell viewForSupplementaryElementOfKind]: typecastError - Unable to dequeue view as EmojiCellSupplementaryView")
            return UICollectionReusableView()
        }
        
        let headerString = NSLocalizedString("emoji.collectionview.header", comment: "Header for emoji section")
        view.setHeaderLabel(to: headerString)
        
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EmojiCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / CGFloat(6)
        let cellHeight = cellWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}

// MARK: - UICollectionViewDelegate
extension EmojiCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = emojiCollectionView.cellForItem(at: indexPath) as? EmojiCell else {
            print("[EmojiCollectionViewCell didSelectItemAt]: typecastError - Unable to typecast cell as EmojiCell")
            return
        }
        
        let selectedEmoji = emojis[indexPath.item]
        delegate?.didSelectEmoji(selectedEmoji)
        
        cell.selectEmoji()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = emojiCollectionView.cellForItem(at: indexPath) as? EmojiCell else {
            print("[EmojiCollectionViewCell didDeselectItemAt]: typecastError - Unable to typecast cell as EmojiCell")
            return
        }
        
        cell.deselectEmoji()
    }
}

// MARK: - UIConfigurationProtocol
extension EmojiCollectionViewCell: UIConfigurationProtocol {
    func configureUI() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(emojiCollectionView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            emojiCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

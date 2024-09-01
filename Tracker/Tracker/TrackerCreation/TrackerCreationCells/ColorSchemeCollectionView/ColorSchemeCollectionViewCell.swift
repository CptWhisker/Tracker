import UIKit

final class ColorSchemeCollectionViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "ColorSchemeCollectionViewCell"
    private weak var delegate: ColorSchemeCollectionViewCellDelegate?
    private var colors: [UIColor] = [
        .tracker1, .tracker2, .tracker3, .tracker4, .tracker5, .tracker6,
        .tracker7, .tracker8, .tracker9, .tracker10, .tracker11, .tracker12,
        .tracker13, .tracker14, .tracker15, .tracker16, .tracker17, .tracker18
    ]
    private lazy var colorCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            ColorCell.self,
            forCellWithReuseIdentifier: ColorCell.identifier
        )
        collectionView.register(
            ColorSchemeCellSupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ColorSchemeCellSupplementaryView.identifier
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
    func setDelegate(delegate: ColorSchemeCollectionViewCellDelegate) {
        self.delegate = delegate
    }
}

// MARK: - UICollectionViewDataSource
extension ColorSchemeCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else {
            print("[ColorSchemeCollectionViewCell cellForItemAt]: typecastError - Unable to dequeue cell as ColorCell")
            return UICollectionViewCell()
        }
        
        cell.setColor(colors[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ColorSchemeCellSupplementaryView.identifier,
            for: indexPath
        ) as? ColorSchemeCellSupplementaryView else {
            print("[ColorSchemeCollectionViewCell viewForSupplementaryElementOfKind]: typecastError - Unable to dequeue view as ColorSchemeCellSupplementaryView")
            return UICollectionReusableView()
        }
        
        view.setHeaderLabel(to: "Цвет")
        
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ColorSchemeCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // cellWidth is calculated based on the target number of color views in a row
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
extension ColorSchemeCollectionViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else {
            print("[ColorSchemeCollectionViewCell didSelectItemAt]: typecastError - Unable to typecast cell as ColorCell")
            return
        }
        
        let selectedColor = colors[indexPath.item]
        delegate?.didSelectColor(selectedColor)
        
        cell.selectColor(colors[indexPath.item])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCell else {
            print("[ColorSchemeCollectionViewCell didSelectItemAt]: typecastError - Unable to typecast cell as ColorCell")
            return
        }
        
        cell.deselectColor()
    }
}

// MARK: - UIConfigurationProtocol
extension ColorSchemeCollectionViewCell: UIConfigurationProtocol {
    func configureUI() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(colorCollectionView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            colorCollectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

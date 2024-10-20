import UIKit

final class ColorCell: UICollectionViewCell {
    static let identifier = "ColorCell"
    private var selectedColor: UIColor?
    private lazy var colorBackgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.ypMain.cgColor
        view.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        return view
    }()
    private lazy var colorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        return view
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateBorderColor()
        }
    }
    
    // MARK: - Private Methods
    private func updateBorderColor() {
        if selectedColor == nil {
            colorBackgroundView.layer.borderColor = UIColor.ypMain.cgColor
        }
    }
    
    // MARK: - Public Methods
    func setColor(_ color: UIColor) {
        colorView.backgroundColor = color
    }
    
    func selectColor(_ color: UIColor) {
        selectedColor = color
        colorBackgroundView.layer.borderColor = selectedColor?.withAlphaComponent(0.3).cgColor
    }
    
    func deselectColor() {
        selectedColor = nil
        colorBackgroundView.layer.borderColor = UIColor.ypMain.cgColor
    }
}

// MARK: - UIConfigurationProtocol
extension ColorCell: UIConfigurationProtocol {
    func configureUI() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(colorBackgroundView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            colorBackgroundView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorBackgroundView.widthAnchor.constraint(equalToConstant: 52),
            colorBackgroundView.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}

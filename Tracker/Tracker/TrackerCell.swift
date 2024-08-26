import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    private lazy var topView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .tracker12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "❤️"
        label.font = .systemFont(ofSize: 16)
        label.backgroundColor = .white.withAlphaComponent(0.3)
        label.layer.cornerRadius = 16
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.text = "Water plants"
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var recordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.text = "1 Day"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .tracker12
        button.setImage(UIImage(named: "plusButton"), for: .normal)
        button.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Interface Configuration
    private func configureCell() {
        configureTopView()
        configureBottomView()
        
        contentView.addSubview(topView)
        contentView.addSubview(bottomView)
        
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: contentView.topAnchor),
            topView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: 90),
            
            bottomView.topAnchor.constraint(equalTo: topView.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: 58)
        ])
    }
    
    private func configureTopView() {
        topView.addSubview(emojiLabel)
        topView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: topView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: emojiLabel.bottomAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -12)
        ])
    }
    
    private func configureBottomView() {
        bottomView.addSubview(recordLabel)
        bottomView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            recordLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 16),
            recordLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 12),
            recordLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -8),
            
            plusButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    // MARK: - Actions
    @objc private func plusButtonTapped() {
        print("Button tapped!")
    }
}

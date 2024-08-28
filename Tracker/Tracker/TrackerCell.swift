import UIKit

final class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    private weak var delegate: TrackerCellDelegate?
    private lazy var topView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var emojiBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.backgroundColor = .white.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .white
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var recordLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var plusButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.tintColor = .white
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
        topView.addSubview(emojiBackgroundView)
        topView.addSubview(titleLabel)
        emojiBackgroundView.addSubview(emojiLabel)

        
        NSLayoutConstraint.activate([
            emojiBackgroundView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),
            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            
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
    
    private func updateRecordLabel(with count: Int?) {
        let record = count ?? 0
        let dayString = dayDeclension(for: record)
        
        recordLabel.text = "\(record) \(dayString)"
    }
    
    private func updateButtonImage(isCompleted: Bool) {
        if isCompleted {
            plusButton.setImage(UIImage(named: "trackerDone"), for: .normal)
            plusButton.alpha = 0.3
        } else {
            plusButton.setImage(UIImage(named: "trackerPlus")?.withRenderingMode(.alwaysTemplate), for: .normal)
            plusButton.alpha = 1
        }
    }
    
    private func dayDeclension(for day: Int) -> String {
        let absNumber = abs(day)

        let lastDigit = absNumber % 10
        let lastTwoDigits = absNumber % 100

        if lastDigit == 1 && lastTwoDigits != 11 {
            return "день"
        } else if (lastDigit == 2 || lastDigit == 3 || lastDigit == 4) && !(lastTwoDigits >= 12 && lastTwoDigits <= 14) {
            return "дня"
        } else {
            return "дней"
        }
    }
    
    // MARK: - Actions
    @objc private func plusButtonTapped() {
        guard let delegate else { return }
                
        delegate.didTapPlusButton(in: self)
    }
    
    
    
    // MARK: - Public Methods
    func configure(with tracker: Tracker, completed count: Int?, isCompleted: Bool) {
        titleLabel.text = tracker.habitName
        emojiLabel.text = tracker.habitEmoji
        topView.backgroundColor = tracker.habitColor
        plusButton.backgroundColor = tracker.habitColor
        
        updateRecordLabel(with: count)
        updateButtonImage(isCompleted: isCompleted)
    }
    
    func configure(completed count: Int?, isCompleted: Bool) {
        updateRecordLabel(with: count)
        updateButtonImage(isCompleted: isCompleted)
    }
    
    func setDelegate(delegate: TrackerCellDelegate) {
        self.delegate = delegate
    }
}

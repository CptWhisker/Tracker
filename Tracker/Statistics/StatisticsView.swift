import UIKit

final class StatisticsView: UIView {
    // MARK: - UI Elements
    private lazy var gradientBorder: GradientView = {
        let view = GradientView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypMain
        view.layer.cornerRadius = 16
        return view
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypAccent
        label.textAlignment = .left
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypAccent
        label.textAlignment = .left
        label.text = "Trackers completed"
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Configuration
    private func configureView() {
        configureLabel()
        
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
    }
    
    private func configureLabel() {
        self.addSubview(gradientBorder)
        self.addSubview(backgroundView)
        self.addSubview(scoreLabel)
        self.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            gradientBorder.topAnchor.constraint(equalTo: self.topAnchor),
            gradientBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            gradientBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            gradientBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            backgroundView.topAnchor.constraint(equalTo: gradientBorder.topAnchor, constant: 1),
            backgroundView.leadingAnchor.constraint(equalTo: gradientBorder.leadingAnchor, constant: 1),
            backgroundView.trailingAnchor.constraint(equalTo: gradientBorder.trailingAnchor, constant: -1),
            backgroundView.bottomAnchor.constraint(equalTo: gradientBorder.bottomAnchor, constant: -1),
            
            scoreLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            scoreLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            scoreLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 7),
            descriptionLabel.leadingAnchor.constraint(equalTo: scoreLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: scoreLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12)
        ])
    }
    
    // MARK: - Public Methods
    func setScore(to score: Int) {
        scoreLabel.text = String(score)
    }
}

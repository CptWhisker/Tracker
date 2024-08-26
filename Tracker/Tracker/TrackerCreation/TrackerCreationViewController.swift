import UIKit

final class TrackerCreationViewController: UIViewController {
    private lazy var newHabitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .ypAccent
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(.ypMain, for: .normal)
        button.addTarget(self, action: #selector(createNewHabit), for: .touchUpInside)
        return button
    }()
    private lazy var newIrregularEventButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .ypAccent
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(.ypMain, for: .normal)
        button.addTarget(self, action: #selector(createNewIrregularEvent), for: .touchUpInside)
        return button
    }()
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [newHabitButton, newIrregularEventButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.masksToBounds = true
        stackView.axis = .vertical
        stackView.spacing = 16
        
        NSLayoutConstraint.activate([
            newHabitButton.heightAnchor.constraint(equalToConstant: 60),
            newIrregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
    private func configureInterface() {
        view.backgroundColor = .ypMain
        
        title = "Создание трекера"
        
        view.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func createNewHabit() {
        let newHabitCreationViewController = NewHabitOrIrregularEventViewController(initializerTag: .habit)
        let newHabitCreationNavigationController = UINavigationController(rootViewController: newHabitCreationViewController)
        
        present(newHabitCreationNavigationController, animated: true)
    }
    
    @objc private func createNewIrregularEvent() {
        let newIrregularEventCreationViewController = NewHabitOrIrregularEventViewController(initializerTag: .event)
        let newIrregularEventCreationNavigationController = UINavigationController(rootViewController: newIrregularEventCreationViewController)
        
        present(newIrregularEventCreationNavigationController, animated: true)
    }
}

import UIKit

final class ScheduleCell: UITableViewCell {
    static let identifier = "ScheduleCell"
    private var delegate: ScheduleCreationDelegate?
    private var accessory: UISwitch = {
        let accessory = UISwitch()
        accessory.translatesAutoresizingMaskIntoConstraints = false
        accessory.onTintColor = .ypBlue
        return accessory
    }()
    private let weekdayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypAccent
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCell() {
        contentView.backgroundColor = .ypBackground
        
        configureWeekdayLabel()
        configureAccessory()
    }
    
    private func configureWeekdayLabel() {
        contentView.addSubview(weekdayLabel)
        
        NSLayoutConstraint.activate([
            weekdayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            weekdayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
    
    private func configureAccessory() {
        contentView.addSubview(accessory)
        accessory.addTarget(self, action: #selector(switchToggled(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            accessory.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessory.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func setTitle(to title: WeekDays) {
        weekdayLabel.text = title.rawValue
    }
    
    func setDelegate(delegate: ScheduleCreationDelegate) {
        self.delegate = delegate
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        guard let delegate else {
            print("[ScheduleCell switchToggled]: delegateError - Delegate is not set")
            return
        }
        guard let weekday = weekdayLabel.text else {
            print("[ScheduleCell switchToggled]: weekdayLabelError - weekdayLabel`s text is not set")
            return
        }
        
        if sender.isOn {
            delegate.addWeekDay(weekday)
        } else {
            delegate.removeWeekDay(weekday)
        }
    }
}

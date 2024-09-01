import Foundation

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectWeekDays( weekdays: [WeekDays])
}

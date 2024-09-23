import Foundation

protocol ScheduleCreationDelegate: AnyObject {
    func addWeekDay(_ weekday: WeekDays)
    func removeWeekDay(_ weekday: WeekDays)
}

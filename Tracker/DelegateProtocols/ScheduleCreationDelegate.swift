import Foundation

protocol ScheduleCreationDelegate: AnyObject {
    func addWeekDay(_ weekday: String)
    func removeWeekDay(_ weekday: String)
}

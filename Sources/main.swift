import EventKit
import PrettyColors

let red = Color.Wrap(foreground: .red).wrap
let green_bold = Color.Wrap(foreground: .green, style: .bold).wrap
let blue_bold = Color.Wrap(foreground: .blue, style: .bold).wrap

var store = EKEventStore()

switch EKEventStore.authorizationStatus(for: .event) {
case .notDetermined:
  if #available(macOS 14.0, *) {
    store.requestFullAccessToEvents { granted, error in
      if granted {
        print(green_bold("I'm in."))
      } else {
        print(red("Error getting access to calendars"))
      }
    }
  } else {
    print(red("eventuilly only works for macOS 14+"))
    exit(1)
  }

case .denied:
  print(
    """
    access denied to calendars, try:

       Preferences > Privacy > Calendars > [Your Terminal] > Check
    """
  )
  exit(1)

case .authorized:
  break

default:
  fputs("wat.", stderr)
}

var calendars = store.calendars(for: .event)
// calendars = calendars.filter { ["Personal"].contains($0.title) }

let now = Date()
let ten_minutes_ago = Calendar.current.date(byAdding: .minute, value: -10, to: now)!
let ten_minutes_from_now = Calendar.current.date(byAdding: .minute, value: 10, to: now)!

// print(ten_minutes_ago)
// print(now)
// print(ten_minutes_from_now)

let predicate_current_events = store.predicateForEvents(
  withStart: ten_minutes_from_now,
  end: ten_minutes_from_now,
  calendars: calendars
)

let current_events = store.events(matching: predicate_current_events).filter { event in
  return !event.isAllDay
}
if current_events.isEmpty {
  print("no events")
  exit(0)
}

let dateComponentsFormatter = DateComponentsFormatter()
dateComponentsFormatter.allowedUnits = [.second, .minute, .hour]
dateComponentsFormatter.maximumUnitCount = 1
dateComponentsFormatter.unitsStyle = .full

let timeFormatter = DateFormatter()
timeFormatter.dateFormat = "HH:mm"

for event in current_events {
  // let time_passed = dateComponentsFormatter.string(from: event.startDate, to: now)!
  // print("Event: \(event.title!) (\(time_passed))")

  let start = timeFormatter.string(from: event.startDate)
  let end = timeFormatter.string(from: event.endDate)
  print("[\(start) - \(end)] \(event.title!)")
}

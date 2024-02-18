import EventKit
import PrettyColors

let red = Color.Wrap(foreground: .red).wrap
let green_bold = Color.Wrap(foreground: .green, style: .bold).wrap
let blue_bold = Color.Wrap(foreground: .blue, style: .bold).wrap

var store = EKEventStore()

switch EKEventStore.authorizationStatus(for: .event) {
case .notDetermined:
  store.requestFullAccessToEvents { granted, error in
    if granted {
      print(green_bold("I'm in."))
    } else {
      print(red("Error getting access to calendars"))
    }
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

let calendars =
  store
  .calendars(for: .event)
  .filter { ["Personal"].contains($0.title) }

let now = Date()
let ten_minutes_ago = Calendar.current.date(byAdding: .minute, value: -10, to: now)!
let ten_minutes_from_now = Calendar.current.date(byAdding: .minute, value: 10, to: now)!

let predicate_current_events = store.predicateForEvents(
  withStart: ten_minutes_from_now,
  end: ten_minutes_from_now,
  calendars: calendars
)

let current_events =
  store
  .events(matching: predicate_current_events)
  .filter { !$0.isAllDay }

if current_events.isEmpty {
  print("no events")
  exit(0)
}

let time_formatter = DateFormatter()
time_formatter.dateFormat = "HH:mm"

let relative_formatter = RelativeDateTimeFormatter()

for event in current_events {
  let start = time_formatter.string(from: event.startDate)
  let end = time_formatter.string(from: event.endDate)
  let when = relative_formatter.string(for: event.startDate)!

  print("[\(start) - \(end)] \(event.title!) (\(when))")
}

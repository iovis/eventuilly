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

let calendars = store.calendars(for: .event)
print(calendars)

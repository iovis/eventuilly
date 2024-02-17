import PrettyColors

print("Eventuilly")

let red = Color.Wrap(foreground: .red).wrap
let blue_bold = Color.Wrap(foreground: .blue, style: .bold).wrap

print(
  red("Some red text"),
  blue_bold("with some bold blue text")
)

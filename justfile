default: run

@list:
    just --list

run:
    swift run

build:
    swift build -c release

dev:
    watchexec -e swift just run

open:
    gh repo view --web

console:
    swift repl

test:
    swift test

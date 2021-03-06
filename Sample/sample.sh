#!/bin/sh
cd `dirname $0`

if ! which brew; then
  echo "brew not found. Prease install Homebrew."
  exit 1
fi

if ! brew list | grep -q graphviz; then
  brew install graphviz
fi

swift build -c release
swift run -c release FlowGraphDotConverter ../Sources/FlowGraphDotConverterCore/FlowGraphScanner.swift --output ./ --hide-enter
dot -T svg ./StateScanner.dot -o ./StateScanner.svg

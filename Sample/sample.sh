#!/bin/sh
cd `dirname $0`
swift build -c release
../.build/release/FlowGraphDotConverter ../Sources/FlowGraphDotConverterCore/FlowGraphScanner.swift --output ./
dot -T svg ./StateScanner.dot -o ./StateScanner.svg

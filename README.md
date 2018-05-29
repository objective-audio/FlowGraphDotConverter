# FlowGraphDotConverter

[FlowGraph](https://github.com/objective-audio/SwiftFlowGraph)が使用されているSwiftファイルを解析して、dot形式のファイルを出力します。

## ビルドする

```
$ swift build -c release
```

## 実行する

```
$ .build/release/FlowGraphDotConverter 入力するswiftファイルのパス（複数可） --output 出力するディレクトリのパス
```

dot形式のファイルが出力されます。

## 状態遷移図を作成する

GraphVizのインストール

```
$ brew install graphviz
```

dot形式のファイルを画像に変換する

```
$ dot -T svg 入力するファイルのパス -o 出力するファイルのパス
```

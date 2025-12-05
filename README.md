[README.md](https://github.com/user-attachments/files/23957141/README.md)
# Script Explorer (Godot エディタプラグイン)

**現在選択／編集中の GDScript の情報（ファイル名・class_name・extends・メソッド・プロパティ）を右側 Dock に表示するプラグイン**です。
タブ名は `SE` です。

## インストール
1. `addons/script_explorer` をプロジェクトにコピー
2. Godot → Project → Project Settings → Plugins で `Script Explorer` を有効化

## 使い方
スクリプトエディタで GDScript を開くか選択すると、SE タブに情報が表示されます。
- Script: `enemy.gd`
- Class: `Enemy`
- Base: `Node2D`
- Methods: `attack(target)`, `take_damage(dmg)` ...
- Properties: `hp`, `speed`, ...

## 注意
- Godot 4.x 向け実装
- 現状は RegEx による解析（将来的に AST を使った精密解析へ拡張可能）

## ライセンス
MIT

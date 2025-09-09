# Claude Code Usage Analyzer with ClickHouse Local

Claude Code の使用ログを ClickHouse Local で詳細分析するツールセットです。

## 概要

Claude Code は `~/.claude/projects/*/*.jsonl` に会話ログを保存しています。このプロジェクトでは、これらのログファイルを ClickHouse Local を使って高速に分析し、使用パターンや統計情報を可視化します。

## 必要環境

- ClickHouse Local
- Claude Code のログファイル（`~/.claude/projects/` ディレクトリ）

### ClickHouse のインストール

```bash
# macOS
brew install clickhouse

# Linux
curl https://clickhouse.com/ | sh
```

## ファイル構成

```
2025-09-09_clickhouse-local-claude/
├── README.md                    # このファイル
├── claude-usage-analyzer.sh     # オールインワン分析スクリプト
├── init.sql                     # 初期化SQL（テーブル作成）
├── analysis.sql                 # 分析クエリ集
└── analyze.sh                   # 実行スクリプト
```

## 使い方

### 方法1: オールインワンスクリプト（推奨）

```bash
# デフォルトのタイムゾーン（Asia/Tokyo）で実行
./claude-usage-analyzer.sh

# 別のタイムゾーンで実行
TZ=America/New_York ./claude-usage-analyzer.sh
```

### 方法2: 個別ファイルを使用

```bash
# 標準分析を実行
./analyze.sh

# カスタムクエリを実行
./analyze.sh "SELECT count() FROM claude_projects_jsonl"

# インタラクティブモードで起動
./analyze.sh --interactive
```

## 実装方針

### 1. データ構造

Claude Code のログは JSONL（JSON Lines）形式で保存されています：

```json
{
  "sessionId": "uuid",
  "timestamp": "2025-09-09T12:00:00.000Z",
  "type": "user|assistant|system",
  "cwd": "/path/to/project",
  "message": {
    "role": "user|assistant",
    "content": "..."
  },
  "toolName": "Bash|Edit|Write|...",
  ...
}
```

### 2. ClickHouse Local の選定理由

- **高速処理**: 大量のJSONログを効率的に処理
- **SQLサポート**: 複雑な集計クエリが書きやすい
- **インストール不要**: サーバー起動不要でローカル実行可能
- **JSONAsObject**: JSON をネイティブにサポート

### 3. 技術的な工夫

#### JSONAsObject によるパスベースアクセス

ClickHouse の JSONAsObject 形式を使用することで、JSONフィールドに直接アクセス可能：

```sql
SELECT 
    json.sessionId as session_id,
    json.message.role as role,
    json.timestamp as timestamp
FROM file('$HOME/.claude/projects/*/*.jsonl', 'JSONAsObject') AS json
```

#### タイムゾーン対応

`--session_timezone` オプションを使用して、クライアント接続時にタイムゾーンを指定：

```bash
clickhouse local --session_timezone="Asia/Tokyo"
```

データはUTCで保存され、クエリ実行時に自動変換されます。

#### メモリテーブルの使用

初期化時に全データをメモリテーブルにロード：

```sql
CREATE TABLE claude_projects_jsonl
ENGINE = Memory
AS SELECT ...
```

これにより、後続のクエリが高速に実行されます。

### 4. 制限事項と回避策

#### インタラクティブモード問題

ClickHouse Local では、`--file` で初期化したテーブルがインタラクティブモードで保持されない制限があります。

**回避策検討**:
1. パイプによる初期化 → stdin競合で失敗
2. 一時ファイル経由 → テーブルが保持されない
3. 現在の実装：初期化とデモ表示後、インタラクティブモードへ

## 分析できる内容

### 基本統計
- 総メッセージ数、セッション数
- ユーザー/アシスタントメッセージの内訳
- アクティブなプロジェクト数

### 時系列分析
- 日別アクティビティ推移
- 時間帯別使用パターン
- 週次サマリー
- 平日/週末の比較

### プロジェクト分析
- プロジェクト別メッセージ数
- ブランチ別アクティビティ
- 最終更新日時

### ツール使用統計
- 使用頻度の高いツール（Bash, Edit, Write等）
- ツール別のエラー率

### セッション分析
- 最も活発なセッション
- セッション継続時間
- セッションあたりのメッセージ数

## サンプルクエリ

```sql
-- 日別アクティビティ
SELECT date, count() as messages 
FROM claude_projects_jsonl 
GROUP BY date 
ORDER BY date DESC 
LIMIT 10;

-- プロジェクト別統計
SELECT project, count() as messages 
FROM claude_projects_jsonl 
WHERE project != '' 
GROUP BY project 
ORDER BY messages DESC 
LIMIT 10;

-- 時間帯パターン
SELECT hour, count() as messages, 
       bar(count(), 0, 3000, 30) as pattern 
FROM claude_projects_jsonl 
GROUP BY hour 
ORDER BY hour;

-- ツール使用状況
SELECT tool_name, count() as uses 
FROM claude_projects_jsonl 
WHERE tool_name != '' 
GROUP BY tool_name 
ORDER BY uses DESC 
LIMIT 10;
```

## トラブルシューティング

### Q: テーブルが見つからないエラー
A: init.sql が正しく実行されていない可能性があります。`analyze.sh` を使用するか、`claude-usage-analyzer.sh` を実行してください。

### Q: タイムゾーンが正しくない
A: 環境変数 `TZ` を設定してください：
```bash
TZ=America/New_York ./analyze.sh
```

### Q: ファイルが見つからない
A: `~/.claude/projects/` ディレクトリが存在することを確認してください。

## ライセンス

MIT License

## 作者

Kazuki Matsuda

## 更新履歴

- 2025-09-09: 初版作成
  - JSONAsObject によるパスベースアクセス実装
  - タイムゾーンサポート追加
  - オールインワンスクリプト作成
# ClickHouse Local で Claude Code の使用ログを爆速分析する

## はじめに

諸君、私は ClickHouse が好きだ。

諸君、私は ClickHouse が大好きだ。

100TB のデータを秒速でスキャンする ClickHouse が好きだ。  
ペタバイトのログを瞬時に集計する ClickHouse が好きだ。  
JSON を SQL でネイティブに扱える ClickHouse が好きだ。  
サーバー不要で動く ClickHouse Local が好きだ。  

数百個の JSONL ファイルを Python で読み込んで pandas でゴリゴリ集計しているのを見た時など、心が躍る。いや、違う。それは悲しみだ。

SQLite で頑張って JOIN を繰り返している開発者を、ClickHouse の MergeTree エンジンが粉砕した時など、胸がすくような気持ちだった。

jq でパイプを繋ぎまくって複雑な集計をしているのを、たった一行の SQL で置き換えた時など、感動すら覚える。

そう、今日は Claude Code の使用ログを ClickHouse Local で爆速分析する話だ。

`~/.claude/projects/` に眠る大量の JSONL ファイル。これを **ClickHouse Local** で料理する。

## TL;DR

```bash
# ClickHouse をインストール
brew install clickhouse

# このスクリプトを実行するだけ
curl -sL https://gist.github.com/kazuki-ma/claude-analyzer.sh | bash
```

で、Claude の使用統計が見れます。

## Claude Code のログ構造

まず、Claude Code がどんなログを吐いているか見てみましょう：

```bash
$ ls ~/.claude/projects/
-Users-kazuki-dev-project1/
-Users-kazuki-dev-project2/
...

$ ls ~/.claude/projects/*/*.jsonl | wc -l
321  # 321個のセッションファイル！
```

各 JSONL ファイルの中身：

```json
{"sessionId":"xxx","timestamp":"2025-09-09T12:00:00Z","type":"user","message":{"role":"user","content":"..."},"cwd":"/Users/kazuki/dev/..."}
{"sessionId":"xxx","timestamp":"2025-09-09T12:00:01Z","type":"assistant","message":{"role":"assistant","content":"..."},"toolName":"Bash"}
```

これを SQL で分析したい！

## ClickHouse Local とは

ClickHouse Local は、**サーバー不要**で使える SQL エンジンです。

通常の ClickHouse：
```
データベースサーバー起動 → 接続 → クエリ実行
```

ClickHouse Local：
```
ファイルに対して直接 SQL 実行！
```

しかも **JSON をネイティブサポート**しているので、jq より高速で複雑な集計ができます。

## 実装：1ファイルで完結する分析スクリプト

以下のスクリプトを `claude-analyzer.sh` として保存して実行するだけ：

```bash
#!/bin/bash

TIMEZONE="${TZ:-Asia/Tokyo}"

cat << 'SQL' | clickhouse local --multiquery --session_timezone="$TIMEZONE"
-- JSONファイルを直接読み込んでテーブル作成
CREATE TABLE claude_logs ENGINE = Memory AS 
SELECT 
    json.sessionId as session_id,
    json.timestamp as timestamp,
    toDate(parseDateTimeBestEffort(toString(json.timestamp))) as date,
    toHour(parseDateTimeBestEffort(toString(json.timestamp))) as hour,
    json.type as type,
    json.message.role as role,
    json.toolName as tool_name,
    substring(toString(json.cwd), position(toString(json.cwd), 'github.com/') + 11, 100) as project
FROM file('$HOME/.claude/projects/*/*.jsonl', 'JSONAsObject') AS json;

-- サマリー表示
SELECT '=== Claude Usage Summary ===' FORMAT LineAsString;
SELECT 
    count() as total_messages,
    count(DISTINCT session_id) as sessions,
    count(DISTINCT project) as projects,
    count(DISTINCT date) as active_days
FROM claude_logs
FORMAT Pretty;

-- 日別アクティビティ
SELECT '=== Daily Activity (Last 7 days) ===' FORMAT LineAsString;
SELECT 
    date,
    count() as messages,
    bar(count(), 0, 1000, 30) as activity
FROM claude_logs
WHERE date >= today() - 7
GROUP BY date
ORDER BY date DESC
FORMAT Pretty;

-- プロジェクト別TOP5
SELECT '=== Top Projects ===' FORMAT LineAsString;
SELECT 
    project,
    count() as messages
FROM claude_logs
WHERE project != ''
GROUP BY project
ORDER BY messages DESC
LIMIT 5
FORMAT Pretty;

-- 時間帯分析
SELECT '=== Hourly Pattern ===' FORMAT LineAsString;
SELECT 
    hour,
    count() as messages,
    bar(count(), 0, 500, 20) as pattern
FROM claude_logs
GROUP BY hour
ORDER BY hour
FORMAT Pretty;
SQL
```

## 実行結果

```
=== Claude Usage Summary ===
┏━━━━━━━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━━━┓
┃ total_messages ┃ sessions ┃ projects ┃ active_days ┃
┡━━━━━━━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━━━┩
│          28999 │      295 │       35 │          24 │
└────────────────┴──────────┴──────────┴─────────────┘

=== Daily Activity (Last 7 days) ===
┏━━━━━━━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃       date ┃ messages ┃ activity                     ┃
┡━━━━━━━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
│ 2025-09-09 │     1886 │ ██████████████████████████████│
│ 2025-09-08 │     3810 │ ██████████████████████████████│
│ 2025-09-07 │     3170 │ ██████████████████████████████│
│ 2025-09-06 │     2130 │ ██████████████████████████▌   │
│ 2025-09-05 │     2476 │ ██████████████████████████████│
└────────────┴──────────┴──────────────────────────────┘

=== Hourly Pattern ===
┏━━━━━━┳━━━━━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━┓
┃ hour ┃ messages ┃ pattern              ┃
┡━━━━━━╇━━━━━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━┩
│    0 │     1566 │ ████████████████████ │
│    1 │     1034 │ █████████████▏       │
│    2 │     1178 │ ███████████████      │
│    5 │     3053 │ ████████████████████ │  ← 早朝がピーク！
│    7 │     1974 │ ████████████████████ │
│   11 │     1990 │ ████████████████████ │
└──────┴──────────┴──────────────────────┘
```

おお、早朝5時が一番活発！（深夜作業の証拠...）

## 技術的なポイント

### 1. JSONAsObject でパスアクセス

ClickHouse の JSONAsObject 形式を使うと、JSON のネストしたフィールドに直接アクセスできます：

```sql
-- json.message.role のように . でアクセス可能
SELECT 
    json.sessionId as session_id,
    json.message.role as role  -- ネストしたフィールド
FROM file('path/*.jsonl', 'JSONAsObject') AS json
```

### 2. タイムゾーン対応

`--session_timezone` オプションで、UTCで保存されているタイムスタンプを自動変換：

```bash
# 日本時間で分析
clickhouse local --session_timezone="Asia/Tokyo"

# ニューヨーク時間で分析
TZ=America/New_York ./analyzer.sh
```

### 3. バーチャート表示

`bar()` 関数で簡易的なバーチャートが作れます：

```sql
SELECT 
    hour,
    bar(count(), 0, 1000, 30) as pattern  -- 最小0、最大1000、幅30文字
FROM ...
```

## 応用：もっと詳しく分析したい

### ツール使用統計

```sql
SELECT 
    tool_name,
    count() as uses,
    bar(count(), 0, 500, 30) as usage
FROM claude_logs
WHERE tool_name != ''
GROUP BY tool_name
ORDER BY uses DESC;
```

結果：
```
┏━━━━━━━━━━━━┳━━━━━━┳━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ tool_name  ┃ uses ┃ usage                        ┃
┡━━━━━━━━━━━━╇━━━━━━╇━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┩
│ Bash       │  892 │ ██████████████████████████████│
│ Edit       │  651 │ ███████████████████████▌      │
│ Read       │  423 │ ███████████████▍              │
│ Write      │  312 │ ███████████▏                  │
└────────────┴──────┴──────────────────────────────┘
```

### 週末 vs 平日

```sql
SELECT 
    if(toDayOfWeek(date) IN (6, 7), 'Weekend', 'Weekday') as day_type,
    count() as messages,
    round(count() / count(DISTINCT date), 1) as avg_per_day
FROM claude_logs
GROUP BY day_type;
```

### セッション継続時間

```sql
SELECT 
    session_id,
    dateDiff('minute', min(timestamp), max(timestamp)) as duration_min,
    count() as messages
FROM claude_logs
GROUP BY session_id
HAVING duration_min > 60
ORDER BY duration_min DESC
LIMIT 10;
```

## まとめ

ClickHouse Local を使うと：

- **サーバー不要**で即座に分析開始
- **SQL** で複雑な集計も簡単
- **JSON サポート**でパース不要
- **高速**（数万レコードも一瞬）

Claude Code のログ以外にも、アプリケーションログ、アクセスログ、その他の JSONL ファイルの分析に使えます。

jq でゴリゴリ頑張る前に、ClickHouse Local を試してみてください！

## 参考リンク

- [ClickHouse Local Documentation](https://clickhouse.com/docs/en/operations/utilities/clickhouse-local)
- [完全版スクリプト（GitHub）](https://github.com/kazuki-ma/kazuki-ma.github.io/tree/master/2025-09-09_clickhouse-local-claude)

---

タグ: `ClickHouse`, `Claude`, `ログ分析`, `SQL`, `JSON`
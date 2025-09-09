#!/bin/bash
#
# Claude Code Usage Analyzer - All-in-one Script
# Analyzes Claude Code usage patterns using ClickHouse Local
#
# Usage:
#   ./claude-usage-analyzer.sh              # Run with default timezone (Asia/Tokyo)
#   TZ=America/New_York ./claude-usage-analyzer.sh  # Run with different timezone
#
# Requirements:
#   - ClickHouse Local installed (brew install clickhouse)
#   - Claude Code projects in ~/.claude/projects/
#
# Author: Kazuki Matsuda
# Date: 2025-09-09

set -e

# Configuration
TIMEZONE="${TZ:-Asia/Tokyo}"
CLAUDE_DIR="$HOME/.claude/projects"

echo "=== Claude Code Usage Analyzer ==="
echo "Analyzing $(find $CLAUDE_DIR -name "*.jsonl" 2>/dev/null | wc -l | xargs) session files..."
echo "Timezone: $TIMEZONE"
echo ""

# Define initialization SQL (with HOME variable substitution)
read -r -d '' INIT_SQL << EOF || true
-- Claude Code Usage Analysis - Initialization
-- Creates base table from JSONL files using JSONAsObject

-- Create deduplicated view first (following ccusage logic: message.id + requestId)
CREATE TABLE IF NOT EXISTS claude_projects_jsonl_raw
ENGINE = Memory
AS 
SELECT 
    CAST(json.content, 'Nullable(String)') as content,
    CAST(json.cwd, 'Nullable(String)') as cwd,
    CAST(json.gitBranch, 'Nullable(String)') as git_branch,
    CAST(json.isApiErrorMessage, 'Nullable(String)') as is_api_error_message,
    CAST(json.isCompactSummary, 'Nullable(String)') as is_compact_summary,
    CAST(json.isMeta, 'Nullable(String)') as is_meta,
    CAST(json.isSidechain, 'Nullable(String)') as is_sidechain,
    CAST(json.isVisibleInTranscriptOnly, 'Nullable(String)') as is_visible_in_transcript_only,
    CAST(json.leafUuid, 'Nullable(String)') as leaf_uuid,
    CAST(json.level, 'Nullable(String)') as level,
    CAST(json.parentUuid, 'Nullable(String)') as parent_uuid,
    CAST(json.requestId, 'Nullable(String)') as request_id,
    CAST(json.sessionId, 'String') as session_id,
    CAST(json.summary, 'Nullable(String)') as summary,
    CAST(json.timestamp, 'Nullable(String)') as timestamp_str,
    CAST(json.toolUseID, 'Nullable(String)') as tool_use_id,
    CAST(json.toolUseResult, 'Nullable(String)') as tool_use_result,
    CAST(json.type, 'Nullable(String)') as type,
    CAST(json.userType, 'Nullable(String)') as user_type,
    CAST(json.uuid, 'String') as message_uuid,
    CAST(json.uuid, 'Nullable(String)') as uuid,
    CAST(json.version, 'Nullable(String)') as version,

    parseDateTimeBestEffortOrNull(toString(json.timestamp)) as timestamp,
    if(isNotNull(parseDateTimeBestEffortOrNull(toString(json.timestamp))), toDate(parseDateTimeBestEffortOrNull(toString(json.timestamp))), NULL) as date,
    if(isNotNull(parseDateTimeBestEffortOrNull(toString(json.timestamp))), toHour(parseDateTimeBestEffortOrNull(toString(json.timestamp))), NULL) as hour,
    if(isNotNull(parseDateTimeBestEffortOrNull(toString(json.timestamp))), toDayOfWeek(parseDateTimeBestEffortOrNull(toString(json.timestamp))), NULL) as day_of_week,
    json.message as message,
    json.message.usage as message_usage,
    toString(json.message.content) as message_content,
    toUInt32OrNull(toString(json.message.usage.input_tokens)) as input_tokens,
    toUInt32OrNull(toString(json.message.usage.output_tokens)) as output_tokens,
    toUInt32OrNull(toString(json.message.usage.cache_creation_input_tokens)) as cache_creation_input_tokens,
    toUInt32OrNull(toString(json.message.usage.cache_read_input_tokens)) as cache_read_input_tokens,
    toString(json.message.usage.service_tier) as service_tier,
    
    toString(json.message.id) as message_id,
    toString(json.message.role) as role,
    toString(json.message.model) as model,

    substring(toString(json.cwd), position(toString(json.cwd), 'github.com/') + 11, 100) as project,
    _path,
    json as raw_json
FROM file('$HOME/.claude/projects/*/*.jsonl', 'JSONAsObject') AS json;

-- Create deduplicated table using message_id + request_id as unique key
CREATE TABLE IF NOT EXISTS claude_projects_jsonl
ENGINE = MergeTree()
PRIMARY KEY (session_id, message_uuid)
AS
WITH deduplicated AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY concat(coalesce(message_id, ''), ':', coalesce(request_id, ''))
            ORDER BY timestamp ASC
        ) as rn
    FROM claude_projects_jsonl_raw
)
SELECT * EXCEPT(rn)
FROM deduplicated
WHERE rn = 1 OR (message_id = '' AND request_id = '');

-- Display initialization summary
SELECT '=== Initialization Complete ===' as status FORMAT LineAsString;
SELECT concat('Loaded ', toString(count()), ' records from ', toString(count(DISTINCT _path)), ' files') as info 
FROM claude_projects_jsonl 
FORMAT LineAsString;
SELECT concat('Timezone: ', timezone()) as tz_info FORMAT LineAsString;

-- Quick preview
SELECT '' FORMAT LineAsString;
SELECT '=== Quick Summary ===' FORMAT LineAsString;
SELECT 
    count(DISTINCT session_id) as sessions,
    formatReadableQuantity(count()) as total_messages,
    formatReadableQuantity(countIf(type = 'user')) as user_messages,
    formatReadableQuantity(countIf(role = 'assistant')) as assistant_messages,
    count(DISTINCT project) as projects,
    count(DISTINCT date) as active_days
FROM claude_projects_jsonl
WHERE session_id != ''
FORMAT Pretty;

-- Common queries hint
SELECT '' FORMAT LineAsString;
SELECT '=== Interactive Mode - Example Queries ===' FORMAT LineAsString;
SELECT '-- Daily activity:' FORMAT LineAsString;
SELECT '-- SELECT date, count() as messages FROM claude_projects_jsonl GROUP BY date ORDER BY date DESC LIMIT 10;' FORMAT LineAsString;
SELECT date, count() as messages FROM claude_projects_jsonl GROUP BY date ORDER BY date DESC LIMIT 10 FORMAT Pretty;
SELECT '' FORMAT LineAsString;
SELECT '-- Top projects:' FORMAT LineAsString;
SELECT '-- SELECT project, count() as messages FROM claude_projects_jsonl WHERE project != \'\' GROUP BY project ORDER BY messages DESC LIMIT 10;' FORMAT LineAsString;
SELECT '' FORMAT LineAsString;
SELECT '-- Hourly pattern:' FORMAT LineAsString;
SELECT '-- SELECT hour, count() as messages, bar(count(), 0, 3000, 30) as pattern FROM claude_projects_jsonl GROUP BY hour ORDER BY hour;' FORMAT LineAsString;
SELECT '' FORMAT LineAsString;
SELECT '-- Tool usage:' FORMAT LineAsString;
SELECT '-- SELECT tool_name, count() as uses FROM claude_projects_jsonl WHERE tool_name != \'\' GROUP BY tool_name ORDER BY uses DESC LIMIT 10;' FORMAT LineAsString;
SELECT '' FORMAT LineAsString;
SELECT '-- Recent sessions:' FORMAT LineAsString;
SELECT '-- SELECT session_id, project, count() as messages, min(timestamp) as started FROM claude_projects_jsonl WHERE session_id != \'\' GROUP BY session_id, project ORDER BY started DESC LIMIT 10;' FORMAT LineAsString;
SELECT '' FORMAT LineAsString;

-- Recent Active Sessions
SELECT '=== Recent Active Sessions (Last 7 Days) ===' FORMAT LineAsString;
SELECT 
    session_id,
    project,
    count() as messages,
    formatDateTime(min(timestamp), '%m-%d %H:%i') as started,
    dateDiff('minute', min(timestamp), max(timestamp)) as duration_min
FROM claude_projects_jsonl
WHERE session_id != '' 
    AND timestamp > now() - INTERVAL 7 DAY
GROUP BY 1,2
HAVING messages > 10
ORDER BY min(timestamp) DESC
LIMIT 10
FORMAT Pretty;

SELECT '' FORMAT LineAsString;
SELECT '=== Actual Token Usage Summary ===' FORMAT LineAsString;
SELECT 
    formatReadableQuantity(sum(input_tokens)) as total_input_tokens,
    formatReadableQuantity(sum(output_tokens)) as total_output_tokens,
    formatReadableQuantity(sum(cache_creation_input_tokens)) as total_cache_creation,
    formatReadableQuantity(sum(cache_read_input_tokens)) as total_cache_read,
    formatReadableQuantity(sum(input_tokens + output_tokens + cache_creation_input_tokens + cache_read_input_tokens)) as total_all_tokens
FROM claude_projects_jsonl
WHERE input_tokens IS NOT NULL
FORMAT Pretty;

SELECT '' FORMAT LineAsString;
SELECT '=== Token Usage by Model ===' FORMAT LineAsString;
SELECT 
    model,
    formatReadableQuantity(sum(input_tokens)) as input,
    formatReadableQuantity(sum(output_tokens)) as output,
    formatReadableQuantity(sum(cache_creation_input_tokens)) as cache_creation,
    formatReadableQuantity(sum(cache_read_input_tokens)) as cache_read,
    formatReadableQuantity(sum(input_tokens + output_tokens + cache_creation_input_tokens + cache_read_input_tokens)) as total
FROM claude_projects_jsonl
WHERE model != ''
GROUP BY model
ORDER BY sum(input_tokens + output_tokens + cache_creation_input_tokens + cache_read_input_tokens) DESC
FORMAT Pretty;

SELECT '' FORMAT LineAsString;
SELECT '=== Token Usage by Hour of Day ===' FORMAT LineAsString;
SELECT 
    hour,
    formatReadableQuantity(sum(input_tokens + output_tokens)) as actual_tokens,
    bar(sum(input_tokens + output_tokens), 0, 100000, 30) as usage_pattern
FROM claude_projects_jsonl
WHERE input_tokens IS NOT NULL
GROUP BY hour
ORDER BY hour
FORMAT Pretty;

SELECT '' FORMAT LineAsString;
SELECT 'Type your SQL queries below. Use Ctrl+D to exit.' FORMAT LineAsString;
SELECT '' FORMAT LineAsString;
EOF

# Write initialization SQL to temp file
TMP_FILE="/tmp/claude_init_$$.sql"
echo "$INIT_SQL" > "$TMP_FILE"

# First run initialization for display
TEMP_DB_PATH=$(mktemp -d /tmp/claude_analysis.XXXXXX)
echo "Temporary database path: $TEMP_DB_PATH"

clickhouse local --multiquery --path "$TEMP_DB_PATH" --session_timezone="$TIMEZONE" < "$TMP_FILE"

echo "Entering interactive mode. Type your SQL queries below."
echo "desc claude_projects_jsonl; -- to see table schema"
# Re-run initialization in the temp directory and enter interactive mode
exec clickhouse local \
    --path "$TEMP_DB_PATH" \
    --session_timezone="$TIMEZONE" \
    --multiquery \
    --interactive \
    --format=Pretty

# Clean up (this won't be reached due to exec, but good practice)
rm -f "$TMP_FILE"
-- Claude Code Usage Analysis - Main Analysis Queries
-- Comprehensive analysis queries for Claude usage patterns
-- Author: Kazuki Matsuda
-- Date: 2025-09-09

-- ========================================
-- 1. Executive Summary
-- ========================================
SELECT '=== Executive Summary ===' as section FORMAT LineAsString;

SELECT 
    count(DISTINCT session_id) as sessions,
    formatReadableQuantity(count()) as messages,
    formatReadableQuantity(countIf(type = 'user')) as user_msgs,
    formatReadableQuantity(countIf(role = 'assistant')) as assistant_msgs,
    count(DISTINCT project) as projects,
    count(DISTINCT date) as active_days,
    concat(toString(min(date)), ' to ', toString(max(date))) as period
FROM claude_projects_jsonl
WHERE session_id != ''
FORMAT Pretty;

-- ========================================
-- 2. Daily Activity Trend (Last 14 Days)
-- ========================================
SELECT '' FORMAT LineAsString;
SELECT '=== Daily Activity Trend ===' as section FORMAT LineAsString;

SELECT 
    date,
    count(DISTINCT session_id) as sessions,
    formatReadableQuantity(count()) as messages,
    formatReadableQuantity(countIf(type = 'user')) as user,
    formatReadableQuantity(countIf(role = 'assistant')) as assistant,
    bar(count(), 0, 5000, 30) as activity_bar
FROM claude_projects_jsonl
WHERE date >= today() - 14
GROUP BY date
ORDER BY date DESC
LIMIT 14
FORMAT Pretty;

-- ========================================
-- 3. Top Projects by Activity
-- ========================================
SELECT '' FORMAT LineAsString;
SELECT '=== Top Projects by Activity ===' as section FORMAT LineAsString;

SELECT 
    substring(project, 1, 40) as project,
    count(DISTINCT session_id) as sessions,
    formatReadableQuantity(count()) as messages,
    count(DISTINCT git_branch) as branches,
    dateDiff('day', min(date), max(date)) + 1 as days,
    toString(max(date)) as last_active
FROM claude_projects_jsonl
WHERE project != ''
GROUP BY project
ORDER BY count() DESC
LIMIT 10
FORMAT Pretty;

-- ========================================
-- 4. Hourly Activity Pattern
-- ========================================
SELECT '' FORMAT LineAsString;
SELECT '=== Hourly Activity Pattern ===' as section FORMAT LineAsString;

SELECT 
    concat(toString(hour), ':00') as time,
    count() as messages,
    round(count() / count(DISTINCT date), 1) as avg_per_day,
    bar(count(), 0, 3500, 30) as pattern,
    concat(
        round(countIf(day_of_week NOT IN (6, 7)) * 100.0 / count(), 1), 
        '% weekday'
    ) as weekday_pct
FROM claude_projects_jsonl
WHERE hour IS NOT NULL
GROUP BY hour
ORDER BY hour
FORMAT Pretty;

-- ========================================
-- 5. Most Active Sessions
-- ========================================
SELECT '' FORMAT LineAsString;
SELECT '=== Most Active Sessions ===' as section FORMAT LineAsString;

SELECT 
    substring(session_id, 1, 8) as session,
    substring(project, 1, 30) as project,
    count() as msgs,
    concat(toString(dateDiff('minute', min(timestamp), max(timestamp))), ' min') as duration,
    toString(min(timestamp), 'MM-dd HH:mm') as started
FROM claude_projects_jsonl
WHERE session_id != ''
GROUP BY session_id, project
HAVING count() > 100
ORDER BY count() DESC
LIMIT 10
FORMAT Pretty;

-- ========================================
-- 6. Tool Usage Statistics
-- ========================================
SELECT '' FORMAT LineAsString;
SELECT '=== Tool Usage Statistics ===' as section FORMAT LineAsString;

SELECT 
    tool_name as tool,
    formatReadableQuantity(count()) as uses,
    count(DISTINCT session_id) as sessions,
    count(DISTINCT date) as days,
    bar(count(), 0, 2000, 30) as usage_bar
FROM claude_projects_jsonl
WHERE tool_name != ''
GROUP BY tool_name
ORDER BY count() DESC
LIMIT 15
FORMAT Pretty;

-- ========================================
-- 7. Weekly Summary
-- ========================================
SELECT '' FORMAT LineAsString;
SELECT '=== Weekly Summary ===' as section FORMAT LineAsString;

SELECT 
    toString(toStartOfWeek(date), 'MM-dd') as week_start,
    count(DISTINCT session_id) as sessions,
    formatReadableQuantity(count()) as messages,
    round(count() / 7.0, 1) as daily_avg,
    bar(count(), 0, 20000, 30) as activity
FROM claude_projects_jsonl
WHERE date >= today() - 56
GROUP BY toStartOfWeek(date)
ORDER BY toStartOfWeek(date) DESC
LIMIT 8
FORMAT Pretty;

-- ========================================
-- 8. Weekend vs Weekday Comparison
-- ========================================
SELECT '' FORMAT LineAsString;
SELECT '=== Weekend vs Weekday Activity ===' as section FORMAT LineAsString;

SELECT 
    if(day_of_week IN (6, 7), 'Weekend', 'Weekday') as day_type,
    formatReadableQuantity(count()) as total_messages,
    count(DISTINCT date) as active_days,
    count(DISTINCT session_id) as sessions,
    round(count() / count(DISTINCT date), 1) as msgs_per_day,
    round(count(DISTINCT session_id) / count(DISTINCT date), 1) as sessions_per_day
FROM claude_projects_jsonl
WHERE day_of_week IS NOT NULL
GROUP BY day_type
ORDER BY day_type DESC
FORMAT Pretty;
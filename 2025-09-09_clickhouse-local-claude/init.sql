-- Claude Code Usage Analysis - Initialization
-- Creates base table from JSONL files using JSONAsObject
-- Author: Kazuki Matsuda
-- Date: 2025-09-09

-- Create base table with all JSONL data using JSONAsObject path access
CREATE TABLE IF NOT EXISTS claude_projects_jsonl
ENGINE = Memory
AS 
SELECT 
    json.sessionId as session_id,
    json.uuid as message_uuid,
    json.parentUuid as parent_uuid,
    json.cwd as cwd,
    json.gitBranch as git_branch,
    toString(json.timestamp) as timestamp_str,
    if(json.timestamp IS NOT NULL, parseDateTimeBestEffort(toString(json.timestamp)), NULL) as timestamp,
    if(json.timestamp IS NOT NULL, toDate(parseDateTimeBestEffort(toString(json.timestamp))), NULL) as date,
    if(json.timestamp IS NOT NULL, toHour(parseDateTimeBestEffort(toString(json.timestamp))), NULL) as hour,
    if(json.timestamp IS NOT NULL, toDayOfWeek(parseDateTimeBestEffort(toString(json.timestamp))), NULL) as day_of_week,
    json.type as type,
    json.level as level,
    json.toolName as tool_name,
    json.version as claude_version,
    json.message as message,
    json.message.role as role,
    json.message.content as message_content,
    json.toolParams as tool_params,
    json.usage as usage,
    json.metadata as metadata,
    substring(toString(json.cwd), position(toString(json.cwd), 'github.com/') + 11, 100) as project,
    _path,
    json as raw_json
FROM file('./home/.claude/projects/*/*.jsonl', 'JSONAsObject') AS json;

-- Display initialization summary
SELECT '=== Initialization Complete ===' as status FORMAT LineAsString;
SELECT concat('Loaded ', toString(count()), ' records from ', toString(count(DISTINCT _path)), ' files') as info 
FROM claude_projects_jsonl 
FORMAT LineAsString;
SELECT concat('Timezone: ', timezone()) as tz_info FORMAT LineAsString;
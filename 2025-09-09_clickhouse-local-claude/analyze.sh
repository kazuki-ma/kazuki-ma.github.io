#!/bin/bash
#
# Claude Code Usage Analyzer with ClickHouse Local
# Main entry point for analyzing Claude usage patterns
#
# Usage:
#   ./analyze.sh                    # Run default analysis
#   ./analyze.sh analysis.sql       # Run specific analysis file
#   ./analyze.sh "SELECT ..."       # Run custom query
#   ./analyze.sh --interactive      # Interactive mode
#
# Author: Kazuki Matsuda
# Date: 2025-09-09

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INIT_SQL="$SCRIPT_DIR/init.sql"
DEFAULT_ANALYSIS="$SCRIPT_DIR/analysis.sql"

# Create symlink to home directory if it doesn't exist
if [ ! -L "$SCRIPT_DIR/home" ]; then
    ln -s "$HOME" "$SCRIPT_DIR/home"
fi

# Parse arguments
INTERACTIVE=false
QUERY_ARG=""

for arg in "$@"; do
    case $arg in
        --interactive|-i)
            INTERACTIVE=true
            ;;
        *)
            QUERY_ARG="$arg"
            ;;
    esac
done

# Change to script directory for relative paths to work
cd "$SCRIPT_DIR"

# Determine what to execute
if [ "$INTERACTIVE" = true ]; then
    echo "=== Claude Code Analysis - Interactive Mode ==="
    echo "Initializing database views..."
    echo ""
    
    # Run ClickHouse in interactive mode with initialization
    exec clickhouse local \
        --multiquery \
        --file "$INIT_SQL" \
        --interactive
        
elif [ -n "$QUERY_ARG" ]; then
    # Check if argument is a file or a query
    if [ -f "$QUERY_ARG" ]; then
        echo "=== Running analysis from $QUERY_ARG ==="
        # Combine init and query file
        cat "$INIT_SQL" > /tmp/claude_custom_analysis.sql
        echo "" >> /tmp/claude_custom_analysis.sql
        cat "$QUERY_ARG" >> /tmp/claude_custom_analysis.sql
        
        clickhouse local \
            --multiquery \
            --file /tmp/claude_custom_analysis.sql
        
        rm -f /tmp/claude_custom_analysis.sql
    else
        echo "=== Running custom query ==="
        # Run initialization and then the query
        echo "SELECT 'Initializing...' FORMAT LineAsString;" > /tmp/claude_query.sql
        cat "$INIT_SQL" >> /tmp/claude_query.sql
        echo "" >> /tmp/claude_query.sql
        echo "$QUERY_ARG;" >> /tmp/claude_query.sql
        
        clickhouse local \
            --multiquery \
            --file /tmp/claude_query.sql
        
        rm -f /tmp/claude_query.sql
    fi
else
    # Default: run standard analysis
    echo "=== Claude Code Usage Analysis ==="
    echo "Analyzing $(find home/.claude/projects -name "*.jsonl" 2>/dev/null | wc -l | xargs) session files..."
    echo ""
    
    # Combine init and analysis into single file
    cat "$INIT_SQL" > /tmp/claude_full_analysis.sql
    echo "" >> /tmp/claude_full_analysis.sql
    cat "$DEFAULT_ANALYSIS" >> /tmp/claude_full_analysis.sql
    
    # Run analysis with timezone support
    # Use TZ environment variable or default to Asia/Tokyo
    TIMEZONE="${TZ:-Asia/Tokyo}"
    cat /tmp/claude_full_analysis.sql | clickhouse local --multiquery --session_timezone="$TIMEZONE"
    
    rm -f /tmp/claude_full_analysis.sql
fi
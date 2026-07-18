#!/bin/bash
# TradingView Skill — CLI entry point
# Usage: ./tradingview.sh <action> [symbol] [timeframe]

set -e

MCP_DIR="$HOME/tradingview-mcp"
ACTION="${1:-status}"
SYMBOL="${2:-}"
TIMEFRAME="${3:-}"

# ── Helper: ensure TV is running with CDP ──
ensure_tv() {
  if curl -s "http://localhost:9222/json/version" > /dev/null 2>&1; then
    return 0
  fi
  echo '{"error": "TradingView CDP not responding. Run: pkill -f TradingView && ~/tradingview-mcp/scripts/launch_tv_debug_mac.sh"}'
  exit 1
}

# ── Helper: switch symbol if requested ──
maybe_switch_symbol() {
  if [ -n "$SYMBOL" ]; then
    node "$MCP_DIR/src/cli/index.js" symbol "$SYMBOL" > /dev/null 2>&1
    sleep 1
  fi
}

# ── Helper: switch timeframe if requested ──
maybe_switch_timeframe() {
  if [ -n "$TIMEFRAME" ]; then
    node "$MCP_DIR/src/cli/index.js" timeframe "$TIMEFRAME" > /dev/null 2>&1
    sleep 1
  fi
}

# ── Actions ──
case "$ACTION" in
  launch)
    echo "Killing existing TradingView..."
    pkill -f TradingView 2>/dev/null || true
    sleep 2
    echo "Launching with CDP on port 9222..."
    bash "$MCP_DIR/scripts/launch_tv_debug_mac.sh"
    echo "Waiting for chart to load..."
    sleep 3
    cd "$MCP_DIR" && node src/cli/index.js status
    ;;

  status)
    cd "$MCP_DIR" && node src/cli/index.js status
    ;;

  quote)
    ensure_tv
    maybe_switch_symbol
    maybe_switch_timeframe
    cd "$MCP_DIR" && node src/cli/index.js quote
    ;;

  ohlcv)
    ensure_tv
    maybe_switch_symbol
    maybe_switch_timeframe
    cd "$MCP_DIR" && node src/cli/index.js ohlcv --summary
    ;;

  values)
    ensure_tv
    maybe_switch_symbol
    maybe_switch_timeframe
    cd "$MCP_DIR" && node src/cli/index.js values
    ;;

  levels)
    ensure_tv
    cd "$MCP_DIR" && node src/cli/index.js data lines
    ;;

  labels)
    ensure_tv
    cd "$MCP_DIR" && node src/cli/index.js data labels
    ;;

  tables)
    ensure_tv
    cd "$MCP_DIR" && node src/cli/index.js data tables
    ;;

  screenshot)
    ensure_tv
    cd "$MCP_DIR" && node src/cli/index.js screenshot
    ;;

  full)
    ensure_tv
    maybe_switch_symbol
    maybe_switch_timeframe
    echo "--- Quote ---"
    cd "$MCP_DIR" && node src/cli/index.js quote
    echo ""
    echo "--- OHLCV Summary ---"
    cd "$MCP_DIR" && node src/cli/index.js ohlcv --summary
    echo ""
    echo "--- Indicator Values ---"
    cd "$MCP_DIR" && node src/cli/index.js values
    echo ""
    echo "--- Key Levels ---"
    cd "$MCP_DIR" && node src/cli/index.js data lines
    echo ""
    echo "--- Labels ---"
    cd "$MCP_DIR" && node src/cli/index.js data labels
    echo ""
    echo "--- Tables ---"
    cd "$MCP_DIR" && node src/cli/index.js data tables
    ;;

  *)
    echo "Usage: tradingview.sh <action> [symbol] [timeframe]"
    echo ""
    echo "Actions: launch, status, quote, ohlcv, values, levels, labels, tables, screenshot, full"
    echo ""
    echo "Examples:"
    echo "  tradingview.sh launch"
    echo "  tradingview.sh status"
    echo "  tradingview.sh full"
    echo "  tradingview.sh full AAPL"
    echo "  tradingview.sh quote ES1!"
    echo "  tradingview.sh ohlcv BTCUSD 15"
    exit 1
    ;;
esac

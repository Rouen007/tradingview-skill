---
name: tradingview
description: TradingView Desktop CDP skill — launch, health check, chart analysis, quote, OHLCV, indicator values, Pine levels/labels/tables, and screenshot via tradingview-mcp
version: 1.0.0
tags: [tradingview, chart, trading, cdp, stocks, futures]
---

# TradingView Skill

Control TradingView Desktop via Chrome DevTools Protocol (CDP) using the tradingview-mcp project.

## Setup (First Time)

### 1. Close existing TradingView

```bash
pkill -f TradingView
```

### 2. Launch TradingView with CDP enabled

```bash
~/tradingview-mcp/scripts/launch_tv_debug_mac.sh
```

### 3. Verify connection

```bash
tv status
```

Should return `"cdp_connected": true`.

## Usage

Invoke with `/tradingview` followed by the action.

## Actions

| Action | Description | Notes |
|--------|-------------|-------|
| `launch` | Kill existing TV, relaunch with CDP, wait for ready | Full startup sequence |
| `status` | Check CDP connection + current chart state | Quick health check |
| `quote` | Real-time price, OHLC, volume for current symbol | ~200 bytes |
| `ohlcv` | OHLCV bar data summary (high, low, range, change%, last 5 bars) | Use summary mode |
| `values` | All visible indicator values (RSI, MACD, EMAs, VWAP, etc.) | ~500 bytes |
| `levels` | Horizontal price levels from custom Pine indicators | Key support/resistance |
| `labels` | Text annotations with prices from Pine indicators | Context labels |
| `tables` | Table data from Pine indicators (session stats, dashboards) | Formatted rows |
| `screenshot` | Capture chart screenshot | Returns file path |
| `full` | Complete analysis: quote + ohlcv + values + levels + labels | Full picture |

## Discord 联动用法

配合 `discord-finance-summary` skill 使用时，从群内提取关键价位后直接验证：

```bash
# 1. 拉报价确认当前位置
cd ~/tradingview-mcp && node src/cli/index.js quote --symbol 'SP:SPX' --timeframe '60'

# 2. 拉 5min OHLCV 看近期价格行为
cd ~/tradingview-mcp && node src/cli/index.js ohlcv --symbol 'SP:SPX' --timeframe '5'

# 3. 截图（可选）
cd ~/tradingview-mcp && node src/cli/index.js screenshot
```

**常用 symbol 对照：**

| 群内说法 | TradingView symbol |
|----------|--------------------|
| SPX / 标普 | `SP:SPX` 或 `CME_MINI:MES1!` |
| 纳指 / QQQ | `NASDAQ:QQQ` 或 `CME_MINI:MNQ1!` |
| 黄金 / GLD | `COMEX:GC1!` 或 `AMEX:GLD` |
| 比特币 | `BITSTAMP:BTCUSD` |

## Parameters

- `action` (required): One of the actions above
- `symbol` (optional): Switch to this symbol before analysis (e.g., "ES1!", "AAPL", "BTCUSD")
- `timeframe` (optional): Switch timeframe (e.g., "1", "5", "15", "60", "D", "W")

## Quick Launch Sequence

```bash
pkill -f TradingView && sleep 2 && ~/tradingview-mcp/scripts/launch_tv_debug_mac.sh && sleep 3 && cd ~/tradingview-mcp && node src/cli/index.js status
```

## Architecture

```
Claude Code → tradingview.sh (skill entry) → tv CLI (src/cli/index.js) → CDP (localhost:9222) → TradingView Desktop
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `CDP connection failed` | Run `launch` action to restart TV with CDP |
| `No TradingView chart target found` | Make sure a chart tab is open in TV |
| `TradingView not found` | Install TV to /Applications or ~/Applications |
| Stale data | TV may need a moment after launch; retry `status` |

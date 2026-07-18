# tradingview

A Claude Code / Claude skill that drives TradingView Desktop via Chrome DevTools Protocol (CDP), for quotes, OHLCV, indicator values, Pine Script levels/labels/tables, and screenshots — all from the command line.

It's a thin wrapper (`tradingview.sh`) around [tradingview-mcp](https://github.com/tradesdontlie/tradingview-mcp), which does the actual CDP work.

## Prerequisites

- macOS with **TradingView Desktop** installed
- [tradingview-mcp](https://github.com/tradesdontlie/tradingview-mcp) cloned to `~/tradingview-mcp` with its dependencies installed:
  ```bash
  git clone https://github.com/tradesdontlie/tradingview-mcp.git ~/tradingview-mcp
  cd ~/tradingview-mcp && npm install
  ```

## Install

```bash
git clone https://github.com/Rouen007/tradingview-skill.git ~/.claude/skills/tradingview
chmod +x ~/.claude/skills/tradingview/tradingview.sh
ln -sfn ~/.claude/skills/tradingview/tradingview.sh ~/.local/bin/tv-skill   # optional
```

## First Run

```bash
pkill -f TradingView
~/tradingview-mcp/scripts/launch_tv_debug_mac.sh
./tradingview.sh status
```

Should report `"cdp_connected": true`.

## Usage

```bash
./tradingview.sh <action> [symbol] [timeframe]
```

As a Claude skill: `/tradingview <action>`.

## Actions

| Action | Description | Notes |
|--------|-------------|-------|
| `launch` | Kill existing TV, relaunch with CDP, wait for ready | Full startup sequence |
| `status` | Check CDP connection + current chart state | Quick health check |
| `quote` | Real-time price, OHLC, volume for current symbol | ~200 bytes |
| `ohlcv` | OHLCV bar data summary (high, low, range, change%, last 5 bars) | Summary mode |
| `values` | All visible indicator values (RSI, MACD, EMAs, VWAP, etc.) | ~500 bytes |
| `levels` | Horizontal price levels from custom Pine indicators | Key support/resistance |
| `labels` | Text annotations with prices from Pine indicators | Context labels |
| `tables` | Table data from Pine indicators (session stats, dashboards) | Formatted rows |
| `screenshot` | Capture chart screenshot | Returns file path |
| `full` | Complete analysis: quote + ohlcv + values + levels + labels | Full picture |

### Examples

```bash
./tradingview.sh status
./tradingview.sh full
./tradingview.sh full AAPL
./tradingview.sh quote ES1!
./tradingview.sh ohlcv BTCUSD 15
```

## Parameters

- `action` (required): one of the actions above
- `symbol` (optional): switch to this symbol before analysis (e.g. `ES1!`, `AAPL`, `BTCUSD`)
- `timeframe` (optional): switch timeframe (e.g. `1`, `5`, `15`, `60`, `D`, `W`)

## Architecture

```
tradingview.sh (skill entry) → tv CLI (tradingview-mcp: src/cli/index.js) → CDP (localhost:9222) → TradingView Desktop
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `CDP connection failed` | Run `launch` action to restart TV with CDP |
| `No TradingView chart target found` | Make sure a chart tab is open in TV |
| `TradingView not found` | Install TV to `/Applications` or `~/Applications` |
| Stale data | TV may need a moment after launch; retry `status` |

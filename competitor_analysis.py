import yfinance as yf
import pandas as pd

# ── Currency conversion rates to USD (approximate 2024 averages) ──────────
# Source: World Bank / XE.com averages FY2024
FX = {
    "LKR": 1 / 300,     # Sri Lanka Rupee  — 1 LKR = 0.00333 USD
    "MYR": 1 / 4.47,    # Malaysian Ringgit
    "INR": 1 / 83.5,    # Indian Rupee
    "BDT": 1 / 110.0,   # Bangladeshi Taka
    "IDR": 1 / 15800,   # Indonesian Rupiah
    "USD": 1.0
}

# ── Currency per ticker ───────────────────────────────────────────────────
TICKER_CCY = {
    "6888.KL":      "MYR",
    "BHARTIARTL.NS":"INR",
    "ISAT.JK":      "IDR",
    "TLKM.JK":      "IDR",
}

# ── Dialog Axiata — manual entry from Annual Reports (more reliable) ──────
# FY2024 figures. Revenue & EBITDA from our verified PDF extraction.
# Market Cap: ~LKR 69.9Bn (share price ~LKR 8.51 x 8,210Mn shares approx)
DIALOG_MANUAL = {
    "Company":           "Dialog Axiata (LK)",
    "Market Cap (USD Mn)": round(69_900 * FX["LKR"], 1),
    "Revenue (USD Mn)":    round(171_170 * FX["LKR"], 1),
    "EBITDA (USD Mn)":     round(66_275 * FX["LKR"], 1),
    "Net Margin %":        round(12_435 / 171_170 * 100, 2),
    "EBITDA Margin %":     round(66_275 / 171_170 * 100, 2),
    "Debt/Equity":         round(107_694 / 78_280, 2),
    "ROE %":               round(12_435 / 78_280 * 100, 2),
    "P/E Ratio":           round(69_900 / 12_435, 2),
    "Source": "Dialog Axiata Annual Report 2024 (PDF verified)"
}

# ── Peers to fetch from yfinance ──────────────────────────────────────────
tickers = {
    "Axiata Group (MY)":  "6888.KL",
    "Bharti Airtel (IN)": "BHARTIARTL.NS",
    "Indosat (ID)":       "ISAT.JK",
    "Telkom Indonesia":   "TLKM.JK",
}

print("Fetching competitor data...\n")
results = [DIALOG_MANUAL]  # Dialog goes in first — manual data

for company, ticker in tickers.items():
    try:
        stock = yf.Ticker(ticker)
        info  = stock.info

        ccy = TICKER_CCY.get(ticker, "USD")
        fx  = FX[ccy]

        mkt_cap  = info.get("marketCap",    0) or 0
        revenue  = info.get("totalRevenue", 0) or 0
        ebitda   = info.get("ebitda",       0) or 0
        margins  = info.get("profitMargins",0) or 0
        roe      = info.get("returnOnEquity",0) or 0
        de       = info.get("debtToEquity", 0) or 0
        pe       = info.get("trailingPE",   0) or 0

        # Guard: avoid division by zero
        ebitda_margin = (ebitda / revenue * 100) if revenue else 0

        results.append({
            "Company":             company,
            "Market Cap (USD Mn)": round(mkt_cap  * fx / 1_000_000, 1),
            "Revenue (USD Mn)":    round(revenue  * fx / 1_000_000, 1),
            "EBITDA (USD Mn)":     round(ebitda   * fx / 1_000_000, 1),
            "Net Margin %":        round(margins  * 100, 2),
            "EBITDA Margin %":     round(ebitda_margin, 2),
            "Debt/Equity":         round(de, 2),
            "ROE %":               round(roe * 100, 2),
            "P/E Ratio":           round(pe, 2),
            "Source":              f"yfinance · {ticker} · FX: 1 {ccy} = {fx:.6f} USD"
        })

        print(f"✅ {company} ({ccy} → USD at {fx:.5f}) — done")

    except Exception as e:
        print(f"❌ {company} — failed: {e}")

# ── Build DataFrame ───────────────────────────────────────────────────────
df = pd.DataFrame(results)

# Reorder columns — Source goes last
cols = ["Company","Market Cap (USD Mn)","Revenue (USD Mn)",
        "EBITDA (USD Mn)","Net Margin %","EBITDA Margin %",
        "Debt/Equity","ROE %","P/E Ratio","Source"]
df = df[cols]

# ── Display ───────────────────────────────────────────────────────────────
print("\n========== COMPETITOR BENCHMARKING TABLE (USD) ==========")
pd.set_option("display.max_columns", None)
pd.set_option("display.width", 200)
print(df.to_string(index=False))

# ── Export ────────────────────────────────────────────────────────────────
df.to_excel("competitor_benchmarking.xlsx", index=False)
print("\n✅ Saved to competitor_benchmarking.xlsx")

# ── Analyst insight print ─────────────────────────────────────────────────
print("\n========== QUICK ANALYST READ ==========")
dialog_row = df[df["Company"] == "Dialog Axiata (LK)"].iloc[0]
avg_ebitda_margin = df["EBITDA Margin %"].mean()
avg_de = df["Debt/Equity"].mean()

print(f"Dialog EBITDA Margin : {dialog_row['EBITDA Margin %']:.1f}%  |  Peer Average: {avg_ebitda_margin:.1f}%")
print(f"Dialog Debt/Equity   : {dialog_row['Debt/Equity']:.2f}x  |  Peer Average: {avg_de:.2f}x")
print(f"Dialog ROE           : {dialog_row['ROE %']:.1f}%  |  Peer Average: {df['ROE %'].mean():.1f}%")
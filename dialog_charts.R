# ── Chart 1: Revenue & EBITDA Trend 2020-2024 ─────────────────────────────
# Dialog Axiata PLC | Source: Annual Reports (PDF verified)

library(ggplot2)
library(dplyr)
library(scales)

# Step 1: Enter your data
years  <- c(2020, 2021, 2022, 2023, 2024)
rev    <- c(120142, 141915, 178131, 187813, 171170)
ebitda <- c(51221,  59222,  43663,  61918,  66276)

# Step 2: Build a dataframe
df <- data.frame(
  Year   = rep(years, 2),
  Value  = c(rev, ebitda),
  Metric = c(rep("Revenue", 5), rep("EBITDA", 5))
)

# Step 3: Plot
chart1 <- ggplot(df, aes(x = Year, y = Value, color = Metric, group = Metric)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3.5) +
  geom_label(aes(label = paste0(round(Value/1000, 1), "B")),
             nudge_y = 5000, size = 3, show.legend = FALSE) +
  scale_y_continuous(labels = comma) +
  scale_x_continuous(breaks = years) +
  scale_color_manual(values = c("Revenue" = "#1F3864", "EBITDA" = "#C9A227")) +
  labs(
    title    = "Dialog Axiata PLC — Revenue & EBITDA Trend",
    subtitle = "FY2020 to FY2024  |  LKR Millions  |  Group",
    x        = "Year",
    y        = "LKR Millions",
    color    = "",
    caption  = "Source: Dialog Axiata Annual Reports 2020–2024"
  ) +
  theme_minimal() +
  theme(
    plot.title    = element_text(size = 14, face = "bold", color = "#1F3864"),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    plot.caption  = element_text(size = 8,  color = "grey60"),
    legend.position = "top"
  )

# Step 4: Save
ggsave("chart1_revenue_ebitda_trend.png", chart1,
       width = 10, height = 6, dpi = 300)

print("Chart 1 saved.")

# ── Chart 2: Margin Analysis 2020-2024 ────────────────────────────────────

years       <- c(2020, 2021, 2022, 2023, 2024)
gross_margin  <- c(43.0, 43.4, 33.8, 35.0, 42.5)
ebitda_margin <- c(42.6, 41.7, 24.5, 33.0, 38.7)
net_margin    <- c(10.0,  12.0, -18.8, 10.7,  7.3)

df2 <- data.frame(
  Year   = rep(years, 3),
  Margin = c(gross_margin, ebitda_margin, net_margin),
  Type   = c(rep("Gross Margin",  5),
             rep("EBITDA Margin", 5),
             rep("Net Margin",    5))
)

chart2 <- ggplot(df2, aes(x = Year, y = Margin, color = Type, group = Type)) +
  geom_line(linewidth = 1.2) +
  geom_point(size = 3.5) +
  geom_label(aes(label = paste0(round(Margin, 1), "%")),
             nudge_y = 1.5, size = 2.8, show.legend = FALSE) +
  geom_hline(yintercept = 0, linetype = "dashed", color = "grey50") +
  scale_x_continuous(breaks = years) +
  scale_color_manual(values = c(
    "Gross Margin"  = "#1F3864",
    "EBITDA Margin" = "#C9A227",
    "Net Margin"    = "#C00000"
  )) +
  labs(
    title    = "Dialog Axiata PLC — Margin Analysis",
    subtitle = "FY2020 to FY2024  |  Percentage of Revenue  |  Group",
    x        = "Year",
    y        = "Margin %",
    color    = "",
    caption  = "Source: Dialog Axiata Annual Reports 2020–2024"
  ) +
  theme_minimal() +
  theme(
    plot.title    = element_text(size = 14, face = "bold", color = "#1F3864"),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    plot.caption  = element_text(size = 8,  color = "grey60"),
    legend.position = "top"
  )

ggsave("chart2_margin_analysis.png", chart2,
       width = 10, height = 6, dpi = 300)

print("Chart 2 saved.")

# ── Chart 3: Competitor EBITDA Margin Benchmarking ────────────────────────

companies <- c("Dialog Axiata\n(LK)", "Axiata Group\n(MY)", 
               "Bharti Airtel\n(IN)", "Indosat\n(ID)", 
               "Telkom\nIndonesia")

ebitda_margins <- c(38.7, 42.4, 52.0, 37.2, 41.8)

# Dialog gets a different colour so it stands out
bar_colors <- c("#C9A227", "#4472C4", "#4472C4", "#4472C4", "#4472C4")

df3 <- data.frame(
  Company = factor(companies, levels = companies),
  Margin  = ebitda_margins,
  Color   = bar_colors
)

# Peer average line
peer_avg <- mean(ebitda_margins[-1])  # exclude Dialog

chart3 <- ggplot(df3, aes(x = Company, y = Margin, fill = Company)) +
  geom_col(width = 0.6, show.legend = FALSE) +
  geom_hline(yintercept = peer_avg,
             linetype = "dashed", color = "#C00000", linewidth = 0.8) +
  annotate("text", x = 5.4, y = peer_avg + 1.2,
           label = paste0("Peer avg: ", round(peer_avg, 1), "%"),
           color = "#C00000", size = 3.2, fontface = "bold") +
  geom_text(aes(label = paste0(Margin, "%")),
            vjust = -0.5, size = 3.8, fontface = "bold") +
  scale_fill_manual(values = bar_colors) +
  scale_y_continuous(limits = c(0, 62), labels = function(x) paste0(x, "%")) +
  labs(
    title    = "EBITDA Margin — Dialog Axiata vs Regional Peers",
    subtitle = "FY2024  |  Dialog highlighted in gold  |  USD comparable basis",
    x        = "",
    y        = "EBITDA Margin %",
    caption  = "Sources: Dialog Axiata Annual Report 2024 (PDF verified) · Peers: yfinance API"
  ) +
  theme_minimal() +
  theme(
    plot.title    = element_text(size = 14, face = "bold", color = "#1F3864"),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    plot.caption  = element_text(size = 8,  color = "grey60"),
    axis.text.x   = element_text(size = 10, color = "#1F3864", face = "bold")
  )

ggsave("chart3_competitor_ebitda.png", chart3,
       width = 10, height = 6, dpi = 300)

print("Chart 3 saved.")

# ── Regression: Does Total Debt predict Revenue? ──────────────────────────

# Data from Dialog Annual Reports 2020-2024
debt    <- c(40426, 41836, 103590, 122765, 107694)
revenue <- c(120142, 141915, 178131, 187813, 171170)

# Run regression
model <- lm(revenue ~ debt)
summary(model)

# Plot regression
df_reg <- data.frame(debt, revenue)

chart4 <- ggplot(df_reg, aes(x = debt, y = revenue)) +
  geom_point(size = 4, color = "#1F3864") +
  geom_smooth(method = "lm", color = "#C9A227", se = TRUE) +
  geom_text(aes(label = c("2020","2021","2022","2023","2024")),
            vjust = -1, size = 3.5, color = "#1F3864") +
  scale_x_continuous(labels = comma) +
  scale_y_continuous(labels = comma) +
  labs(
    title    = "Dialog Axiata — Does Debt Drive Revenue?",
    subtitle = "Simple Linear Regression  |  FY2020–FY2024  |  LKR Millions",
    x        = "Total Debt (LKR Mn)",
    y        = "Revenue (LKR Mn)",
    caption  = "Source: Dialog Axiata Annual Reports 2020–2024"
  ) +
  theme_minimal() +
  theme(
    plot.title    = element_text(size = 14, face = "bold", color = "#1F3864"),
    plot.subtitle = element_text(size = 10, color = "grey40"),
    plot.caption  = element_text(size = 8,  color = "grey60")
  )

ggsave("chart4_regression.png", chart4,
       width = 10, height = 6, dpi = 300)

print("Chart 4 — Regression saved.")
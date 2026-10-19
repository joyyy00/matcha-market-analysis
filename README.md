# Matcha Market Intelligence: Consumer Demand & Content Analysis 

<img width="1243" height="700" alt="image" src="https://github.com/user-attachments/assets/16bb4f3d-bd0f-4313-b8f1-0a167d5f6f0a" />

Check out the [dashboard](https://019ead93-3cc7-3c7f-40c7-048e2cc8f2f3.share.connect.posit.cloud/#analysis)

## Summary 
An end-to-end data pipeline and business intelligence dashboard analyzing the US consumer market for Matcha. 
By integrating macro-level Google Trends search volume (2021–2026) with micro-level TikTok engagement metrics (~520 videos), 
this analysis bridges social media content strategy with long-term market stability forecasting.

## Insights
* **The Trailing 12-Month (TTM) Growth:** Matcha search interest experienced a **+235.8%** Trailing 12-Month baseline growth 
    (June 2025–May 2026) compared to the initial 12-month baseline, indicating aggressive but sustained market penetration.
    
* **Volatility & Market Predictability:** By engineering a Growth-Stability Matrix and establishing a **0.75 Coefficient of 
    Variation (CV)** threshold, the analysis mathematically proves Matcha behaves as a **low-volatility** staple.
    
* **Commercial Dependency on Flavor Innovation:** Matrix cross-filtering revealed a **> 33%** overlap between commercial beverage 
    content such as Starbucks and flavor innovation tags. This indicates that consumers are attracted to novel flavor 
    combinations (like strawberry or ube) and brands capitalize on that idea to maintain relevance and capture engagement.
    
* **The Engagement Parity Multiplier:** Calculated a **0.9x** engagement parity metric between Traditional/Ceremonial matcha content 
    and massive commercial brand content. This proves that while traditional content generates fewer raw views, its active audience 
    engagement efficiency is nearly identical to corporate giants.

## Analytics & Methodology

This project goes beyond surface-level aggregation, utilizing advanced data engineering and statistical smoothing to uncover true market signals.

*   **Composite Feature Engineering:** Raw TikTok metrics (likes, comments, shares, saves) were synthesized into a unified `Engagement Rate` composite 
    feature, normalizing interaction intensity against total video exposure.
*   **Seasonality Aggregation:** Grouped time-series data by month and extracted the mean search interest to build a seasonal baseline, exposing heavy 
    Spring demand cycles while stripping out year-over-year volume inflation.
*   **Trailing Twelve-Month (TTM) Cutoffs:** Growth rates were calculated using programmatic `head(12)` and `tail(12)` trailing functions, effectively 
    neutralizing the statistical bias caused by mid-year data cutoffs.
*   **Boolean Intersection Profiling:** Utilized non-mutually exclusive logical tagging to isolate categorical overlap, mathematically proving the 
    dependency of commercial beverage brands on novel flavor trends.

## Technical Stack

*   **Data Acquisition:** Apify API (TikTok), Google Trends
*   **Data Processing:** R (`dplyr`, `tidyr`, `lubridate`)
*   **Visualization:** R (`ggplot2` - custom matrix, time-series plot, bar chart, bee swarm plot)
*   **Dashboard Deployment:** Quarto (Markdown-based, static HTML rendering)

## Data & Tagging Limitations
The following constraints apply to this analysis:

*   **Google Trends Data:** The data represents a relative search index (scaled 0-100), not absolute search volume. It is highly sensitive to normalization 
    effects over time and cannot definitively distinguish between informational curiosity and actual purchase intent.
*   **TikTok Data:** Video collection relied on hashtag scraping via the Apify API, therefore reflecting a partial view of platform activity; content without 
    relevant hashtags is not captured. Additionally, engagement metrics (views, likes, saves) reflect digital attention and brand affinity, which do not 
    translate linearly into point-of-sale conversion.
*   **Tagging System:** Content categorization (e.g.,"Traditional", "Flavors") was executed using a rule-based keyword detection pipeline applied 
    to video captions. This represents heuristic content signaling rather than deep semantic or NLP-driven sentiment analysis.

## Local Setup & Reproducibility 

To run this dashboard locally, ensure you have [R](https://cran.r-project.org/) and [Quarto](https://quarto.org/docs/get-started/) installed on your machine.

**1. Clone the repository:**
```bash
git clone https://github.com/joyyy00/matcha-market-analysis.git
cd matcha-market-analysis
```
**2. Install required packages:**
```bash
install.packages(c("tidyverse", "arrow", "scales", "ggrepel", "ggbeeswarm"))
```

**3. Render Quarto dashboard:**
```bash
quarto render matcha_dashboard1.qmd
```

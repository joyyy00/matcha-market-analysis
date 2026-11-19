# Matcha Market Intelligence: Consumer Demand & Content Analysis 

<img width="1161" height="623" alt="Screenshot 2026-11-19 140145" src="https://github.com/user-attachments/assets/cdab7fd3-09b9-422e-8c2d-933f5bd59c67"/>

Check out the [dashboard](https://01a1f5e3-8f71-e97b-1a6c-0200d0c82615.share.connect.posit.cloud/)

## Summary 
An end-to-end data pipeline and business intelligence dashboard analyzing the US consumer market for Matcha. 
By integrating macro-level Google Trends search interest (2021–2026) with micro-level TikTok engagement metrics (about 560 videos), this analysis bridges social media content strategy with long-term market variability.

## Stakeholder Scenario
A marketing lead at a local US cafe wants to decide whether matcha is a year round line or a short seasonal drop, and how to split the content budget.

**Business Question:** Over the last five years in the US, has matcha search interest behaved like a stable beverage or a temporary trend, and which content type deserves the posting budget?


## Insights
- **The Long-Term Growth:** The search interest experienced a **+235.8%** increase trailing 12 months ending May 2026 versus the 12 months ending May 2022. 
- **Volatility & Market Predictability:** Matcha is the fastest-growing series in the set, with a coefficient of variation of 0.53: above 
    the set median (~0.21), well below pumpkin spice latte (1.40).
- **Starbucks and Flavor Overlap:** **36.1%** of Starbucks-tagged videos also carry a flavor keyword such as strawberry or ube. Dropping broad tokens such as sugar, fruit, and butter leaves this share unchanged.
- **Engagement and Reach:** Among videos with at least 1,000 views, Ceremonial/Traditional content has a median engagement rate **0.97×** Starbucks (121 videos, median 94,000 views, versus 150 videos and a median of 160,850 views). The rates are about equal. Starbucks has the larger reach.

## Decisions
- **Promote matcha in spring and keep it on the menu the rest of the year.** Search interest is up 235.8% on a trailing 12-month basis, the fastest gain in this set. Variability is 0.53, above the median of about 0.21 and below pumpkin spice latte at 1.40. After removing the multi-year 
rise, March–May is still the high and November is still the low, at 0.87 of a normal month. Revisit this if the March–May lift disappears, or if variability rises toward 1.40.
- **Put the posting budget on cafe-drink videos.** Among videos with at least 1,000 views, captions with "latte" lead both measures: 315 videos, a median of 285,800 views, and a 7.6% median engagement rate.
- **Use flavor and ceremonial posts as support, not as the reach plan.** A flavor word appears in 36.1% of Starbucks-tagged videos. Inside that set, captions without a flavor word have the higher median views, 246,600 versus 91,600. Flavor-tagged videos overall have a 7.1% engagement 
rate and a median of 102,850 views. Ceremonial posts match the Starbucks tag on engagement at 0.97× and reach fewer people, a median of 94,000 views versus 160,850. Those Starbucks views are spread across many creators, with at most 3 videos from any one account, so they do not transfer 
to this brand’s own account.

## Analytics & Methodology
*   **Composite Feature Engineering:** Raw TikTok metrics (likes, comments, shares, saves) were synthesized into a unified `Engagement Rate` composite 
    feature, normalizing interaction intensity against total video exposure.
*   **Detrended Seasonality:** Each month is divided by that keyword's trailing 12-month mean, then averaged by calendar month. This removes the rise in the level of the series. Matcha's detrended index still peaks in March–May and is lowest in November.
*   **Trailing Twelve-Month (TTM) Cutoffs:** Growth rates were calculated using programmatic `head(12)` and `tail(12)` trailing functions, effectively 
    neutralizing the statistical bias caused by mid-year data cutoffs.
*   **Overlapping Tags:** Videos can carry more than one theme. The Starbucks flavor figure is the share of Starbucks-tagged videos that also match a specific flavor keyword. Theme frequency is the share of videos, not the share of tags.

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
install.packages(c("tidyverse", "arrow", "scales", "ggrepel", "zoo", ggbeeswarm", "readxl", "openxlsx", "httr2"))
```

**3. Render Quarto dashboard:**
```bash
quarto render matcha_dashboard.qmd
```

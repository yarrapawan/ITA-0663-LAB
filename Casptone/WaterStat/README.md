# WaterStat: An Interactive Statistical Framework for Water Quality Assessment and Potability Analysis Using R and Shiny

**B.Tech CSE Major Project** | **Software-Only Analytics Platform** (No Arduino, ESP32, or IoT hardware required)

WaterStat is an upload-driven statistical computing platform developed in **R and R Shiny**. It automates multi-parameter water data validation, exploratory visualization across all major distribution and correlation chart types, hypothesis testing, PCA dimensionality reduction, and logistic regression potability modeling.

---

## 📂 Project Presentation Deliverables

This repository includes a complete academic presentation package tailored for B.Tech project reviews and viva defense:

1. **PowerPoint Presentation Deck:** [`WaterStat_BTech_CSE_Presentation.pptx`](file:///d:/R%20Program/WaterStat/WaterStat_BTech_CSE_Presentation.pptx)
   - 16:9 Widescreen format, 12 professional academic slides.
   - White/light background with a modern academic blue/teal theme (`#0f766e`, `#0284c7`).
   - Includes real literature review table, architecture mapping, and embedded speaker notes.
2. **Interactive Web Presentation:** [`presentation.html`](file:///d:/R%20Program/WaterStat/presentation.html)
   - Open directly in any web browser (`Chrome`, `Edge`, `Firefox`).
   - Supports keyboard navigation (Arrow keys / Spacebar) and an interactive speaker script drawer.
3. **Viva Defense & Script Guide:** [`PRESENTATION_NOTES.md`](file:///d:/R%20Program/WaterStat/PRESENTATION_NOTES.md)
   - 10–12 minute slide-by-slide verbal script with timing cues.
   - Top 10 anticipated viva questions with technical answers (Welch t-test, Tukey IQR, Odds Ratios, VIF, PCA, and data leakage prevention).

---

## 🏗️ System Architecture (4 Modules)

WaterStat is strictly structured into **four cohesive modules**:

```text
User Interaction (Web UI)
       ↓
CSV / Excel Dataset Upload
       ↓
Module 1: Water Quality Data Acquisition & Preprocessing
   • Header auto-normalization (e.g. ph -> pH)
   • Physical boundary validation (pH 0–14, non-negativity)
   • Tukey 1.5x IQR outlier detection & missing value profiling
   • Interactive Data Explorer (raw vs EDA-ready toggle)
       ↓
Module 2: Exploratory & Descriptive Statistical Analysis
   • Univariate: Histograms with normal curves, Kernel Density Estimation, Boxplots, Violin plots
   • Bivariate: Scatter plots with linear regression fit lines & 95% CI bands
   • Comparative: Standardized Z-Score boxplots & Mean ± SE bar charts across all 9 parameters
   • Correlation: Pearson & Spearman heatmaps with significance tables (alpha = 0.05)
   • Descriptive statistics & potability group summary tables
       ↓
Module 3: Inferential Statistical Analysis & Modeling
   • Welch two-sample t-tests with Cohen's d effect sizes
   • One-Way ANOVA with assumption diagnostics (Shapiro-Wilk, Levene, Kruskal-Wallis, Q-Q plots)
   • Chi-Square test of independence with Cramer's V
   • Multiple Linear Regression (MLR) with VIF checks & 3 residual diagnostic plots
   • Principal Component Analysis (PCA Scree, Biplot, and Variable Contributions)
   • Stratified Logistic Regression training (Odds Ratios per +1 SD, 95% Wald CIs)
   • Evaluation: Confusion Matrix heatmap, ROC/AUC, Calibration curve, Threshold sweeps (0.1–0.9)
       ↓
Module 4: Interactive R Shiny Application & Dashboard
   • Batch Dataset Potability Assessment & probability distribution
   • Single-Sample Custom Laboratory Assessment Calculator with extrapolation guards
   • Consolidated Export Center for multi-section CSV reports
```

---

## 🧪 Evaluated Water Quality Parameters (9 Physicochemical Features)

1. **pH:** Acid-base balance (permissible: 6.5–8.5)
2. **Hardness:** Calcium & magnesium mineral concentrations (mg/L)
3. **Solids (TDS):** Total dissolved solids in parts per million (ppm)
4. **Chloramines:** Disinfectant concentration (ppm)
5. **Sulfate:** Naturally occurring dissolved sulfate salts (mg/L)
6. **Conductivity:** Electrical conductance of dissolved ions (μS/cm)
7. **Organic Carbon:** Total organic carbon from decaying matter (ppm)
8. **Trihalomethanes:** Chemical disinfection byproducts (μg/L)
9. **Turbidity:** Measure of water clarity and suspended particulate matter (NTU)
- **Target Label:** `Potability` (0 = Non-potable, 1 = Potable)

---

## 🚀 Setup & Execution Instructions

### Prerequisites
Install [R (v4.0 or later)](https://cran.r-project.org/).

### Required R Packages
Open R or RStudio and execute:
```r
install.packages(c(
  "shiny", "bslib", "plotly", "DT", "ggplot2", 
  "dplyr", "tidyr", "readr", "readxl", "psych", 
  "car", "FactoMineR", "factoextra"
))
```

### Launch the Application
Run from this directory:
```r
shiny::runApp()
```
Or from the terminal:
```powershell
Rscript -e "shiny::runApp()"
```

---

## 🔒 Preprocessing Paths & Data Leakage Prevention

- **EDA Path:** Duplicates removed, physically invalid values set to `NA`. **Zero imputation** is performed so visualizations reflect true distributions.
- **Statistical Testing Path:** Each test uses complete pairwise observations for its respective parameters.
- **Machine Learning Path:** Stratified train/test split is applied first. Median imputation, log1p(Solids), and Z-score standardization are learned strictly from the **training set only** and reapplied to test sets and new custom samples.

"""
Generate updated professional B.Tech CSE Project Presentation PowerPoint (.pptx)
Title: WaterStat: An Interactive Statistical Framework for Water Quality Assessment and Potability Analysis Using R and Shiny

Features:
- Dedicated description slide for EACH of the 4 modules in simple English points
- Dedicated visual preview / screenshot slide right after EACH module with embedded image
- Exact same academic blue/teal theme (widescreen 16:9, white/light background, fonts, spacing)
"""

import os
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE

def create_presentation():
    prs = Presentation()
    prs.slide_width = Inches(13.333)
    prs.slide_height = Inches(7.5)

    # Color Palette: Academic Blue / Teal Theme
    C_PRIMARY = RGBColor(15, 118, 110)       # #0f766e - Deep Teal
    C_SECONDARY = RGBColor(2, 132, 199)     # #0284c7 - Academic Blue
    C_DARK = RGBColor(15, 23, 42)           # #0f172a - Slate Dark
    C_TEXT = RGBColor(51, 65, 85)           # #334155 - Slate Body
    C_MUTED = RGBColor(100, 116, 139)       # #64748b - Slate Muted
    C_LIGHT_BG = RGBColor(248, 250, 252)    # #f8fafc - Very Light Grey/Blue
    C_CARD_BG = RGBColor(255, 255, 255)     # Pure White
    C_BORDER = RGBColor(226, 232, 240)      # #e2e8f0 - Slate Border
    C_ACCENT_BG = RGBColor(240, 253, 250)   # #f0fdfa - Soft Teal tint
    C_ACCENT_BLUE = RGBColor(224, 242, 254) # #e0f2fe - Soft Blue tint
    C_WHITE = RGBColor(255, 255, 255)

    blank_layout = prs.slide_layouts[6]

    def set_slide_background(slide, color=C_LIGHT_BG):
        bg = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(7.5))
        bg.fill.solid()
        bg.fill.fore_color.rgb = color
        bg.line.fill.background()
        return bg

    def add_header(slide, title_text, category_text="B.Tech Computer Science & Engineering | Major Project"):
        tb_cat = slide.shapes.add_textbox(Inches(0.8), Inches(0.4), Inches(11.7), Inches(0.4))
        p_cat = tb_cat.text_frame.paragraphs[0]
        p_cat.text = category_text.upper()
        p_cat.font.size = Pt(10)
        p_cat.font.bold = True
        p_cat.font.color.rgb = C_PRIMARY
        p_cat.font.name = "Arial"

        tb_title = slide.shapes.add_textbox(Inches(0.8), Inches(0.65), Inches(11.7), Inches(0.7))
        p_title = tb_title.text_frame.paragraphs[0]
        p_title.text = title_text
        p_title.font.size = Pt(22)
        p_title.font.bold = True
        p_title.font.color.rgb = C_DARK
        p_title.font.name = "Arial"

        line = slide.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(0.8), Inches(1.35), Inches(11.733), Inches(0.025))
        line.fill.solid()
        line.fill.fore_color.rgb = C_PRIMARY
        line.line.fill.background()

    def add_card(slide, left, top, width, height, bg_color=C_CARD_BG, border_color=C_BORDER):
        card = slide.shapes.add_shape(MSO_SHAPE.ROUNDED_RECTANGLE, Inches(left), Inches(top), Inches(width), Inches(height))
        card.fill.solid()
        card.fill.fore_color.rgb = bg_color
        card.line.color.rgb = border_color
        card.line.width = Pt(1)
        return card

    # ==========================================
    # SLIDE 1: Title Slide
    # ==========================================
    s1 = prs.slides.add_slide(blank_layout)
    set_slide_background(s1, C_LIGHT_BG)
    strip = s1.shapes.add_shape(MSO_SHAPE.RECTANGLE, 0, 0, Inches(13.333), Inches(0.3))
    strip.fill.solid()
    strip.fill.fore_color.rgb = C_PRIMARY
    strip.line.fill.background()

    add_card(s1, 0.8, 0.8, 11.733, 5.9, bg_color=C_WHITE, border_color=C_BORDER)
    tb = s1.shapes.add_textbox(Inches(1.2), Inches(1.2), Inches(10.9), Inches(5.1))
    tf = tb.text_frame
    tf.word_wrap = True

    p0 = tf.paragraphs[0]
    p0.text = "B.TECH CSE MAJOR PROJECT PRESENTATION"
    p0.font.size = Pt(12)
    p0.font.bold = True
    p0.font.color.rgb = C_PRIMARY
    p0.space_after = Pt(14)

    p1 = tf.add_paragraph()
    p1.text = "WaterStat: An Interactive Statistical Framework for\nWater Quality Assessment and Potability Analysis\nUsing R and Shiny"
    p1.font.size = Pt(28)
    p1.font.bold = True
    p1.font.color.rgb = C_DARK
    p1.space_after = Pt(14)

    p2 = tf.add_paragraph()
    p2.text = "A Pure Software-Based Interactive Framework for Multi-Parameter Data Validation, Exploratory Visualization, Hypothesis Testing, and Statistical Potability Modeling"
    p2.font.size = Pt(13)
    p2.font.color.rgb = C_TEXT
    p2.space_after = Pt(24)

    p3 = tf.add_paragraph()
    p3.text = "Domain: Water Quality Informatics & Applied Statistical Computing   |   Technologies: R, R Shiny, Plotly, FactoMineR   |   Hardware: Pure Software (No IoT / Sensors)"
    p3.font.size = Pt(11)
    p3.font.bold = True
    p3.font.color.rgb = C_SECONDARY

    s1.notes_slide.notes_text_frame.text = (
        "Welcome evaluators. Today I am presenting WaterStat, a pure software-only statistical platform developed using R and Shiny "
        "for water quality assessment and potability modeling."
    )

    # ==========================================
    # SLIDE 2: Introduction
    # ==========================================
    s2 = prs.slides.add_slide(blank_layout)
    set_slide_background(s2)
    add_header(s2, "1. Introduction to Water Quality & Statistical Assessment")

    add_card(s2, 0.8, 1.6, 3.65, 5.2)
    tb = s2.shapes.add_textbox(Inches(1.0), Inches(1.8), Inches(3.25), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "What is Water Quality?"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = C_PRIMARY
    p.space_after = Pt(8)
    for line in [
        "• Defines chemical, physical, and biological properties of water relative to safety standards.",
        "• Why Assessment Matters: Contaminated water carries waterborne pathogens causing severe public health risks.",
        "• Safe drinking water (potability) requires strict adherence to permissible limits established by WHO."
    ]:
        p = tf.add_paragraph()
        p.text = line
        p.font.size = Pt(11)
        p.font.color.rgb = C_TEXT
        p.space_after = Pt(6)

    add_card(s2, 4.84, 1.6, 3.65, 5.2)
    tb = s2.shapes.add_textbox(Inches(5.04), Inches(1.8), Inches(3.25), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "The 9 Physicochemical Parameters"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = C_SECONDARY
    p.space_after = Pt(8)
    params_list = [
        "1. pH (Acid-base balance, 6.5–8.5)",
        "2. Hardness (Ca & Mg ion concentrations)",
        "3. Solids / TDS (Total dissolved minerals)",
        "4. Chloramines (Disinfection agent levels)",
        "5. Sulfate (Natural dissolved mineral salt)",
        "6. Conductivity (Electrical ion conductance)",
        "7. Organic Carbon (TOC from organic matter)",
        "8. Trihalomethanes (Disinfection byproduct)",
        "9. Turbidity (Clarity / suspended particles)"
    ]
    for param in params_list:
        p = tf.add_paragraph()
        p.text = "• " + param
        p.font.size = Pt(9.5)
        p.font.color.rgb = C_TEXT
        p.space_after = Pt(2)
    p = tf.add_paragraph()
    p.text = "\nComplexity: Parameters interact non-linearly with differing scales and outliers."
    p.font.size = Pt(10)
    p.font.bold = True
    p.font.color.rgb = C_DARK

    add_card(s2, 8.88, 1.6, 3.65, 5.2)
    tb = s2.shapes.add_textbox(Inches(9.08), Inches(1.8), Inches(3.25), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "How Statistics & WaterStat Help"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = C_PRIMARY
    p.space_after = Pt(8)
    for line in [
        "• Statistical Rigor: Quantifies variance and tests significant differences using hypothesis tests.",
        "• Interactive Visualization: Translates abstract tables into intuitive distributions, correlation heatmaps, and PCA biplots.",
        "• WaterStat: A unified, upload-driven R Shiny platform providing end-to-end data validation, exploration, hypothesis testing, and potability modeling."
    ]:
        p = tf.add_paragraph()
        p.text = line
        p.font.size = Pt(11)
        p.font.color.rgb = C_TEXT
        p.space_after = Pt(6)

    # ==========================================
    # SLIDE 3: Literature Review
    # ==========================================
    s3 = prs.slides.add_slide(blank_layout)
    set_slide_background(s3)
    add_header(s3, "2. Literature Review (Credible Research Studies)")

    table_shape = s3.shapes.add_table(5, 4, Inches(0.8), Inches(1.7), Inches(11.733), Inches(4.8))
    tbl = table_shape.table
    tbl.columns[0].width = Inches(2.3)
    tbl.columns[1].width = Inches(2.6)
    tbl.columns[2].width = Inches(3.8)
    tbl.columns[3].width = Inches(3.033)

    headers = ["Author / Year", "Method / Approach", "Main Finding", "Limitation / Gap"]
    for i, h in enumerate(headers):
        cell = tbl.cell(0, i)
        cell.fill.solid()
        cell.fill.fore_color.rgb = C_PRIMARY
        p = cell.text_frame.paragraphs[0]
        p.text = h
        p.font.bold = True
        p.font.size = Pt(12)
        p.font.color.rgb = C_WHITE
        p.alignment = PP_ALIGN.CENTER

    lit_data = [
        ("World Health Organization\n(WHO, 2017 / 2022)",
         "Guidelines for Drinking-Water Quality Standards",
         "Established definitive physicochemical permissible thresholds (pH, sulfate, chloramines, turbidity) for potability worldwide.",
         "Provides normative regulatory thresholds, but no automated statistical computing platform for multivariate user data."),

        ("Kazi et al. (2009)\nElsevier: Chemosphere",
         "Multivariate Statistical Analysis (PCA, Cluster Analysis, DA)",
         "Demonstrated that PCA and factor analysis reduce parameter dimensionality and isolate key pollution-indicating factors.",
         "Conducted as static offline statistical scripts without an interactive dashboard or predictive potability classification."),

        ("Uddin et al. (2021)\nEcological Indicators",
         "Review of Water Quality Index (WQI) Formulations",
         "Showed that traditional WQI models suffer from 'eclipsing' and subjective parameter sub-index weighting bias.",
         "Identified the urgent need for objective, data-driven statistical modeling and transparent uncertainty reporting."),

        ("Mohammed et al. (2022) /\nTyagi et al. (2020)",
         "Machine Learning Algorithms (Logistic Reg., RF, SVM, ANN)",
         "Demonstrated ML models can effectively predict water potability from physicochemical parameters with high classification performance.",
         "Focused almost purely on black-box prediction accuracy; lacked integrated hypothesis testing, exploratory visuals, and clinical diagnostics.")
    ]

    for row_idx, data in enumerate(lit_data, start=1):
        for col_idx, text in enumerate(data):
            cell = tbl.cell(row_idx, col_idx)
            cell.fill.solid()
            cell.fill.fore_color.rgb = C_WHITE if row_idx % 2 == 1 else C_ACCENT_BG
            p = cell.text_frame.paragraphs[0]
            p.text = text
            p.font.size = Pt(10.5)
            p.font.color.rgb = C_TEXT
            if col_idx == 0:
                p.font.bold = True

    # ==========================================
    # SLIDE 4: Research Gap & Problem Statement
    # ==========================================
    s4 = prs.slides.add_slide(blank_layout)
    set_slide_background(s4)
    add_header(s4, "3. Research Gap & 4. Problem Statement")

    add_card(s4, 0.8, 1.6, 5.7, 5.2)
    tb = s4.shapes.add_textbox(Inches(1.0), Inches(1.8), Inches(5.3), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Identified Research Gaps"
    p.font.size = Pt(18)
    p.font.bold = True
    p.font.color.rgb = C_PRIMARY
    p.space_after = Pt(12)

    gaps = [
        ("Disjointed Toolchains: ", "Statistical analysis, visualization, and modeling are handled using separate, fragmented software tools."),
        ("Black-Box Prediction Focus: ", "Recent studies prioritize predictive accuracy alone while ignoring hypothesis testing and parameter interpretability."),
        ("High Technical Barrier: ", "Environmental researchers and municipal analysts may lack coding expertise required to run complete statistical pipelines."),
        ("Absence of Integrated Framework: ", "There is a clear gap for a single interactive platform providing validation, statistics, visualization, and potability modeling.")
    ]
    for title, desc in gaps:
        p = tf.add_paragraph()
        p.text = "• " + title
        p.font.bold = True
        p.font.size = Pt(11)
        p.font.color.rgb = C_DARK
        p = tf.add_paragraph()
        p.text = "  " + desc
        p.font.size = Pt(10.5)
        p.font.color.rgb = C_TEXT
        p.space_after = Pt(6)

    add_card(s4, 6.833, 1.6, 5.7, 5.2)
    tb = s4.shapes.add_textbox(Inches(7.033), Inches(1.8), Inches(5.3), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Problem Statement"
    p.font.size = Pt(18)
    p.font.bold = True
    p.font.color.rgb = C_SECONDARY
    p.space_after = Pt(12)

    p = tf.add_paragraph()
    p.text = '"Water-quality datasets contain multiple parameters, missing values, outliers, and complex relationships.\n\nPerforming preprocessing, statistical analysis, visualization, hypothesis testing, and potability assessment separately can make the analysis difficult, error-prone, and time-consuming.\n\nTherefore, an integrated interactive framework is required to simplify and organize the complete water-quality analysis process."'
    p.font.size = Pt(12.5)
    p.font.italic = True
    p.font.color.rgb = C_DARK

    # ==========================================
    # SLIDE 5: Proposed Solution
    # ==========================================
    s5 = prs.slides.add_slide(blank_layout)
    set_slide_background(s5)
    add_header(s5, "5. Proposed Solution: The WaterStat Framework")

    add_card(s5, 0.8, 1.6, 11.733, 1.4, bg_color=C_ACCENT_BG, border_color=C_PRIMARY)
    tb = s5.shapes.add_textbox(Inches(1.0), Inches(1.7), Inches(11.333), Inches(1.2))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "WaterStat — An R and R Shiny-Based Software Platform"
    p.font.size = Pt(18)
    p.font.bold = True
    p.font.color.rgb = C_PRIMARY
    p.space_after = Pt(4)
    p = tf.add_paragraph()
    p.text = "WaterStat is an integrated, upload-driven computational software platform developed entirely in R and R Shiny. It executes a seamless, closed-loop statistical pipeline from raw file ingestion to actionable potability classification."
    p.font.size = Pt(11.5)
    p.font.color.rgb = C_DARK

    add_card(s5, 0.8, 3.2, 11.733, 1.8, bg_color=C_WHITE)
    tb = s5.shapes.add_textbox(Inches(1.0), Inches(3.3), Inches(11.333), Inches(1.5))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Complete End-to-End Execution Pipeline:"
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = C_SECONDARY
    p.space_after = Pt(8)
    flow_str = "Upload Dataset  ➔  Validate  ➔  Preprocess  ➔  Analyze  ➔  Visualize  ➔  Perform Statistical Tests  ➔  Train Model  ➔  Evaluate  ➔  Assess Potability"
    p = tf.add_paragraph()
    p.text = flow_str
    p.font.size = Pt(12)
    p.font.bold = True
    p.font.color.rgb = C_DARK
    p.space_after = Pt(8)
    p = tf.add_paragraph()
    p.text = "• Upload-driven: Operates cleanly with any user-uploaded CSV or Excel file, plus automatic auto-load from data/."
    p.font.size = Pt(10.5)
    p.font.color.rgb = C_TEXT

    add_card(s5, 0.8, 5.2, 11.733, 1.6, bg_color=C_ACCENT_BLUE, border_color=C_SECONDARY)
    tb = s5.shapes.add_textbox(Inches(1.0), Inches(5.3), Inches(11.333), Inches(1.4))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Important Project Scope Clarification (Software-Only):"
    p.font.size = Pt(13)
    p.font.bold = True
    p.font.color.rgb = C_SECONDARY
    p.space_after = Pt(4)
    p = tf.add_paragraph()
    p.text = "• Pure Software Architecture: WaterStat does NOT use Arduino, ESP32, physical pH/turbidity probes, or IoT microcontrollers.\n• Focused on Computational Analytics: Designed specifically to process certified laboratory testing data with mathematical and statistical rigor."
    p.font.size = Pt(11)
    p.font.color.rgb = C_DARK

    # ==========================================
    # SLIDE 6: System Architecture
    # ==========================================
    s6 = prs.slides.add_slide(blank_layout)
    set_slide_background(s6)
    add_header(s6, "6. System Architecture & Component Mapping")

    arch_steps = [
        ("USER INTERACTION", "Analyst uploads CSV / Excel dataset via web browser UI", C_DARK),
        ("MODULE 1: DATA PREPROCESSING", "Format Normalization | Range Validation | Tukey Outlier Auditing | Stratified Split", C_PRIMARY),
        ("MODULE 2: EXPLORATORY ANALYSIS", "Descriptive Statistics | Univariate & Bivariate Plots | Correlation Heatmaps", C_SECONDARY),
        ("MODULE 3: INFERENTIAL MODELING", "Welch t-tests | One-way ANOVA | Chi-Square | MLR | PCA | Logistic Regression", C_PRIMARY),
        ("MODULE 4: INTERACTIVE R SHINY DASHBOARD", "Interactive Plotly Visualizations | Batch Dataset Scoring | Single Sample Evaluator", C_SECONDARY),
        ("DECISION SUPPORT OUTPUTS", "Potability Assessment (0/1) | Classification Metrics | Downloadable CSV Reports", C_DARK)
    ]
    for idx, (title, desc, col) in enumerate(arch_steps):
        top = 1.6 + idx * 0.9
        add_card(s6, 1.2, top, 10.933, 0.75, bg_color=C_WHITE, border_color=col)
        badge = s6.shapes.add_shape(MSO_SHAPE.RECTANGLE, Inches(1.2), Inches(top), Inches(0.15), Inches(0.75))
        badge.fill.solid()
        badge.fill.fore_color.rgb = col
        badge.line.fill.background()

        tb = s6.shapes.add_textbox(Inches(1.5), Inches(top + 0.08), Inches(10.4), Inches(0.6))
        tf = tb.text_frame
        tf.word_wrap = True
        p = tf.paragraphs[0]
        p.text = title + "  ➔  "
        p.font.bold = True
        p.font.size = Pt(11)
        p.font.color.rgb = col
        run = p.add_run()
        run.text = desc
        run.font.bold = False
        run.font.size = Pt(10.5)
        run.font.color.rgb = C_TEXT

    # ==========================================
    # SLIDE 7: Module 1 Description
    # ==========================================
    s7 = prs.slides.add_slide(blank_layout)
    set_slide_background(s7)
    add_header(s7, "Module 1: Water Quality Data Acquisition & Preprocessing")

    add_card(s7, 0.8, 1.6, 11.733, 5.2)
    tb = s7.shapes.add_textbox(Inches(1.1), Inches(1.8), Inches(11.133), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Module 1 Overview & Core Capabilities (in Simple English):"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = C_PRIMARY
    p.space_after = Pt(14)

    m1_points = [
        ("Accepts CSV & Excel Data: ", "Users can easily drag-and-drop or browse their water quality datasets without needing any database setup."),
        ("Automatic Column Normalization: ", "Standardizes column headers automatically so that variations like 'ph', 'PH', or 'pH' are detected correctly."),
        ("Strict Physical Boundary Validation: ", "Automatically audits physical constraints, verifying that pH is between 0.0 and 14.0 and that concentrations are non-negative."),
        ("Duplicate Row Removal: ", "Identifies and filters out duplicate records to prevent skewed distributions and false sample inflation."),
        ("Missing Value Profiling: ", "Calculates exact missing values per parameter and provides visual bar charts showing missing percentages."),
        ("Outlier Detection (Tukey 1.5×IQR Rule): ", "Calculates IQR fences to flag extreme contamination events without blindly deleting them, avoiding survival bias."),
        ("Interactive Data Explorer: ", "Provides a searchable, sortable, and paginated data table where users can view raw data, inspect cleaned data, and download cleaned CSVs.")
    ]
    for title, desc in m1_points:
        p = tf.add_paragraph()
        p.text = "✔ " + title
        p.font.bold = True
        p.font.size = Pt(11.5)
        p.font.color.rgb = C_DARK
        run = p.add_run()
        run.text = desc
        run.font.bold = False
        run.font.color.rgb = C_TEXT
        p.space_after = Pt(6)

    # ==========================================
    # SLIDE 8: Module 1 Visual Preview (Image Slide)
    # ==========================================
    s8 = prs.slides.add_slide(blank_layout)
    set_slide_background(s8)
    add_header(s8, "Module 1: User Interface & Visual Preview")

    # Add Image
    img1_path = "www/previews/mod1_preview.png"
    if os.path.exists(img1_path):
        s8.shapes.add_picture(img1_path, Inches(0.8), Inches(1.6), Inches(8.8), Inches(5.1))
    else:
        add_card(s8, 0.8, 1.6, 8.8, 5.1, bg_color=C_WHITE, border_color=C_PRIMARY)

    # Right Callout Card
    add_card(s8, 9.8, 1.6, 2.733, 5.1, bg_color=C_ACCENT_BG, border_color=C_PRIMARY)
    tb = s8.shapes.add_textbox(Inches(9.95), Inches(1.8), Inches(2.433), Inches(4.7))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Visual Interface Highlights:"
    p.font.size = Pt(13)
    p.font.bold = True
    p.font.color.rgb = C_PRIMARY
    p.space_after = Pt(8)

    calls_m1 = [
        "1. Instant CSV/Excel Ingestion",
        "2. Automated Schema & Range Audit",
        "3. Live Missing Data & Outlier Bar Plots",
        "4. Raw vs. EDA-Ready Data Viewer",
        "5. One-Click Cleaned CSV Download"
    ]
    for c in calls_m1:
        p = tf.add_paragraph()
        p.text = "• " + c
        p.font.size = Pt(10)
        p.font.color.rgb = C_DARK
        p.space_after = Pt(6)
    p = tf.add_paragraph()
    p.text = "\n[Tip: You can right-click the image to replace it with your custom browser screenshot.]"
    p.font.size = Pt(8.5)
    p.font.italic = True
    p.font.color.rgb = C_MUTED

    # ==========================================
    # SLIDE 9: Module 2 Description
    # ==========================================
    s9 = prs.slides.add_slide(blank_layout)
    set_slide_background(s9)
    add_header(s9, "Module 2: Exploratory & Descriptive Statistical Analysis")

    add_card(s9, 0.8, 1.6, 11.733, 5.2)
    tb = s9.shapes.add_textbox(Inches(1.1), Inches(1.8), Inches(11.133), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Module 2 Overview & Core Capabilities (in Simple English):"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = C_SECONDARY
    p.space_after = Pt(14)

    m2_points = [
        ("Comprehensive Descriptive Statistics: ", "Calculates mean, median, standard deviation, variance, minimum, maximum, quartiles (Q1, Q3), and skewness for each parameter."),
        ("All Major Univariate Distribution Charts: ", "Users can switch between Histograms, Kernel Density Estimation, Boxplots, and Violin Plots with internal quartiles."),
        ("Bivariate Relationships & Trendlines: ", "Plots interactive scatter plots between any two selected water parameters with an automatic linear regression fit line and 95% confidence interval."),
        ("Multi-Parameter Comparative Boxplots: ", "Standardizes all 9 parameters onto a Z-score scale, enabling side-by-side comparison across potable and non-potable samples."),
        ("Mean ± Standard Error Bar Charts: ", "Displays faceted bar charts comparing parameter means with error bars across potability classes."),
        ("Correlation Matrix Heatmaps: ", "Computes both Pearson (linear) and Spearman (rank) correlation matrices with color-coded heatmaps and coefficient labels."),
        ("Pairwise Statistical Significance Table: ", "Presents full correlation tables reporting exact coefficients, p-values, sample size n, and verbal interpretation (alpha = 0.05).")
    ]
    for title, desc in m2_points:
        p = tf.add_paragraph()
        p.text = "✔ " + title
        p.font.bold = True
        p.font.size = Pt(11.5)
        p.font.color.rgb = C_DARK
        run = p.add_run()
        run.text = desc
        run.font.bold = False
        run.font.color.rgb = C_TEXT
        p.space_after = Pt(6)

    # ==========================================
    # SLIDE 10: Module 2 Visual Preview (Image Slide)
    # ==========================================
    s10 = prs.slides.add_slide(blank_layout)
    set_slide_background(s10)
    add_header(s10, "Module 2: User Interface & Visual Preview")

    img2_path = "www/previews/mod2_preview.png"
    if os.path.exists(img2_path):
        s10.shapes.add_picture(img2_path, Inches(0.8), Inches(1.6), Inches(8.8), Inches(5.1))
    else:
        add_card(s10, 0.8, 1.6, 8.8, 5.1, bg_color=C_WHITE, border_color=C_SECONDARY)

    add_card(s10, 9.8, 1.6, 2.733, 5.1, bg_color=C_ACCENT_BLUE, border_color=C_SECONDARY)
    tb = s10.shapes.add_textbox(Inches(9.95), Inches(1.8), Inches(2.433), Inches(4.7))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Visual Interface Highlights:"
    p.font.size = Pt(13)
    p.font.bold = True
    p.font.color.rgb = C_SECONDARY
    p.space_after = Pt(8)

    calls_m2 = [
        "1. Dynamic Chart Switcher (Hist / Density / Box / Violin)",
        "2. Real-time Parameter Metric Value Boxes",
        "3. Interactive Plotly Zoom & Hover Tooltips",
        "4. Pearson & Spearman Heatmap Matrix",
        "5. Standardized Z-Score Comparison Profiles"
    ]
    for c in calls_m2:
        p = tf.add_paragraph()
        p.text = "• " + c
        p.font.size = Pt(10)
        p.font.color.rgb = C_DARK
        p.space_after = Pt(6)
    p = tf.add_paragraph()
    p.text = "\n[Tip: You can right-click the image to replace it with your custom browser screenshot.]"
    p.font.size = Pt(8.5)
    p.font.italic = True
    p.font.color.rgb = C_MUTED

    # ==========================================
    # SLIDE 11: Module 3 Description
    # ==========================================
    s11 = prs.slides.add_slide(blank_layout)
    set_slide_background(s11)
    add_header(s11, "Module 3: Inferential Statistical Analysis & Modeling")

    add_card(s11, 0.8, 1.6, 11.733, 5.2)
    tb = s11.shapes.add_textbox(Inches(1.1), Inches(1.8), Inches(11.133), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Module 3 Overview & Core Capabilities (in Simple English):"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = C_PRIMARY
    p.space_after = Pt(14)

    m3_points = [
        ("Welch Two-Sample t-tests: ", "Tests whether potable and non-potable water differ significantly in each parameter without assuming equal variances, reporting Cohen's d effect sizes."),
        ("One-Way ANOVA & Diagnostics: ", "Compares parameter means across groups, complete with Shapiro-Wilk normality tests, Levene's variance tests, and Normal Q-Q residual plots."),
        ("Chi-Square Test of Independence: ", "Groups continuous parameters into quantile bins to test whether they are statistically dependent on potability, reporting Cramer's V."),
        ("Multiple Linear Regression (MLR): ", "Models multi-parameter dependencies with R², adjusted R², overall F-test, VIF collinearity checks, and 3 residual diagnostic plots."),
        ("Principal Component Analysis (PCA): ", "Compresses the 9 dimensions into orthogonal components with Scree plots, 2D Biplots, and variable contribution bar charts."),
        ("Stratified Logistic Regression: ", "Trains a predictive potability model using stratified train/test splits, reporting Odds Ratios per +1 SD with 95% Wald confidence intervals."),
        ("Rigorous Model Evaluation: ", "Displays live Confusion Matrix heatmaps, ROC curves (with AUC), probability calibration curves, and sensitivity sweeps across decision thresholds (0.1–0.9).")
    ]
    for title, desc in m3_points:
        p = tf.add_paragraph()
        p.text = "✔ " + title
        p.font.bold = True
        p.font.size = Pt(11.5)
        p.font.color.rgb = C_DARK
        run = p.add_run()
        run.text = desc
        run.font.bold = False
        run.font.color.rgb = C_TEXT
        p.space_after = Pt(6)

    # ==========================================
    # SLIDE 12: Module 3 Visual Preview (Image Slide)
    # ==========================================
    s12 = prs.slides.add_slide(blank_layout)
    set_slide_background(s12)
    add_header(s12, "Module 3: User Interface & Visual Preview")

    img3_path = "www/previews/mod3_preview.png"
    if os.path.exists(img3_path):
        s12.shapes.add_picture(img3_path, Inches(0.8), Inches(1.6), Inches(8.8), Inches(5.1))
    else:
        add_card(s12, 0.8, 1.6, 8.8, 5.1, bg_color=C_WHITE, border_color=C_PRIMARY)

    add_card(s12, 9.8, 1.6, 2.733, 5.1, bg_color=C_ACCENT_BG, border_color=C_PRIMARY)
    tb = s12.shapes.add_textbox(Inches(9.95), Inches(1.8), Inches(2.433), Inches(4.7))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Visual Interface Highlights:"
    p.font.size = Pt(13)
    p.font.bold = True
    p.font.color.rgb = C_PRIMARY
    p.space_after = Pt(8)

    calls_m3 = [
        "1. Trainable Logistic Regression Controls",
        "2. Visual Confusion Matrix Heatmap (TP, TN, FP, FN)",
        "3. Interactive ROC Curve with AUC Score",
        "4. Odds Ratios Forest Plot with 95% Wald CI",
        "5. ANOVA Q-Q Residual Diagnostics"
    ]
    for c in calls_m3:
        p = tf.add_paragraph()
        p.text = "• " + c
        p.font.size = Pt(10)
        p.font.color.rgb = C_DARK
        p.space_after = Pt(6)
    p = tf.add_paragraph()
    p.text = "\n[Tip: You can right-click the image to replace it with your custom browser screenshot.]"
    p.font.size = Pt(8.5)
    p.font.italic = True
    p.font.color.rgb = C_MUTED

    # ==========================================
    # SLIDE 13: Module 4 Description
    # ==========================================
    s13 = prs.slides.add_slide(blank_layout)
    set_slide_background(s13)
    add_header(s13, "Module 4: Interactive Dashboard & Potability Assessment")

    add_card(s13, 0.8, 1.6, 11.733, 5.2)
    tb = s13.shapes.add_textbox(Inches(1.1), Inches(1.8), Inches(11.133), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Module 4 Overview & Core Capabilities (in Simple English):"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = C_SECONDARY
    p.space_after = Pt(14)

    m4_points = [
        ("Unified Decision-Support Dashboard: ", "Ties all preprocessing, exploration, and modeling together into a fast, reactive R Shiny application."),
        ("Batch Dataset Assessment: ", "Deploys the trained model to predict potability probabilities across all rows in an uploaded dataset, showing predicted probability distributions."),
        ("Custom Single-Sample Assessment: ", "Allows users to input measured laboratory values for all 9 parameters to receive instant potability classifications."),
        ("Realistic Quick Presets: ", "Provides one-click buttons like 'Preset Potable' and 'Preset Non-Potable' for live testing and demonstration."),
        ("Real-Time Probability Meter & Badges: ", "Displays the estimated potability probability percentage and a clear Potable (Safe) / Non-potable (Unsafe) status badge."),
        ("Out-of-Bounds Extrapolation Warnings: ", "Alerts the user if an entered parameter falls outside the range observed during training, cautioning about extrapolation."),
        ("Consolidated Export Center: ", "Enables downloading comprehensive multi-section CSV reports for statistical tests, batch predictions, and model specifications.")
    ]
    for title, desc in m4_points:
        p = tf.add_paragraph()
        p.text = "✔ " + title
        p.font.bold = True
        p.font.size = Pt(11.5)
        p.font.color.rgb = C_DARK
        run = p.add_run()
        run.text = desc
        run.font.bold = False
        run.font.color.rgb = C_TEXT
        p.space_after = Pt(6)

    # ==========================================
    # SLIDE 14: Module 4 Visual Preview (Image Slide)
    # ==========================================
    s14 = prs.slides.add_slide(blank_layout)
    set_slide_background(s14)
    add_header(s14, "Module 4: User Interface & Visual Preview")

    img4_path = "www/previews/mod4_preview.png"
    if os.path.exists(img4_path):
        s14.shapes.add_picture(img4_path, Inches(0.8), Inches(1.6), Inches(8.8), Inches(5.1))
    else:
        add_card(s14, 0.8, 1.6, 8.8, 5.1, bg_color=C_WHITE, border_color=C_SECONDARY)

    add_card(s14, 9.8, 1.6, 2.733, 5.1, bg_color=C_ACCENT_BLUE, border_color=C_SECONDARY)
    tb = s14.shapes.add_textbox(Inches(9.95), Inches(1.8), Inches(2.433), Inches(4.7))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Visual Interface Highlights:"
    p.font.size = Pt(13)
    p.font.bold = True
    p.font.color.rgb = C_SECONDARY
    p.space_after = Pt(8)

    calls_m4 = [
        "1. Interactive Sample Input Panel",
        "2. Live Predicted Probability Percentage Gauge",
        "3. Real-time Model Classification Badge",
        "4. Log-Odds Parameter Contribution Table",
        "5. Batch Dataset Probability Distribution"
    ]
    for c in calls_m4:
        p = tf.add_paragraph()
        p.text = "• " + c
        p.font.size = Pt(10)
        p.font.color.rgb = C_DARK
        p.space_after = Pt(6)
    p = tf.add_paragraph()
    p.text = "\n[Tip: You can right-click the image to replace it with your custom browser screenshot.]"
    p.font.size = Pt(8.5)
    p.font.italic = True
    p.font.color.rgb = C_MUTED

    # ==========================================
    # SLIDE 15: Statistical Techniques Used
    # ==========================================
    s15 = prs.slides.add_slide(blank_layout)
    set_slide_background(s15)
    add_header(s15, "8. Statistical Techniques & Modeling Rigor")

    tech_blocks = [
        ("Descriptive Statistics", C_PRIMARY, [
            "Mean & Median (Central tendency)",
            "Variance & Standard Deviation (Dispersion)",
            "Quartiles & Interquartile Range (IQR)",
            "Skewness (Distribution asymmetry)",
            "Group-wise statistics partitioned by potability"
        ]),
        ("Hypothesis Tests (alpha = 0.05)", C_SECONDARY, [
            "Welch Two-sample t-test (potable vs non-potable)",
            "Cohen's d standardized effect sizes",
            "One-way ANOVA (Response across groups)",
            "Shapiro-Wilk & Levene assumption tests",
            "Chi-Square test of independence & Cramer's V"
        ]),
        ("Multivariate Modeling", C_PRIMARY, [
            "Multiple Linear Regression (MLR with F-test)",
            "Variance Inflation Factor (VIF for multicollinearity)",
            "Principal Component Analysis (FactoMineR)",
            "PCA Scree plot, Biplot & Variable contributions",
            "Binomial Logistic Regression (Log-odds estimation)"
        ]),
        ("Model Evaluation Metrics", C_SECONDARY, [
            "Confusion Matrix (TP, TN, FP, FN counts)",
            "Accuracy, Precision, Recall / Sensitivity",
            "Specificity & Harmonic F1-Score",
            "Receiver Operating Characteristic (ROC)",
            "Area Under Curve (AUC) & Brier Calibration Score"
        ])
    ]

    for idx, (title, color, items) in enumerate(tech_blocks):
        left = 0.8 + idx * 2.98
        add_card(s15, left, 1.6, 2.85, 5.2)
        tb = s15.shapes.add_textbox(Inches(left + 0.15), Inches(1.75), Inches(2.55), Inches(4.9))
        tf = tb.text_frame
        tf.word_wrap = True
        p = tf.paragraphs[0]
        p.text = title
        p.font.size = Pt(13)
        p.font.bold = True
        p.font.color.rgb = color
        p.space_after = Pt(10)
        for item in items:
            p = tf.add_paragraph()
            p.text = "• " + item
            p.font.size = Pt(9.5)
            p.font.color.rgb = C_TEXT
            p.space_after = Pt(4)

    # ==========================================
    # SLIDE 16: Expected Outcomes
    # ==========================================
    s16 = prs.slides.add_slide(blank_layout)
    set_slide_background(s16)
    add_header(s16, "10. Expected Outcomes (Target Deliverables)")

    outcomes = [
        ("Clean & Validated Water Data", "Automated detection of negative concentrations, pH bounds violation (>14), duplicates, and missing value profiling."),
        ("Descriptive Statistical Insights", "Complete baseline parameters profile (mean, SD, IQR, skewness) with potability group comparisons."),
        ("Parameter Relationship Discovery", "Pearson/Spearman correlation matrices and multiple linear regression describing multi-parameter associations."),
        ("Hypothesis Significance Testing", "Mathematically sound Welch t-tests, ANOVA, and Chi-square tests reporting test statistics, p-values, and effect sizes."),
        ("Interactive Exploratory Visuals", "Plotly-enabled histograms, density curves, boxplots, violin plots, scatter charts, and PCA biplots."),
        ("Logistic Regression Potability Assessment", "Standardized log-odds estimation with Odds Ratios per +1 SD, Wald confidence intervals, and threshold tuning."),
        ("Interactive Custom Sample Evaluator", "Laboratory decision-support tool for assessing new samples with real-time probability gauge and extrapolation warnings."),
        ("Exportable Analysis Deliverables", "Multi-section downloadable CSV reports summarizing validation audits, statistical tests, model metrics, and predictions.")
    ]

    for idx, (title, desc) in enumerate(outcomes):
        col = idx % 2
        row = idx // 2
        left = 0.8 + col * 5.95
        top = 1.6 + row * 1.3
        add_card(s16, left, top, 5.75, 1.18)
        tb = s16.shapes.add_textbox(Inches(left + 0.2), Inches(top + 0.08), Inches(5.35), Inches(1.0))
        tf = tb.text_frame
        tf.word_wrap = True
        p = tf.paragraphs[0]
        p.text = "✔ " + title
        p.font.size = Pt(12)
        p.font.bold = True
        p.font.color.rgb = C_PRIMARY if col == 0 else C_SECONDARY
        p = tf.add_paragraph()
        p.text = desc
        p.font.size = Pt(9.5)
        p.font.color.rgb = C_TEXT

    tb = s16.shapes.add_textbox(Inches(0.8), Inches(6.85), Inches(11.733), Inches(0.4))
    p = tb.text_frame.paragraphs[0]
    p.text = "Note: No numerical results are fabricated in advance; all statistical figures and model metrics are computed live from user datasets."
    p.font.size = Pt(9.5)
    p.font.italic = True
    p.font.color.rgb = C_MUTED
    p.alignment = PP_ALIGN.CENTER

    # ==========================================
    # SLIDE 17: Conclusion
    # ==========================================
    s17 = prs.slides.add_slide(blank_layout)
    set_slide_background(s17)
    add_header(s17, "11. Conclusion & Key Contributions")

    add_card(s17, 0.8, 1.6, 11.733, 2.0, bg_color=C_ACCENT_BG, border_color=C_PRIMARY)
    tb = s17.shapes.add_textbox(Inches(1.1), Inches(1.8), Inches(11.133), Inches(1.6))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Summary Conclusion:"
    p.font.size = Pt(14)
    p.font.bold = True
    p.font.color.rgb = C_PRIMARY
    p.space_after = Pt(6)
    p = tf.add_paragraph()
    p.text = '"WaterStat integrates data preprocessing, statistical analysis, visualization, hypothesis testing, and modeling into a single interactive R Shiny platform.\n\nThe proposed system aims to make water-quality assessment more systematic, accessible, and interpretable while supporting data-driven potability analysis."'
    p.font.size = Pt(13)
    p.font.italic = True
    p.font.color.rgb = C_DARK

    contribs = [
        ("Integrated Unified Workflow", "Eliminates tool fragmentation by merging data validation, exploratory charts, inferential tests, and predictive modeling into one R Shiny dashboard."),
        ("Methodological Soundness", "Maintains separate preprocessing pipelines for EDA, hypothesis testing, and machine learning, completely avoiding data leakage."),
        ("Interpretability over Black-Box", "Provides odds ratios per +1 SD, Wald confidence intervals, VIF collinearity checks, and live threshold tuning for informed decision-making."),
        ("Accessibility & Usability", "Empowers environmental researchers and water quality analysts to perform sophisticated analyses without writing complex code.")
    ]

    for idx, (ctitle, cdesc) in enumerate(contribs):
        col = idx % 2
        row = idx // 2
        left = 0.8 + col * 5.95
        top = 3.8 + row * 1.6
        add_card(s17, left, top, 5.75, 1.45)
        tb = s17.shapes.add_textbox(Inches(left + 0.2), Inches(top + 0.1), Inches(5.35), Inches(1.25))
        tf = tb.text_frame
        tf.word_wrap = True
        p = tf.paragraphs[0]
        p.text = "★ " + ctitle
        p.font.size = Pt(12)
        p.font.bold = True
        p.font.color.rgb = C_SECONDARY
        p.space_after = Pt(2)
        p = tf.add_paragraph()
        p.text = cdesc
        p.font.size = Pt(9.5)
        p.font.color.rgb = C_TEXT

    # ==========================================
    # SLIDE 18: Future Scope & Q&A
    # ==========================================
    s18 = prs.slides.add_slide(blank_layout)
    set_slide_background(s18)
    add_header(s18, "12. Future Scope & Acknowledgements")

    add_card(s18, 0.8, 1.6, 7.5, 5.2)
    tb = s18.shapes.add_textbox(Inches(1.0), Inches(1.8), Inches(7.1), Inches(4.8))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Directions for Future Enhancement"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = C_PRIMARY
    p.space_after = Pt(10)

    future_points = [
        ("Multi-Source Datasets & Benchmarks: ", "Expanding support for diverse international water catchment basins and regional municipal datasets."),
        ("Advanced Machine Learning Models: ", "Incorporating interpretable tree-based ensembles (Random Forest, XGBoost) with SHAP value explanations alongside logistic regression."),
        ("Non-Linear & Advanced Statistics: ", "Adding Generalized Additive Models (GAMs) and non-linear spline estimation for complex parameter interactions."),
        ("Automated PDF / Word Report Generation: ", "Integrating R Markdown / Quarto engines to auto-generate formatted technical assessment reports with one click."),
        ("Geospatial & Spatial GIS Analysis: ", "Incorporating Leaflet GIS mapping to visualize geographic distribution of water quality and potability hotspots."),
        ("Future Real-Time Data Ingestion: ", "Architectural readiness to interface with telemetry APIs for streaming municipal laboratory testing feeds.")
    ]

    for f_title, f_desc in future_points:
        p = tf.add_paragraph()
        p.text = "➔ " + f_title
        p.font.bold = True
        p.font.size = Pt(10.5)
        p.font.color.rgb = C_DARK
        p = tf.add_paragraph()
        p.text = "   " + f_desc
        p.font.size = Pt(9.5)
        p.font.color.rgb = C_TEXT
        p.space_after = Pt(3)

    add_card(s18, 8.6, 1.6, 3.933, 5.2, bg_color=C_ACCENT_BG, border_color=C_PRIMARY)
    tb = s18.shapes.add_textbox(Inches(8.8), Inches(2.2), Inches(3.533), Inches(4.0))
    tf = tb.text_frame
    tf.word_wrap = True
    p = tf.paragraphs[0]
    p.text = "Thank You!"
    p.font.size = Pt(28)
    p.font.bold = True
    p.font.color.rgb = C_PRIMARY
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(12)

    p = tf.add_paragraph()
    p.text = "Questions & Discussion"
    p.font.size = Pt(16)
    p.font.bold = True
    p.font.color.rgb = C_SECONDARY
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(16)

    p = tf.add_paragraph()
    p.text = "Project Title:\nWaterStat: An Interactive Statistical Framework for Water Quality Assessment and Potability Analysis Using R and Shiny"
    p.font.size = Pt(11)
    p.font.color.rgb = C_DARK
    p.alignment = PP_ALIGN.CENTER
    p.space_after = Pt(14)

    p = tf.add_paragraph()
    p.text = "Platform: Pure Software\nLanguage: R v4.6+ & Shiny\nReady for Viva Defense"
    p.font.size = Pt(10)
    p.font.color.rgb = C_MUTED
    p.alignment = PP_ALIGN.CENTER

    output_path = "WaterStat_BTech_CSE_Presentation.pptx"
    prs.save(output_path)
    print(f"Presentation saved successfully to {output_path} with {len(prs.slides)} slides!")

if __name__ == "__main__":
    create_presentation()

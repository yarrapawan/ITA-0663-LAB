"""
Generate 4 professional visual preview images for Module 1, 2, 3, 4
to embed in the PowerPoint slides and presentation web page.
"""
import os
from PIL import Image, ImageDraw, ImageFont

def make_preview_images():
    os.makedirs("www/previews", exist_ok=True)
    width, height = 1280, 720
    
    # Colors
    c_bg = (248, 250, 252)
    c_white = (255, 255, 255)
    c_primary = (15, 118, 110)
    c_secondary = (2, 132, 199)
    c_dark = (15, 23, 42)
    c_muted = (100, 116, 139)
    c_border = (226, 232, 240)
    c_potable = (13, 148, 136)
    c_nonpotable = (220, 38, 38)
    c_card_border = (203, 213, 225)
    c_header_bar = (15, 118, 110)
    
    # -------------------------------------------------------------
    # Image 1: Module 1 Preprocessing
    # -------------------------------------------------------------
    img1 = Image.new("RGB", (width, height), c_bg)
    d1 = ImageDraw.Draw(img1)
    
    # Top navbar
    d1.rectangle([(0, 0), (width, 60)], fill=c_header_bar)
    d1.text((30, 18), "WaterStat  |  Module 1: Water Quality Data Acquisition & Preprocessing", fill=c_white)
    
    # Left sidebar
    d1.rectangle([(30, 80), (340, 680)], fill=c_white, outline=c_border, width=2)
    d1.rectangle([(45, 95), (325, 145)], fill=(240, 253, 250), outline=c_primary, width=1)
    d1.text((60, 112), "[Browse...] water_quality.csv", fill=c_primary)
    d1.text((45, 165), "Data Acquisition & Schema Audit", fill=c_dark)
    d1.text((45, 190), "• 9 Parameters: pH, Hardness, Solids...", fill=c_muted)
    d1.text((45, 215), "• Target: Potability (0/1)", fill=c_muted)
    d1.text((45, 240), "• Status: Validated (3,276 Rows)", fill=c_potable)
    
    # Download buttons
    d1.rectangle([(45, 280), (325, 315)], fill=(241, 245, 249), outline=c_border)
    d1.text((65, 292), "Download Cleaned CSV", fill=c_dark)
    d1.rectangle([(45, 325), (325, 360)], fill=(241, 245, 249), outline=c_border)
    d1.text((65, 337), "Download Quality Report", fill=c_dark)
    
    # Right Main Area
    # Tabs bar
    d1.rectangle([(360, 80), (1240, 120)], fill=(241, 245, 249), outline=c_border)
    d1.rectangle([(370, 85), (550, 120)], fill=c_white, outline=c_primary, width=2)
    d1.text((385, 96), "Validation Report", fill=c_primary)
    d1.text((580, 96), "Data Quality & Missing Plots", fill=c_muted)
    d1.text((820, 96), "Interactive Data Explorer", fill=c_muted)
    
    # Cards on right
    d1.rectangle([(360, 135), (780, 380)], fill=c_white, outline=c_border, width=2)
    d1.rectangle([(360, 135), (780, 175)], fill=(248, 250, 252))
    d1.text((380, 147), "Dataset Validation Summary", fill=c_dark)
    d1.text((380, 195), "Dataset status: VALID", fill=c_potable)
    d1.text((380, 230), "Total Rows: 3,276 observations", fill=c_dark)
    d1.text((380, 265), "Missing values in predictors: 1,434 (Audited)", fill=c_muted)
    d1.text((380, 300), "Duplicate rows removed: 0", fill=c_dark)
    d1.text((380, 335), "Physical bounds: pH in [0,14], non-negative", fill=c_dark)
    
    d1.rectangle([(800, 135), (1240, 380)], fill=c_white, outline=c_border, width=2)
    d1.rectangle([(800, 135), (1240, 175)], fill=(248, 250, 252))
    d1.text((820, 147), "Potability Class Distribution", fill=c_dark)
    d1.text((820, 205), "Class 0 (Non-potable): 1,998 rows  (60.99%)", fill=c_nonpotable)
    d1.text((820, 245), "Class 1 (Potable):     1,278 rows  (39.01%)", fill=c_potable)
    d1.rectangle([(820, 290), (1200, 315)], fill=(226, 232, 240))
    d1.rectangle([(820, 290), (970, 315)], fill=c_nonpotable)
    d1.rectangle([(970, 290), (1200, 315)], fill=c_potable)
    
    # Bottom Card: Data Table Explorer Preview
    d1.rectangle([(360, 400), (1240, 680)], fill=c_white, outline=c_border, width=2)
    d1.rectangle([(360, 400), (1240, 440)], fill=(248, 250, 252))
    d1.text((380, 412), "Interactive Data Explorer (First Records Preview)", fill=c_dark)
    cols = ["Row", "pH", "Hardness", "Solids", "Chloramines", "Sulfate", "Conductivity", "Potability"]
    for i, col in enumerate(cols):
        d1.text((380 + i * 105, 455), col, fill=c_dark)
    d1.line([(370, 480), (1230, 480)], fill=c_border, width=1)
    
    mock_rows = [
        ("1", "NA", "204.89", "20791", "7.30", "368.52", "564.31", "0 (Non-potable)"),
        ("2", "3.72", "129.42", "18630", "6.64", "NA", "592.89", "0 (Non-potable)"),
        ("3", "8.10", "224.24", "19910", "9.28", "NA", "418.61", "0 (Non-potable)"),
        ("4", "8.32", "214.37", "22018", "8.06", "356.89", "363.27", "0 (Non-potable)"),
        ("5", "9.09", "181.10", "17979", "6.55", "310.14", "398.41", "0 (Non-potable)")
    ]
    for r_idx, r in enumerate(mock_rows):
        y = 500 + r_idx * 34
        for c_idx, val in enumerate(r):
            col_color = c_nonpotable if "Non-potable" in val else c_dark
            d1.text((380 + c_idx * 105, y), val, fill=col_color)
            
    img1.save("www/previews/mod1_preview.png")

    # -------------------------------------------------------------
    # Image 2: Module 2 Descriptive Statistics & Charts
    # -------------------------------------------------------------
    img2 = Image.new("RGB", (width, height), c_bg)
    d2 = ImageDraw.Draw(img2)
    
    d2.rectangle([(0, 0), (width, 60)], fill=(2, 132, 199))
    d2.text((30, 18), "WaterStat  |  Module 2: Exploratory & Descriptive Statistical Analysis", fill=c_white)
    
    # Left sidebar
    d2.rectangle([(30, 80), (320, 680)], fill=c_white, outline=c_border, width=2)
    d2.text((45, 100), "Visualization Settings", fill=c_dark)
    d2.text((45, 135), "Parameter: pH", fill=c_secondary)
    d2.text((45, 165), "Potability Groups: All", fill=c_muted)
    d2.text((45, 195), "Chart Type: Histogram / Density / Violin", fill=c_muted)
    d2.text((45, 235), "Bivariate Pair: pH vs Hardness", fill=c_dark)
    d2.text((45, 265), "Correlation Method: Pearson", fill=c_muted)
    
    # Top Value Boxes
    v_boxes = [
        ("Mean", "7.08", (15, 118, 110)),
        ("Median", "7.04", (2, 132, 199)),
        ("Std Dev", "1.59", (100, 116, 139)),
        ("Min", "0.00", (100, 116, 139)),
        ("Max", "14.00", (100, 116, 139)),
        ("Skewness", "-0.026", (217, 119, 6))
    ]
    for i, (title, val, col) in enumerate(v_boxes):
        x = 340 + i * 150
        d2.rectangle([(x, 80), (x + 140, 145)], fill=c_white, outline=c_border, width=2)
        d2.text((x + 15, 90), title, fill=c_muted)
        d2.text((x + 15, 112), val, fill=col)
        
    # Chart 1: Distribution Plot Mockup
    d2.rectangle([(340, 160), (780, 420)], fill=c_white, outline=c_border, width=2)
    d2.text((360, 175), "Histogram & Kernel Density (pH by Potability)", fill=c_dark)
    # Draw bars
    for b in range(12):
        bx = 380 + b * 30
        h_bar = int(30 + (6 - abs(6 - b)) * 18)
        d2.rectangle([(bx, 380 - h_bar), (bx + 24, 380)], fill=(13, 148, 136, 180), outline=(15, 118, 110))
    d2.line([(380, 340), (440, 270), (500, 230), (560, 240), (620, 310), (700, 375)], fill=(2, 132, 199), width=3)
    
    # Chart 2: Violin Plot Mockup
    d2.rectangle([(800, 160), (1240, 420)], fill=c_white, outline=c_border, width=2)
    d2.text((820, 175), "Violin Plot (with Internal Quartiles)", fill=c_dark)
    # Non-potable violin
    d2.polygon([(900, 220), (940, 270), (950, 300), (940, 330), (900, 380), (860, 330), (850, 300), (860, 270)], fill=(220, 38, 38, 120), outline=c_nonpotable)
    # Potable violin
    d2.polygon([(1100, 220), (1140, 270), (1150, 300), (1140, 330), (1100, 380), (1060, 330), (1050, 300), (1060, 270)], fill=(13, 148, 136, 120), outline=c_potable)
    d2.text((870, 395), "Non-potable (0)", fill=c_nonpotable)
    d2.text((1070, 395), "Potable (1)", fill=c_potable)

    # Bottom Area: Correlation Heatmap Mockup
    d2.rectangle([(340, 440), (1240, 680)], fill=c_white, outline=c_border, width=2)
    d2.text((360, 455), "Inter-Parameter Correlation Matrix Heatmap (Pearson r)", fill=c_dark)
    # Draw a 9x4 grid
    p_names = ["pH", "Hardness", "Solids", "Chloramines", "Sulfate", "Conductivity", "Organic", "Trihalo", "Turbidity"]
    for c_i in range(9):
        d2.text((450 + c_i * 85, 485), p_names[c_i], fill=c_dark)
    for r_i in range(4):
        d2.text((360, 520 + r_i * 35), p_names[r_i], fill=c_dark)
        for c_i in range(9):
            val_r = (c_i * 3 - r_i * 2) % 10 / 25.0
            col_tile = (240, 253, 250) if val_r >= 0 else (254, 242, 242)
            d2.rectangle([(445 + c_i * 85, 515 + r_i * 35), (445 + c_i * 85 + 75, 515 + r_i * 35 + 30)], fill=col_tile, outline=c_border)
            d2.text((465 + c_i * 85, 522 + r_i * 35), f"{val_r:+.2f}", fill=c_dark)
            
    img2.save("www/previews/mod2_preview.png")

    # -------------------------------------------------------------
    # Image 3: Module 3 Inferential & Modeling
    # -------------------------------------------------------------
    img3 = Image.new("RGB", (width, height), c_bg)
    d3 = ImageDraw.Draw(img3)
    
    d3.rectangle([(0, 0), (width, 60)], fill=(15, 118, 110))
    d3.text((30, 18), "WaterStat  |  Module 3: Inferential Statistical Analysis & Modeling", fill=c_white)
    
    # Left Sidebar
    d3.rectangle([(30, 80), (320, 680)], fill=c_white, outline=c_border, width=2)
    d3.text((45, 100), "Model Training Controls", fill=c_dark)
    d3.text((45, 130), "Seed: 42 (Reproducible)", fill=c_muted)
    d3.text((45, 160), "Train Fraction: 80% (Stratified)", fill=c_muted)
    d3.text((45, 190), "Classification Threshold: 0.50", fill=c_muted)
    d3.rectangle([(45, 220), (300, 260)], fill=(13, 148, 136), outline=(15, 118, 110))
    d3.text((65, 232), "▶ Train Logistic Regression", fill=c_white)
    d3.rectangle([(45, 280), (300, 320)], fill=(240, 253, 250), outline=c_potable)
    d3.text((65, 292), "✔ Model Active: Test AUC = 0.548", fill=c_potable)
    
    # Top Row: ROC Curve & Confusion Matrix
    d3.rectangle([(340, 80), (780, 370)], fill=c_white, outline=c_border, width=2)
    d3.text((360, 95), "Confusion Matrix Visual Heatmap (Threshold 0.50)", fill=c_dark)
    # 2x2 grid
    d3.rectangle([(400, 140), (560, 230)], fill=(204, 251, 241), outline=c_potable, width=2)
    d3.text((440, 165), "TN = 360", fill=c_dark)
    d3.text((435, 190), "(True Negative)", fill=c_muted)
    
    d3.rectangle([(580, 140), (740, 230)], fill=(254, 226, 226), outline=c_nonpotable, width=2)
    d3.text((620, 165), "FP = 40", fill=c_dark)
    d3.text((615, 190), "(False Positive)", fill=c_muted)
    
    d3.rectangle([(400, 250), (560, 340)], fill=(254, 226, 226), outline=c_nonpotable, width=2)
    d3.text((440, 275), "FN = 210", fill=c_dark)
    d3.text((435, 300), "(False Negative)", fill=c_muted)
    
    d3.rectangle([(580, 250), (740, 340)], fill=(204, 251, 241), outline=c_potable, width=2)
    d3.text((620, 275), "TP = 46", fill=c_dark)
    d3.text((615, 300), "(True Positive)", fill=c_muted)
    
    # ROC Curve Card
    d3.rectangle([(800, 80), (1240, 370)], fill=c_white, outline=c_border, width=2)
    d3.text((820, 95), "ROC Curve (Held-out Test Set) [AUC = 0.548]", fill=c_dark)
    d3.line([(850, 330), (1190, 330)], fill=c_muted, width=2)
    d3.line([(850, 140), (850, 330)], fill=c_muted, width=2)
    d3.line([(850, 330), (1190, 140)], fill=(148, 163, 184), width=2) # Diagonal
    d3.line([(850, 330), (930, 260), (1020, 190), (1100, 150), (1190, 140)], fill=c_primary, width=3)
    d3.text((950, 280), "ROC Curve (AUC = 0.548)", fill=c_primary)
    
    # Bottom Row: Hypothesis Testing & Odds Ratios
    d3.rectangle([(340, 390), (1240, 680)], fill=c_white, outline=c_border, width=2)
    d3.text((360, 405), "Welch Two-Sample t-tests & Parameter Odds Ratios (alpha = 0.05)", fill=c_dark)
    
    t_headers = ["Parameter", "Mean(Potable)", "Mean(Non-potable)", "t-statistic", "p-value", "Cohen's d", "Odds Ratio (per +1 SD)", "Conclusion"]
    for i, h in enumerate(t_headers):
        d3.text((360 + i * 110, 440), h, fill=c_dark)
    d3.line([(350, 465), (1230, 465)], fill=c_border, width=1)
    
    t_rows = [
        ("pH", "7.07", "7.08", "-0.17", "0.865", "negligible", "OR = 1.01 [0.91-1.12]", "Fail to Reject H0"),
        ("Hardness", "195.8", "196.7", "-0.81", "0.418", "negligible", "OR = 0.98 [0.89-1.09]", "Fail to Reject H0"),
        ("Solids", "22384", "21770", "+1.78", "0.076", "small", "OR = 1.08 [0.97-1.19]", "Fail to Reject H0"),
        ("Chloramines", "7.17", "7.09", "+1.33", "0.183", "small", "OR = 1.07 [0.96-1.18]", "Fail to Reject H0"),
        ("Sulfate", "332.6", "334.6", "-1.04", "0.298", "small", "OR = 0.95 [0.85-1.07]", "Fail to Reject H0")
    ]
    for r_idx, r in enumerate(t_rows):
        y = 485 + r_idx * 35
        for c_idx, val in enumerate(r):
            d3.text((360 + c_idx * 110, y), val, fill=c_dark)
            
    img3.save("www/previews/mod3_preview.png")

    # -------------------------------------------------------------
    # Image 4: Module 4 Dashboard & Assessment
    # -------------------------------------------------------------
    img4 = Image.new("RGB", (width, height), c_bg)
    d4 = ImageDraw.Draw(img4)
    
    d4.rectangle([(0, 0), (width, 60)], fill=(13, 148, 136))
    d4.text((30, 18), "WaterStat  |  Module 4: Interactive Dashboard & Potability Assessment", fill=c_white)
    
    # Left Sidebar: Custom Sample Inputs
    d4.rectangle([(30, 80), (340, 680)], fill=c_white, outline=c_border, width=2)
    d4.text((45, 100), "Custom Water Sample Assessment", fill=c_dark)
    d4.rectangle([(45, 125), (170, 155)], fill=(240, 253, 250), outline=c_potable)
    d4.text((55, 134), "Preset Potable", fill=c_potable)
    d4.rectangle([(185, 125), (315, 155)], fill=(254, 242, 242), outline=c_nonpotable)
    d4.text((195, 134), "Preset Non-Potable", fill=c_nonpotable)
    
    inps = [("pH", "7.20"), ("Hardness", "200 mg/L"), ("Solids (TDS)", "18,000 ppm"), ("Chloramines", "7.00 ppm"),
            ("Sulfate", "330 mg/L"), ("Conductivity", "400 μS/cm"), ("Organic Carbon", "13.00 ppm"),
            ("Trihalomethanes", "60.00 μg/L"), ("Turbidity", "3.50 NTU")]
    for idx, (label, val) in enumerate(inps):
        y = 175 + idx * 46
        d4.text((45, y), label, fill=c_muted)
        d4.rectangle([(45, y + 16), (320, y + 40)], fill=(248, 250, 252), outline=c_border)
        d4.text((55, y + 22), val, fill=c_dark)
        
    d4.rectangle([(45, 615), (320, 655)], fill=c_primary)
    d4.text((85, 627), "Assess Water Sample", fill=c_white)
    
    # Right Area
    # Value Boxes Result
    d4.rectangle([(360, 80), (640, 180)], fill=(240, 253, 250), outline=c_potable, width=2)
    d4.text((380, 95), "Predicted Potability Probability", fill=c_muted)
    d4.text((380, 125), "78.4%", fill=c_potable)
    
    d4.rectangle([(660, 80), (940, 180)], fill=(240, 253, 250), outline=c_potable, width=2)
    d4.text((680, 95), "Classification (Threshold 0.50)", fill=c_muted)
    d4.text((680, 125), "POTABLE (SAFE)", fill=c_potable)
    
    d4.rectangle([(960, 80), (1240, 180)], fill=c_white, outline=c_border, width=2)
    d4.text((980, 95), "Training Pipeline", fill=c_muted)
    d4.text((980, 125), "Z-Score Standardized", fill=c_secondary)
    
    # Log-Odds Contribution Table
    d4.rectangle([(360, 200), (780, 680)], fill=c_white, outline=c_border, width=2)
    d4.text((380, 215), "Parameter Contribution to Log-Odds", fill=c_dark)
    contribs = [
        ("Solids (Log-transformed)", "+0.142", "Increases Potability Odds", c_potable),
        ("Chloramines", "+0.089", "Increases Potability Odds", c_potable),
        ("pH", "+0.012", "Slightly Higher Odds", c_potable),
        ("Organic Carbon", "-0.045", "Decreases Odds", c_nonpotable),
        ("Sulfate", "-0.078", "Decreases Odds", c_nonpotable),
        ("Hardness", "-0.034", "Decreases Odds", c_nonpotable)
    ]
    for idx, (p, c, desc, col) in enumerate(contribs):
        y = 260 + idx * 60
        d4.text((380, y), p, fill=c_dark)
        d4.text((380, y + 20), f"Log-Odds Effect: {c} ({desc})", fill=col)
        d4.line([(380, y + 48), (760, y + 48)], fill=c_border)
        
    # Batch Assessment Histogram Mockup
    d4.rectangle([(800, 200), (1240, 680)], fill=c_white, outline=c_border, width=2)
    d4.text((820, 215), "Batch Dataset Predictions (3,276 Rows)", fill=c_dark)
    d4.text((820, 245), "Predicted Potability Probability Distribution", fill=c_muted)
    for b in range(15):
        bx = 840 + b * 25
        h_bar = int(20 + (b * 2) if b < 8 else (15 - b) * 12 + 40)
        d4.rectangle([(bx, 450 - h_bar), (bx + 20, 450)], fill=(2, 132, 199, 180), outline=c_secondary)
    d4.line([(830, 450), (1220, 450)], fill=c_dark, width=2)
    d4.text((840, 465), "0.0 (Non-potable)", fill=c_nonpotable)
    d4.text((1130, 465), "1.0 (Potable)", fill=c_potable)
    
    # Download section in card
    d4.rectangle([(820, 520), (1220, 650)], fill=(248, 250, 252), outline=c_border)
    d4.text((840, 535), "Consolidated Export Center", fill=c_dark)
    d4.text((840, 565), "✔ Statistical Results CSV", fill=c_primary)
    d4.text((840, 590), "✔ Batch Predictions & Potability Scores CSV", fill=c_primary)
    d4.text((840, 615), "✔ Model Specification & Evaluation CSV", fill=c_primary)
    
    img4.save("www/previews/mod4_preview.png")
    print("All 4 preview images generated in www/previews/")

if __name__ == "__main__":
    make_preview_images()

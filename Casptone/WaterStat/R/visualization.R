# Module 4 helpers - ggplot2 builders (wrapped with plotly in the modules)
# Theme colors: Professional academic blue/teal palette
WS_COLORS <- c("Non-potable" = "#dc2626", "Potable" = "#0d9488", "All" = "#475569")
WS_TEAL <- "#0f766e"
WS_BLUE <- "#0284c7"

theme_ws <- function() {
  theme_minimal(base_size = 12) +
    theme(
      text = element_text(family = "sans"),
      plot.title = element_text(face = "bold", size = 13, colour = "#0f172a", margin = margin(b = 8)),
      plot.subtitle = element_text(size = 10, colour = "#64748b", margin = margin(b = 10)),
      axis.title = element_text(face = "bold", size = 11, colour = "#334155"),
      axis.text = element_text(colour = "#475569"),
      panel.grid.major = element_line(colour = "#f1f5f9", linewidth = 0.6),
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      legend.title = element_text(face = "bold", size = 10),
      legend.text = element_text(size = 10)
    )
}

# 1. Histogram with density curve overlay
plot_hist <- function(df, var, bins = 30) {
  ggplot(df, aes(.data[[var]], fill = Group)) +
    geom_histogram(bins = bins, alpha = 0.65, position = "identity", colour = "white", linewidth = 0.2) +
    scale_fill_manual(values = WS_COLORS, na.value = "#94a3b8") +
    labs(title = paste("Distribution of", var), x = var, y = "Frequency Count", fill = "Potability Group") +
    theme_ws()
}

# 2. Kernel Density Plot
plot_density <- function(df, var) {
  ggplot(df, aes(.data[[var]], fill = Group, colour = Group)) +
    geom_density(alpha = 0.35, linewidth = 0.8) +
    scale_fill_manual(values = WS_COLORS, na.value = "#94a3b8") +
    scale_colour_manual(values = WS_COLORS, na.value = "#94a3b8") +
    labs(title = paste("Kernel Density Estimation for", var), x = var, y = "Density", fill = "Potability Group", colour = "Potability Group") +
    theme_ws()
}

# 3. Box Plot with Jitter Points
plot_box <- function(df, var) {
  ggplot(df, aes(Group, .data[[var]], fill = Group)) +
    geom_boxplot(alpha = 0.7, outlier.shape = 21, outlier.size = 2, outlier.fill = "white", width = 0.5) +
    scale_fill_manual(values = WS_COLORS, na.value = "#94a3b8") +
    labs(title = paste("Boxplot of", var, "by Potability"), x = "Potability Class", y = var) +
    theme_ws() +
    theme(legend.position = "none")
}

# 4. Violin Plot with Quartiles
plot_violin <- function(df, var) {
  ggplot(df, aes(Group, .data[[var]], fill = Group)) +
    geom_violin(alpha = 0.5, trim = FALSE, scale = "width", colour = "#334155") +
    geom_boxplot(width = 0.15, fill = "white", outlier.shape = NA, alpha = 0.85) +
    scale_fill_manual(values = WS_COLORS, na.value = "#94a3b8") +
    labs(title = paste("Violin Plot of", var, "(with Quartiles)"), x = "Potability Class", y = var) +
    theme_ws() +
    theme(legend.position = "none")
}

# 5. Multi-parameter Standardized Z-Score Comparison Boxplot
plot_compare_all <- function(df) {
  z <- as.data.frame(scale(df[WQ_PARAMS]))
  z$Group <- df$Group
  long <- tidyr::pivot_longer(z, dplyr::all_of(WQ_PARAMS), names_to = "Parameter", values_to = "z")
  long <- long[!is.na(long$z), ]
  ggplot(long, aes(Parameter, z, fill = Group)) +
    geom_boxplot(alpha = 0.75, outlier.alpha = 0.3, width = 0.6) +
    geom_hline(yintercept = 0, linetype = "dashed", colour = "#94a3b8") +
    scale_fill_manual(values = WS_COLORS, na.value = "#94a3b8") +
    labs(title = "Standardized Parameter Profiles (Z-Scores across All 9 Parameters)", y = "Standardized Value (Z-Score)", fill = "Potability Group") +
    theme_ws() +
    theme(axis.text.x = element_text(angle = 35, hjust = 1, face = "bold"))
}

# 6. Mean Comparison with Error Bars (Bar Chart)
plot_means_barchart <- function(df) {
  long <- tidyr::pivot_longer(df, dplyr::all_of(WQ_PARAMS), names_to = "Parameter", values_to = "Value")
  long <- long[!is.na(long$Value) & !is.na(long$Group), ]
  summ <- long |>
    dplyr::group_by(Parameter, Group) |>
    dplyr::summarise(
      Mean = mean(Value, na.rm = TRUE),
      SE = sd(Value, na.rm = TRUE) / sqrt(dplyr::n()),
      .groups = "drop"
    )
  ggplot(summ, aes(Parameter, Mean, fill = Group)) +
    geom_col(position = position_dodge(0.8), width = 0.7, alpha = 0.85) +
    geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE), position = position_dodge(0.8), width = 0.25, colour = "#1e293b") +
    scale_fill_manual(values = WS_COLORS, na.value = "#94a3b8") +
    facet_wrap(~Parameter, scales = "free_y", ncol = 3) +
    labs(title = "Mean Parameter Comparison by Potability (Mean ± Standard Error)", x = NULL, y = "Mean Value", fill = "Potability Group") +
    theme_ws() +
    theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())
}

# 7. Scatter Plot with Linear Regression Fit & CI
plot_scatter <- function(df, x, y, smooth = TRUE) {
  g <- ggplot(df, aes(.data[[x]], .data[[y]], colour = Group)) +
    geom_point(alpha = 0.5, size = 1.8) +
    scale_colour_manual(values = WS_COLORS, na.value = "#94a3b8") +
    labs(title = paste("Bivariate Scatter Plot:", x, "vs", y), colour = "Potability Group") +
    theme_ws()
  if (smooth) {
    g <- g + geom_smooth(aes(group = 1), method = "lm", se = TRUE, colour = "#0f172a", linewidth = 0.75, fill = "#cbd5e1", alpha = 0.4)
  }
  g
}

# 8. Correlation Heatmap
plot_heatmap <- function(cm) {
  d <- as.data.frame(as.table(cm))
  names(d) <- c("X", "Y", "r")
  ggplot(d, aes(X, Y, fill = r)) +
    geom_tile(colour = "white", linewidth = 0.5) +
    geom_text(aes(label = sprintf("%.2f", r)), size = 3.2, fontface = "bold", colour = ifelse(abs(d$r) > 0.4, "white", "#1e293b")) +
    scale_fill_gradient2(low = "#dc2626", mid = "#f8fafc", high = "#0d9488", limits = c(-1, 1), name = "Correlation (r)") +
    labs(title = "Inter-Parameter Correlation Matrix Heatmap", x = NULL, y = NULL) +
    theme_ws() +
    theme(axis.text.x = element_text(angle = 40, hjust = 1, face = "bold"), axis.text.y = element_text(face = "bold"))
}

# 9. ROC Curve with AUC
plot_roc <- function(roc, auc) {
  ggplot(roc, aes(FPR, TPR)) +
    geom_line(colour = "#0d9488", linewidth = 1.2) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", colour = "#94a3b8", linewidth = 0.8) +
    labs(
      title = sprintf("Receiver Operating Characteristic (ROC) Curve [AUC = %.3f]", auc),
      subtitle = "Shows trade-off between True Positive Rate and False Positive Rate across all thresholds",
      x = "False Positive Rate (1 - Specificity)",
      y = "True Positive Rate (Sensitivity / Recall)"
    ) +
    annotate("text", x = 0.7, y = 0.25, label = sprintf("AUC = %.3f", auc), size = 5, fontface = "bold", colour = "#0f766e") +
    theme_ws()
}

# 10. Calibration Plot
plot_calibration <- function(cal) {
  ggplot(cal, aes(Mean_predicted, Observed_rate, size = N)) +
    geom_point(colour = "#0d9488", alpha = 0.8) +
    geom_abline(intercept = 0, slope = 1, linetype = "dashed", colour = "#94a3b8") +
    coord_cartesian(xlim = c(0, 1), ylim = c(0, 1)) +
    labs(
      title = "Probability Calibration Curve (Test Set)",
      subtitle = "Points along diagonal reflect ideal probabilistic calibration",
      x = "Mean Predicted Probability",
      y = "Observed Potable Rate",
      size = "Bin Count"
    ) +
    theme_ws()
}

# 11. Normal Q-Q Plot (Directly calculated coordinates for full Plotly compatibility)
plot_qq <- function(df, title = "Normal Q-Q Plot of Standardized Residuals") {
  y <- sort(df$Std[!is.na(df$Std)])
  n <- length(y)
  if (n < 2) {
    return(ggplot() + labs(title = title) + theme_ws())
  }
  x <- qnorm(ppoints(n))
  y_q <- quantile(y, c(0.25, 0.75))
  x_q <- qnorm(c(0.25, 0.75))
  slope <- (y_q[2] - y_q[1]) / (x_q[2] - x_q[1])
  intercept <- y_q[1] - slope * x_q[1]
  
  qq_df <- data.frame(Theoretical = x, Sample = y)
  line_df <- data.frame(
    Theoretical = c(min(x), max(x)),
    Sample = c(intercept + slope * min(x), intercept + slope * max(x))
  )
  
  ggplot(qq_df, aes(Theoretical, Sample)) +
    geom_point(alpha = 0.5, colour = "#0284c7") +
    geom_line(data = line_df, colour = "#dc2626", linewidth = 0.8) +
    labs(title = title, x = "Theoretical Quantiles", y = "Standardized Residuals") +
    theme_ws()
}

# 12. Missing Data Bar Chart
plot_missing_bars <- function(miss_df) {
  ggplot(miss_df, aes(reorder(Variable, -Percent), Percent)) +
    geom_col(fill = "#0284c7", alpha = 0.85, width = 0.6) +
    geom_text(aes(label = sprintf("%.1f%%", Percent)), vjust = -0.4, size = 3.2, fontface = "bold") +
    labs(title = "Missing Values Percentage per Parameter", x = "Parameter", y = "Missing Percentage (%)") +
    ylim(0, max(c(miss_df$Percent, 10)) * 1.15) +
    theme_ws() +
    theme(axis.text.x = element_text(angle = 35, hjust = 1, face = "bold"))
}

# 13. Outliers Bar Chart
plot_outlier_bars <- function(out_df) {
  ggplot(out_df, aes(reorder(Parameter, -Outliers), Outliers)) +
    geom_col(fill = "#e11d48", alpha = 0.8, width = 0.6) +
    geom_text(aes(label = Outliers), vjust = -0.4, size = 3.2, fontface = "bold") +
    labs(title = "Outliers Count (Tukey 1.5 x IQR Rule)", x = "Parameter", y = "Outlier Observations Count") +
    theme_ws() +
    theme(axis.text.x = element_text(angle = 35, hjust = 1, face = "bold"))
}

# 14. Visual Confusion Matrix Heatmap
plot_confusion_matrix <- function(counts) {
  tp <- counts["TP"]; fp <- counts["FP"]; fn <- counts["FN"]; tn <- counts["TN"]
  total <- max(1, tp + fp + fn + tn)
  df <- data.frame(
    Actual = factor(c("Actual Non-potable", "Actual Potable", "Actual Non-potable", "Actual Potable"),
                    levels = c("Actual Potable", "Actual Non-potable")),
    Predicted = factor(c("Predicted Non-potable", "Predicted Non-potable", "Predicted Potable", "Predicted Potable"),
                       levels = c("Predicted Potable", "Predicted Non-potable")),
    Type = c("TN", "FN", "FP", "TP"),
    Count = c(tn, fn, fp, tp)
  )
  df$Pct <- round(100 * df$Count / total, 1)
  df$Label <- sprintf("%s\n%d\n(%.1f%%)", df$Type, df$Count, df$Pct)
  
  ggplot(df, aes(Predicted, Actual, fill = Count)) +
    geom_tile(colour = "white", linewidth = 1.2) +
    geom_text(aes(label = Label), fontface = "bold", size = 4.5, colour = "#0f172a") +
    scale_fill_gradient(low = "#e2e8f0", high = "#5eead4", name = "Count") +
    labs(title = "Confusion Matrix Visual Heatmap", x = "Model Prediction", y = "Actual Ground Truth") +
    theme_ws()
}

# 15. Odds Ratio Forest Plot
plot_odds_ratios <- function(coefs_df) {
  cf <- coefs_df[coefs_df$Term != "(Intercept)", ]
  cf$Direction <- ifelse(cf$Odds_Ratio >= 1, "Higher Odds", "Lower Odds")
  ggplot(cf, aes(y = reorder(Term, Odds_Ratio), x = Odds_Ratio, colour = Direction)) +
    geom_vline(xintercept = 1, linetype = "dashed", colour = "#94a3b8", linewidth = 0.8) +
    geom_errorbar(aes(xmin = OR_low, xmax = OR_high), width = 0.25, linewidth = 0.8, orientation = "y") +
    geom_point(size = 3) +
    scale_colour_manual(values = c("Higher Odds" = "#0d9488", "Lower Odds" = "#dc2626")) +
    labs(
      title = "Odds Ratios with 95% Wald Confidence Intervals",
      subtitle = "Predictor impact per +1 Standard Deviation (Holding other parameters constant)",
      x = "Odds Ratio (OR)",
      y = "Parameter"
    ) +
    theme_ws()
}

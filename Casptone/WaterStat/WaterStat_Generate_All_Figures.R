# ================================================================
# WATERSTAT - COMBINED FIGURE GENERATION SCRIPT
# Creates report-ready PNG figures from the supplied water_quality.csv
# Run this script from the extracted WaterStat project folder.
# Output: WaterStat/Generated_Figures/
# ================================================================

# 1. Install/load required packages
required <- c("ggplot2", "dplyr", "tidyr", "scales", "FactoMineR", "pROC")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(scales)
})

# 2. Locate the dataset
possible_files <- c(
  "data/water_quality.csv",
  "water_quality.csv",
  "../water_quality.csv"
)
data_file <- possible_files[file.exists(possible_files)][1]
if (is.na(data_file)) {
  data_file <- file.choose()
}
raw <- read.csv(data_file, check.names = FALSE, stringsAsFactors = FALSE)

# 3. Standardize column names from the supplied dataset
names(raw) <- trimws(names(raw))
name_key <- tolower(gsub("[^a-z0-9]", "", names(raw)))
rename_map <- c(
  ph = "pH", hardness = "Hardness", solids = "Solids",
  chloramines = "Chloramines", sulfate = "Sulfate",
  conductivity = "Conductivity", organiccarbon = "Organic_carbon",
  trihalomethanes = "Trihalomethanes", turbidity = "Turbidity",
  potability = "Potability"
)
for (i in seq_along(name_key)) {
  if (name_key[i] %in% names(rename_map)) names(raw)[i] <- unname(rename_map[name_key[i]])
}
params <- c("pH", "Hardness", "Solids", "Chloramines", "Sulfate",
            "Conductivity", "Organic_carbon", "Trihalomethanes", "Turbidity")
required_cols <- c(params, "Potability")
if (!all(required_cols %in% names(raw))) {
  stop("Dataset is missing required columns: ",
       paste(setdiff(required_cols, names(raw)), collapse = ", "))
}
raw[required_cols] <- lapply(raw[required_cols], function(x) suppressWarnings(as.numeric(as.character(x))))
if (!all(na.omit(unique(raw$Potability)) %in% c(0, 1))) {
  stop("Potability must contain only 0 (non-potable) and 1 (potable).")
}

# 4. Create output directory and common theme
out_dir <- file.path(getwd(), "Generated_Figures")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

teal <- "#0f766e"
blue <- "#0284c7"
navy <- "#0f172a"
red <- "#dc2626"
gray <- "#64748b"
class_cols <- c("Non-potable" = red, "Potable" = teal)

theme_waterstat <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(face = "bold", size = 15, colour = navy),
      plot.subtitle = element_text(size = 10, colour = gray),
      axis.title = element_text(face = "bold", colour = "#334155"),
      axis.text = element_text(colour = "#475569"),
      panel.grid.minor = element_blank(),
      legend.position = "bottom",
      plot.margin = margin(12, 16, 12, 12)
    )
}
save_plot <- function(plot, filename, width = 10, height = 6) {
  ggsave(file.path(out_dir, filename), plot, width = width, height = height,
         dpi = 320, bg = "white")
}
save_base <- function(filename, expr, width = 2200, height = 1400) {
  png(file.path(out_dir, filename), width = width, height = height, res = 220)
  on.exit(dev.off(), add = TRUE)
  force(expr)
}

# 5. EDA preparation: remove duplicate rows; invalid negative values and pH > 14 -> NA.
eda <- raw[!duplicated(raw), , drop = FALSE]
for (v in params) {
  eda[[v]][!is.na(eda[[v]]) & eda[[v]] < 0] <- NA
}
eda$pH[!is.na(eda$pH) & eda$pH > 14] <- NA
eda$Group <- factor(ifelse(eda$Potability == 1, "Potable", "Non-potable"),
                    levels = c("Non-potable", "Potable"))
n <- nrow(raw)
missing_n <- sum(is.na(eda[params]))
duplicate_n <- sum(duplicated(raw))
class_counts <- table(factor(eda$Potability, levels = c(0, 1)))
class_labels <- c("Non-potable", "Potable")

# ================================================================
# FIGURE 1. WaterStat system architecture with four modules
# ================================================================
architecture <- data.frame(
  x = 1, y = c(9, 7.6, 6.1, 4.6, 3.1, 1.5),
  label = c(
    "USER INTERFACE  |  CSV / Excel Upload",
    "MODULE 1  |  Data Acquisition & Preprocessing\nValidation • Missing values • Invalid values • Outlier profiling",
    "MODULE 2  |  Exploratory & Descriptive Analysis\nDistributions • Summary statistics • Comparisons • Correlations",
    "MODULE 3  |  Inferential Analysis & Modeling\nHypothesis tests • PCA • Leakage-free logistic regression • Evaluation",
    "MODULE 4  |  Shiny Application & Assessment\nDashboard • Batch assessment • Custom sample assessment",
    "OUTPUTS  |  Charts • Statistical reports • Potability predictions • Downloads"
  ),
  fill = c("#e0f2fe", "#ccfbf1", "#dbeafe", "#ede9fe", "#ccfbf1", "#f1f5f9")
)
p1 <- ggplot(architecture, aes(x, y)) +
  geom_label(aes(label = label, fill = fill), width = 0.92, size = 3.7,
             label.size = 0.6, colour = navy, fontface = "bold", lineheight = 1.15) +
  scale_fill_identity() +
  geom_segment(data = data.frame(y = c(8.45, 6.95, 5.45, 3.95, 2.45)),
               aes(x = 1, xend = 1, y = y, yend = y - 0.55),
               inherit.aes = FALSE, arrow = grid::arrow(length = grid::unit(0.18, "inches")),
               linewidth = 0.8, colour = teal) +
  coord_cartesian(xlim = c(0.35, 1.65), ylim = c(0.7, 9.8)) +
  labs(title = "WaterStat System Architecture", subtitle = "Four-module software architecture") +
  theme_void() + theme(plot.title = element_text(face = "bold", size = 17, hjust = 0.5),
                       plot.subtitle = element_text(hjust = 0.5, colour = gray))
save_plot(p1, "Figure_01_System_Architecture.png", 10, 9)

# ================================================================
# FIGURE 2. Leakage-free preprocessing and modeling pipeline
# ================================================================
pipeline <- data.frame(
  x = 1, y = c(8, 6.8, 5.6, 4.4, 3.2, 2, 0.8),
  label = c(
    "Original labelled dataset",
    "Remove duplicate rows and create stratified train/test split",
    "TRAINING SET ONLY: learn medians for missing-value imputation",
    "TRAINING SET ONLY: log1p transform Solids; learn means and SDs",
    "Apply the fitted training transformations to train and test sets",
    "Fit logistic regression on transformed training data",
    "Evaluate once on held-out test set: ROC/AUC and confusion matrix"
  )
)
p2 <- ggplot(pipeline, aes(x, y)) +
  geom_label(aes(label = label), fill = "#eff6ff", colour = navy,
             label.size = 0.5, size = 3.7, fontface = "bold", label.padding = grid::unit(0.22, "lines")) +
  geom_segment(data = data.frame(y = seq(7.55, 2.55, by = -1)),
               aes(x = 1, xend = 1, y = y, yend = y - 0.48),
               inherit.aes = FALSE, arrow = grid::arrow(length = grid::unit(0.16, "inches")),
               colour = teal, linewidth = 0.8) +
  annotate("text", x = 1.47, y = 5.0, label = "No test-set\ninformation used\nto fit preprocessing",
           colour = red, fontface = "bold", size = 3.4, hjust = 0) +
  coord_cartesian(xlim = c(0.35, 2.35), ylim = c(0.2, 8.7)) +
  labs(title = "Leakage-Free Preprocessing and Modeling Pipeline",
       subtitle = "Imputation and scaling parameters are learned from training data only") +
  theme_void() + theme(plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
                       plot.subtitle = element_text(hjust = 0.5, colour = gray))
save_plot(p2, "Figure_02_Leakage_Free_Pipeline.png", 11, 9)

# ================================================================
# FIGURE 3. Dataset Assessment: validation report screen (report panel)
# ================================================================
validation_items <- data.frame(
  Item = c("Rows", "Columns", "Missing predictor cells", "Duplicate rows",
           "pH values above 14", "Negative predictor values",
           "Non-potable samples", "Potable samples"),
  Value = c(nrow(raw), ncol(raw), missing_n, duplicate_n,
            sum(raw$pH > 14, na.rm = TRUE),
            sum(vapply(raw[params], function(x) sum(x < 0, na.rm = TRUE), numeric(1))),
            unname(class_counts[1]), unname(class_counts[2]))
)
p3 <- ggplot(validation_items, aes(x = reorder(Item, Value), y = as.numeric(Value))) +
  geom_col(fill = blue, width = 0.68) + coord_flip() +
  geom_text(aes(label = comma(as.numeric(Value))), hjust = -0.12, size = 3.6, colour = navy) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.2))) +
  labs(title = "Dataset Assessment – Validation Summary",
       subtitle = paste("Source:", basename(data_file), "| Validation metrics calculated from the supplied file"),
       x = NULL, y = "Count") + theme_waterstat()
save_plot(p3, "Figure_03_Dataset_Assessment_Validation.png", 10, 6.5)

# ================================================================
# FIGURE 4. Home dashboard with dataset and model status
# ================================================================
dashboard_df <- data.frame(
  Metric = c("Dataset rows", "Water parameters", "Missing predictor cells",
             "Potable samples", "Non-potable samples", "Model"),
  Value = c(comma(nrow(raw)), length(params), comma(missing_n),
            comma(unname(class_counts[2])), comma(unname(class_counts[1])),
            "Training performed in Figure 15–16 pipeline")
)
p4 <- ggplot(dashboard_df, aes(x = 1, y = rev(seq_len(nrow(dashboard_df))))) +
  geom_tile(aes(fill = factor(Metric, levels = Metric)), width = 0.94, height = 0.82,
            colour = "white") +
  geom_text(aes(label = paste0(Metric, "\n", Value)), colour = navy,
            fontface = "bold", size = 4) +
  scale_fill_manual(values = rep(c("#e0f2fe", "#ccfbf1", "#dbeafe"), length.out = nrow(dashboard_df))) +
  coord_cartesian(xlim = c(0.45, 1.55)) +
  labs(title = "WaterStat Home Dashboard – Dataset Status",
       subtitle = "Dashboard summary generated from the uploaded dataset") +
  theme_void() + theme(legend.position = "none",
                       plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
                       plot.subtitle = element_text(hjust = 0.5, colour = gray))
save_plot(p4, "Figure_04_Home_Dashboard_Status.png", 10, 7)

# ================================================================
# FIGURE 5. Data Explorer screen – missingness profile
# ================================================================
miss_df <- data.frame(Parameter = params,
                      Missing = vapply(eda[params], function(x) sum(is.na(x)), numeric(1)))
p5 <- ggplot(miss_df, aes(x = reorder(Parameter, Missing), y = Missing)) +
  geom_col(fill = teal) + coord_flip() +
  geom_text(aes(label = Missing), hjust = -0.15, size = 3.4) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.18))) +
  labs(title = "Data Explorer – Missing Values by Parameter",
       x = NULL, y = "Missing observations") + theme_waterstat()
save_plot(p5, "Figure_05_Data_Explorer_Missingness.png", 10, 6)

# ================================================================
# FIGURE 6. Histogram of pH with mean and median
# ================================================================
ph <- eda$pH[!is.na(eda$pH)]
ph_stats <- data.frame(Mean = mean(ph), Median = median(ph))
p6 <- ggplot(data.frame(pH = ph), aes(pH)) +
  geom_histogram(bins = 35, fill = "#7dd3fc", colour = "white") +
  geom_vline(xintercept = mean(ph), colour = red, linewidth = 1.1) +
  geom_vline(xintercept = median(ph), colour = teal, linewidth = 1.1, linetype = "dashed") +
  annotate("label", x = Inf, y = Inf,
           label = sprintf("Mean = %.2f\\nMedian = %.2f", mean(ph), median(ph)),
           hjust = 1.05, vjust = 1.2, size = 3.7, fill = "white") +
  labs(title = "Distribution of pH with Mean and Median",
       x = "pH", y = "Frequency",
       caption = "Solid red line = mean; dashed teal line = median") + theme_waterstat()
save_plot(p6, "Figure_06_pH_Histogram_Mean_Median.png")

# ================================================================
# FIGURE 7. Box plots of standardized water-quality parameters
# ================================================================
z <- as.data.frame(scale(eda[params]))
z$Group <- eda$Group
zlong <- pivot_longer(z, cols = all_of(params), names_to = "Parameter", values_to = "Z_Score")
p7 <- ggplot(zlong, aes(Parameter, Z_Score, fill = Group)) +
  geom_boxplot(outlier.alpha = 0.18, position = position_dodge(width = 0.8)) +
  scale_fill_manual(values = class_cols) +
  labs(title = "Standardized Water-Quality Parameters",
       subtitle = "Z-scores place the nine parameters on a comparable scale",
       x = NULL, y = "Standardized value (Z-score)", fill = "Potability") +
  theme_waterstat() + theme(axis.text.x = element_text(angle = 35, hjust = 1))
save_plot(p7, "Figure_07_Standardized_Parameter_Boxplots.png", 12, 7)

# ================================================================
# FIGURE 8. Box plots of conductivity by pH group
# ================================================================
ph_group_data <- eda %>% filter(!is.na(pH), !is.na(Conductivity)) %>%
  mutate(pH_Group = cut(pH, breaks = c(-Inf, 6.5, 8.5, Inf),
                        labels = c("Acidic (<6.5)", "Neutral (6.5–8.5)", "Alkaline (>8.5)")))
p8 <- ggplot(ph_group_data, aes(pH_Group, Conductivity, fill = pH_Group)) +
  geom_boxplot(outlier.alpha = 0.2) +
  scale_fill_manual(values = c("#93c5fd", "#5eead4", "#c4b5fd")) +
  labs(title = "Conductivity by pH Group", x = "pH group",
       y = "Conductivity", fill = "pH group") + theme_waterstat() +
  theme(legend.position = "none")
save_plot(p8, "Figure_08_Conductivity_by_pH_Group.png")

# ================================================================
# FIGURE 9. Mean conductivity with 95% confidence intervals
# ================================================================
ci_data <- ph_group_data %>% group_by(pH_Group) %>%
  summarise(N = n(), Mean = mean(Conductivity),
            SD = sd(Conductivity), SE = SD / sqrt(N),
            Lower = Mean - qt(0.975, N - 1) * SE,
            Upper = Mean + qt(0.975, N - 1) * SE, .groups = "drop")
p9 <- ggplot(ci_data, aes(pH_Group, Mean)) +
  geom_point(size = 3.5, colour = teal) +
  geom_errorbar(aes(ymin = Lower, ymax = Upper), width = 0.16,
                linewidth = 0.9, colour = blue) +
  labs(title = "Mean Conductivity with 95% Confidence Intervals",
       x = "pH group", y = "Mean conductivity") + theme_waterstat()
save_plot(p9, "Figure_09_Mean_Conductivity_95CI.png")

# ================================================================
# FIGURE 10. Box plots of Solids for potable/non-potable samples
# ================================================================
p10 <- ggplot(eda %>% filter(!is.na(Solids)), aes(Group, Solids, fill = Group)) +
  geom_boxplot(outlier.alpha = 0.2) + scale_fill_manual(values = class_cols) +
  labs(title = "Solids by Potability Class", x = "Potability class", y = "Solids") +
  theme_waterstat() + theme(legend.position = "none")
save_plot(p10, "Figure_10_Solids_Potability_Boxplots.png")

# ================================================================
# FIGURE 11. Percentage potable/non-potable by pH group
# ================================================================
pH_percent <- eda %>% filter(!is.na(pH)) %>%
  mutate(pH_Group = cut(pH, breaks = c(-Inf, 6.5, 8.5, Inf),
                        labels = c("Acidic (<6.5)", "Neutral (6.5–8.5)", "Alkaline (>8.5)"))) %>%
  count(pH_Group, Group) %>% group_by(pH_Group) %>%
  mutate(Percent = n / sum(n) * 100) %>% ungroup()
p11 <- ggplot(pH_percent, aes(pH_Group, Percent, fill = Group)) +
  geom_col(position = "stack") + scale_fill_manual(values = class_cols) +
  scale_y_continuous(labels = label_percent(scale = 1)) +
  labs(title = "Potability Composition within pH Groups",
       x = "pH group", y = "Percentage of samples", fill = "Potability") +
  theme_waterstat()
save_plot(p11, "Figure_11_Potability_Percentage_by_pH_Group.png")

# ================================================================
# FIGURE 12. Scatter plot of Solids and Sulfate with regression line
# ================================================================
ss <- eda %>% filter(!is.na(Solids), !is.na(Sulfate))
p12 <- ggplot(ss, aes(Solids, Sulfate, colour = Group)) +
  geom_point(alpha = 0.42, size = 1.4) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE, colour = navy) +
  scale_colour_manual(values = class_cols) +
  labs(title = "Relationship between Solids and Sulfate",
       x = "Solids", y = "Sulfate", colour = "Potability") + theme_waterstat()
save_plot(p12, "Figure_12_Solids_Sulfate_Regression.png")

# ================================================================
# FIGURE 13. Scatter plots of pH and Hardness (values and ranks)
# ================================================================
phh <- eda %>% filter(!is.na(pH), !is.na(Hardness))
phh$PH_Rank <- rank(phh$pH, ties.method = "average")
phh$Hardness_Rank <- rank(phh$Hardness, ties.method = "average")
p13a <- ggplot(phh, aes(pH, Hardness, colour = Group)) +
  geom_point(alpha = 0.4) + geom_smooth(method = "lm", se = FALSE, colour = navy) +
  scale_colour_manual(values = class_cols) +
  labs(title = "pH and Hardness – Original Values", x = "pH", y = "Hardness") + theme_waterstat()
p13b <- ggplot(phh, aes(PH_Rank, Hardness_Rank, colour = Group)) +
  geom_point(alpha = 0.4) + geom_smooth(method = "lm", se = FALSE, colour = navy) +
  scale_colour_manual(values = class_cols) +
  labs(title = "pH and Hardness – Rank Values", x = "pH rank", y = "Hardness rank") + theme_waterstat()
save_plot(p13a, "Figure_13A_pH_Hardness_Values.png")
save_plot(p13b, "Figure_13B_pH_Hardness_Ranks.png")

# ================================================================
# FIGURE 14. Pearson correlation heatmap
# ================================================================
cor_mat <- cor(eda[params], use = "pairwise.complete.obs", method = "pearson")
cor_long <- as.data.frame(as.table(cor_mat))
names(cor_long) <- c("Parameter1", "Parameter2", "Correlation")
p14 <- ggplot(cor_long, aes(Parameter1, Parameter2, fill = Correlation)) +
  geom_tile(colour = "white") +
  geom_text(aes(label = sprintf("%.2f", Correlation)), size = 3) +
  scale_fill_gradient2(low = "#dc2626", mid = "white", high = teal,
                       midpoint = 0, limits = c(-1, 1)) +
  labs(title = "Pearson Correlation Heatmap",
       x = NULL, y = NULL, fill = "Pearson r") +
  theme_waterstat() + theme(axis.text.x = element_text(angle = 40, hjust = 1))
save_plot(p14, "Figure_14_Pearson_Correlation_Heatmap.png", 11, 9)

# ================================================================
# FIGURE 15. PCA scree plot and biplot
# ================================================================
pca_data <- eda[complete.cases(eda[params]), params, drop = FALSE]
if (nrow(pca_data) >= 20 && all(vapply(pca_data, sd, numeric(1)) > 0)) {
  pca_fit <- FactoMineR::PCA(pca_data, scale.unit = TRUE, graph = FALSE)
  eig <- as.data.frame(pca_fit$eig)
  eig$Component <- factor(paste0("PC", seq_len(nrow(eig))),
                          levels = paste0("PC", seq_len(nrow(eig))))
  names(eig)[1:3] <- c("Eigenvalue", "Variance", "Cumulative")
  p15a <- ggplot(eig, aes(Component, Variance, group = 1)) +
    geom_col(fill = blue) + geom_line(colour = teal, linewidth = 0.8) +
    geom_point(colour = teal, size = 2) +
    labs(title = "PCA Scree Plot", x = "Principal component",
         y = "Explained variance (%)") + theme_waterstat()
  save_plot(p15a, "Figure_15A_PCA_Scree_Plot.png", 10, 6)
  coords <- as.data.frame(pca_fit$var$coord[, 1:2, drop = FALSE])
  coords$Variable <- rownames(coords)
  names(coords)[1:2] <- c("PC1", "PC2")
  p15b <- ggplot(coords, aes(PC1, PC2, label = Variable)) +
    geom_hline(yintercept = 0, colour = "grey80") +
    geom_vline(xintercept = 0, colour = "grey80") +
    geom_segment(aes(x = 0, y = 0, xend = PC1, yend = PC2),
                 arrow = grid::arrow(length = grid::unit(0.16, "inches")), colour = teal) +
    geom_text(nudge_y = 0.06, colour = navy, fontface = "bold", size = 3.5) +
    coord_equal() + labs(title = "PCA Variable Biplot",
                         x = "PC1 loading", y = "PC2 loading") + theme_waterstat()
  save_plot(p15b, "Figure_15B_PCA_Biplot.png", 9, 7)
} else {
  warning("PCA figures skipped: fewer than 20 complete rows or a constant parameter.")
}

# ================================================================
# FIGURE 16–17. Logistic regression ROC and confusion matrix
# Split first; fit median imputation, log1p(Solids), and scaling on train only.
# ================================================================
model_data <- eda[!is.na(eda$Potability), c(params, "Potability"), drop = FALSE]
model_data <- model_data[!duplicated(model_data), , drop = FALSE]
set.seed(42)
train_idx <- unlist(lapply(split(seq_len(nrow(model_data)), model_data$Potability),
                           function(ii) sample(ii, max(1, floor(0.80 * length(ii))))))
train <- model_data[train_idx, , drop = FALSE]
test <- model_data[-train_idx, , drop = FALSE]

# Training-only fitted preprocessing
for (v in params) {
  train[[v]][!is.na(train[[v]]) & train[[v]] < 0] <- NA
  test[[v]][!is.na(test[[v]]) & test[[v]] < 0] <- NA
}
train$pH[!is.na(train$pH) & train$pH > 14] <- NA
test$pH[!is.na(test$pH) & test$pH > 14] <- NA
medians <- vapply(train[params], median, numeric(1), na.rm = TRUE)
if (any(!is.finite(medians))) stop("A training parameter has no valid values for median imputation.")
transform_x <- function(d) {
  x <- d[params]
  for (v in params) x[[v]][is.na(x[[v]])] <- medians[[v]]
  x$Solids <- log1p(x$Solids)
  x
}
x_train <- transform_x(train)
train_means <- vapply(x_train, mean, numeric(1))
train_sds <- vapply(x_train, sd, numeric(1))
train_sds[!is.finite(train_sds) | train_sds == 0] <- 1
scale_with_train <- function(x) as.data.frame(scale(x, center = train_means, scale = train_sds))
x_train_scaled <- scale_with_train(x_train)
x_test_scaled <- scale_with_train(transform_x(test))
fit <- glm(Potability ~ ., data = cbind(x_train_scaled, Potability = train$Potability),
           family = binomial())
prob <- as.numeric(predict(fit, newdata = x_test_scaled, type = "response"))
threshold <- 0.50
pred <- ifelse(prob >= threshold, 1, 0)
roc_obj <- pROC::roc(test$Potability, prob, quiet = TRUE, direction = "<")
auc_val <- as.numeric(pROC::auc(roc_obj))

roc_df <- data.frame(FPR = 1 - roc_obj$specificities, TPR = roc_obj$sensitivities)
p16 <- ggplot(roc_df, aes(FPR, TPR)) +
  geom_line(colour = teal, linewidth = 1.2) +
  geom_abline(intercept = 0, slope = 1, linetype = "dashed", colour = gray) +
  coord_equal() +
  annotate("label", x = 0.65, y = 0.18,
           label = sprintf("AUC = %.3f\\nThreshold = %.2f", auc_val, threshold),
           fill = "white", size = 4) +
  labs(title = "Logistic Regression – ROC Curve",
       x = "False Positive Rate", y = "True Positive Rate") + theme_waterstat()
save_plot(p16, "Figure_16_Model_Lab_ROC_Curve.png", 8, 7)

cm <- table(Actual = factor(test$Potability, levels = c(0, 1),
                            labels = c("Non-potable", "Potable")),
            Predicted = factor(pred, levels = c(0, 1),
                               labels = c("Non-potable", "Potable")))
cm_df <- as.data.frame(cm)
p17 <- ggplot(cm_df, aes(Predicted, Actual, fill = Freq)) +
  geom_tile(colour = "white", linewidth = 1.2) +
  geom_text(aes(label = Freq), size = 7, fontface = "bold", colour = navy) +
  scale_fill_gradient(low = "#dbeafe", high = teal) +
  labs(title = "Confusion Matrix at Selected Threshold",
       subtitle = sprintf("Threshold = %.2f | Held-out test set", threshold),
       x = "Predicted class", y = "Actual class", fill = "Samples") +
  theme_waterstat()
save_plot(p17, "Figure_17_Model_Lab_Confusion_Matrix.png", 8, 7)

# ================================================================
# FIGURE 18. Custom Sample Assessment screen (real model prediction)
# Uses a median-valued example sample; this is a demonstration input,
# not a laboratory measurement.
# ================================================================
sample_values <- medians
sample_frame <- as.data.frame(as.list(sample_values))
sample_frame$Solids <- log1p(sample_frame$Solids)
sample_scaled <- scale_with_train(sample_frame)
sample_prob <- as.numeric(predict(fit, newdata = sample_scaled, type = "response"))
sample_class <- ifelse(sample_prob >= threshold, "Potable", "Non-potable")
sample_panel <- data.frame(
  Parameter = params,
  Input_Value = as.numeric(medians[params])
)
p18 <- ggplot() +
  annotate("rect", xmin = 0, xmax = 10, ymin = 0, ymax = 10,
           fill = "#f8fafc", colour = "#cbd5e1", linewidth = 1) +
  annotate("text", x = 5, y = 9.3, label = "WaterStat – Custom Sample Assessment",
           fontface = "bold", size = 5, colour = navy) +
  annotate("text", x = 5, y = 8.3,
           label = paste0("Demonstration sample | Predicted class: ", sample_class),
           fontface = "bold", size = 4, colour = teal) +
  annotate("text", x = 5, y = 7.4,
           label = sprintf("Predicted probability of potability: %.1f%%", 100 * sample_prob),
           size = 4.2, colour = blue) +
  annotate("rect", xmin = 1, xmax = 9, ymin = 6.3, ymax = 6.65,
           fill = "#e2e8f0", colour = NA) +
  annotate("rect", xmin = 1, xmax = 1 + 8 * sample_prob, ymin = 6.3, ymax = 6.65,
           fill = teal, colour = NA) +
  annotate("text", x = 5, y = 5.7,
           label = paste(paste0(sample_panel$Parameter, ": ",
                                format(round(sample_panel$Input_Value, 2), nsmall = 2)),
                         collapse = "     |     "),
           size = 2.8, colour = "#334155") +
  annotate("text", x = 5, y = 4.3,
           label = "The example uses training-set median values.\nReplace these with measured laboratory values for a real assessment.",
           size = 3.5, colour = red) +
  coord_cartesian(xlim = c(0, 10), ylim = c(3.5, 10), clip = "off") +
  labs(caption = "Illustrative application panel generated from the fitted model") +
  theme_void() + theme(plot.caption = element_text(colour = gray, hjust = 0.5))
save_plot(p18, "Figure_18_Custom_Sample_Assessment.png", 12, 6)

# ================================================================
# FIGURE 19. Project Gantt chart
# Timeline is a proposed work plan, not recorded project dates.
# ================================================================
gantt <- data.frame(
  Task = factor(c("Dataset collection and validation",
                  "Preprocessing pipeline",
                  "Exploratory data analysis",
                  "Statistical testing and PCA",
                  "Model training and evaluation",
                  "Shiny dashboard development",
                  "Integration, testing and documentation"),
                levels = rev(c("Dataset collection and validation",
                               "Preprocessing pipeline",
                               "Exploratory data analysis",
                               "Statistical testing and PCA",
                               "Model training and evaluation",
                               "Shiny dashboard development",
                               "Integration, testing and documentation"))),
  Start = c(1, 2, 3, 4, 5, 5, 7),
  End = c(2, 3, 5, 6, 7, 8, 9)
)
p19 <- ggplot(gantt, aes(y = Task, x = Start, xend = End, yend = Task)) +
  geom_segment(linewidth = 8, colour = blue, lineend = "butt") +
  scale_x_continuous(breaks = 1:9, labels = paste("Week", 1:9),
                     limits = c(1, 9.2)) +
  labs(title = "WaterStat Project Gantt Chart",
       subtitle = "Proposed nine-week implementation schedule",
       x = "Project timeline", y = NULL) + theme_waterstat()
save_plot(p19, "Figure_19_Project_Gantt_Chart.png", 11, 6)

# Save a text summary of run details
writeLines(c(
  "WaterStat figure generation completed.",
  paste("Dataset:", normalizePath(data_file)),
  paste("Rows:", nrow(raw)),
  paste("Columns:", ncol(raw)),
  paste("Output folder:", normalizePath(out_dir)),
  "Figures 1–19 are saved as high-resolution PNG files.",
  "Note: Figures 3–5 are data-derived report/dashboard panels, not screenshots of a live Shiny browser session.",
  "The Gantt chart is a proposed schedule. The custom sample uses training-set medians as demonstration inputs."
), file.path(out_dir, "README_Figure_Generation.txt"))

cat("\\nDONE! Images saved in:\\n", normalizePath(out_dir), "\\n")
cat("Model test-set AUC:", round(auc_val, 4), "\\n")

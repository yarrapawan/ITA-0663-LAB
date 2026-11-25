# Module 2 - Descriptive & exploratory analysis (NA-aware; no imputation)
group_label <- function(p) factor(ifelse(p == 1, "Potable", "Non-potable"), levels = c("Non-potable", "Potable"))
add_group <- function(df) {
  df$Group <- if (TARGET %in% names(df)) group_label(df[[TARGET]]) else factor("All")
  df
}

describe_stats <- function(df, vars = WQ_PARAMS) {
  vars <- intersect(vars, WQ_PARAMS); if (!length(vars)) stop("Select at least one variable.")
  d <- do.call(rbind, lapply(vars, function(p) {
    x <- df[[p]]; q <- unname(quantile(x, c(.25, .75), na.rm = TRUE))
    data.frame(Parameter = p, N = sum(!is.na(x)), Mean = mean(x, na.rm = TRUE), Median = median(x, na.rm = TRUE),
               SD = sd(x, na.rm = TRUE), Variance = var(x, na.rm = TRUE), Min = min(x, na.rm = TRUE), Q1 = q[1], Q3 = q[2],
               Max = max(x, na.rm = TRUE), IQR = q[2] - q[1], Skewness = psych::skew(x, na.rm = TRUE))
  }))
  d[-1] <- round(d[-1], 3); d
}

group_stats <- function(df) {
  df |> dplyr::filter(!is.na(.data[[TARGET]])) |> dplyr::mutate(Group = group_label(.data[[TARGET]])) |>
    tidyr::pivot_longer(dplyr::all_of(WQ_PARAMS), names_to = "Parameter", values_to = "value") |>
    dplyr::filter(!is.na(value)) |> dplyr::group_by(Parameter, Group) |>
    dplyr::summarise(N = dplyr::n(), Mean = round(mean(value), 3), Median = round(median(value), 3),
                     SD = round(sd(value), 3), .groups = "drop")
}

cor_matrix <- function(df, method = "pearson") cor(df[WQ_PARAMS], method = method, use = "pairwise.complete.obs")

# All pairwise correlations with p-value, n and interpretation (alpha = 0.05)
cor_table <- function(df, method = "pearson", alpha = 0.05) {
  pr <- t(combn(WQ_PARAMS, 2))
  out <- do.call(rbind, lapply(seq_len(nrow(pr)), function(i) {
    x <- df[[pr[i, 1]]]; y <- df[[pr[i, 2]]]; ok <- complete.cases(x, y); n <- sum(ok)
    if (n < 4 || sd(x[ok]) == 0 || sd(y[ok]) == 0) return(data.frame(Variable_1 = pr[i, 1], Variable_2 = pr[i, 2], Method = method, r = NA, p_value = NA, n = n, Interpretation = "Insufficient data / no variation"))
    ct <- suppressWarnings(cor.test(x[ok], y[ok], method = method, exact = FALSE))
    r <- unname(ct$estimate); s <- abs(r)
    data.frame(Variable_1 = pr[i, 1], Variable_2 = pr[i, 2], Method = method, r = round(r, 4), p_value = signif(ct$p.value, 4), n = n,
               Interpretation = sprintf("%s %s %s correlation (|r|=%.2f). Association only, not causation.",
                                        if (ct$p.value < alpha) "Significant" else "Not significant", c("negligible", "weak", "moderate", "strong")[findInterval(s, c(.1, .3, .5)) + 1], if (r >= 0) "positive" else "negative", s))
  }))
  out
}

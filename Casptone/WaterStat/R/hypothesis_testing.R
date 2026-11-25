# Module 3 - Hypothesis tests (alpha = 0.05). Each test uses its own complete observations;
# no global imputation is applied.
ALPHA <- 0.05
effect_label <- function(d) c("negligible", "small", "medium", "large")[findInterval(abs(d), c(0.2, 0.5, 0.8)) + 1]
decide <- function(p, alpha = ALPHA) if (p < alpha) "Reject H0" else "Fail to reject H0"

run_ttest <- function(df, var, alpha = ALPHA) {
  d <- df[c(var, TARGET)]; d <- d[complete.cases(d), ]
  x1 <- d[[var]][d[[TARGET]] == 1]; x0 <- d[[var]][d[[TARGET]] == 0]
  if (length(x1) < 3 || length(x0) < 3) stop(sprintf("%s: fewer than 3 observations in a group.", var))
  if (sd(x1) == 0 && sd(x0) == 0) stop(sprintf("%s: no variation within groups.", var))
  tt <- t.test(x1, x0)   # Welch two-sample t-test
  sp <- sqrt(((length(x1) - 1) * var(x1) + (length(x0) - 1) * var(x0)) / (length(x1) + length(x0) - 2))
  dd <- if (is.na(sp) || sp == 0) 0 else (mean(x1) - mean(x0)) / sp
  sig <- tt$p.value < alpha
  data.frame(Parameter = var, H0 = "Mean(potable) = Mean(non-potable)", H1 = "Means differ (two-sided)",
             t = unname(tt$statistic), df = unname(tt$parameter), p_value = tt$p.value, Alpha = alpha,
             Mean_diff = unname(mean(x1) - mean(x0)), CI_low = tt$conf.int[1], CI_high = tt$conf.int[2], Cohens_d = dd,
             n_potable = length(x1), n_nonpotable = length(x0), Conclusion = decide(tt$p.value, alpha),
             Interpretation = sprintf("%s at alpha = %.2f; effect size is %s (d = %.2f). Statistical significance does not by itself imply practical importance.",
                                      if (sig) "Statistically significant difference" else "No significant difference", alpha, effect_label(dd), dd))
}
run_all_ttests <- function(df) {
  rs <- lapply(WQ_PARAMS, function(p) tryCatch(run_ttest(df, p), error = function(e) NULL))
  rs <- rs[!vapply(rs, is.null, logical(1))]
  if (!length(rs)) stop("No t-test could be computed (check group sizes and variation).")
  r <- do.call(rbind, rs); num <- vapply(r, is.numeric, logical(1)); r[num] <- lapply(r[num], signif, 4); r
}

bin_quantiles <- function(x, k = 4) {
  br <- unique(quantile(x, 0:k / k, na.rm = TRUE))
  if (length(br) < 3) stop("Too few distinct values to form groups.")
  cut(x, br, include.lowest = TRUE, labels = paste0("Q", seq_len(length(br) - 1)))
}

# One-way ANOVA. Grouping is either Potability (2 groups) or quantile bins of ANOTHER parameter.
run_anova <- function(df, response, group, k = 4, alpha = ALPHA) {
  if (!response %in% WQ_PARAMS) stop("Invalid response variable.")
  if (identical(response, group)) stop("The response and the grouping variable must be different.")
  if (!group %in% c(WQ_PARAMS, TARGET)) stop("Invalid grouping variable.")
  d <- df[c(response, group)]; d <- d[complete.cases(d), ]
  g <- if (group == TARGET) group_label(d[[group]]) else bin_quantiles(d[[group]], k)
  g <- droplevels(g); y <- d[[response]]
  if (nlevels(g) < 2) stop("At least two groups are required.")
  if (any(table(g) < 2)) stop("Every group needs at least 2 observations.")
  fit <- aov(y ~ g); s <- summary(fit)[[1]]; p <- s[["Pr(>F)"]][1]; eta <- s[["Sum Sq"]][1] / sum(s[["Sum Sq"]])
  res <- residuals(fit)
  sh <- if (length(res) >= 3 && sd(res) > 0) {
    tryCatch(shapiro.test(if (length(res) > 5000) res[round(seq(1, length(res), length.out = 5000))] else res)$p.value, error = function(e) NA)
  } else NA
  lv <- tryCatch(car::leveneTest(y ~ g)[["Pr(>F)"]][1], error = function(e) NA)
  kw <- tryCatch(kruskal.test(y ~ g)$p.value, error = function(e) NA)
  concerns <- (!is.na(sh) && sh < alpha) || (!is.na(lv) && lv < alpha)
  method <- if (group == TARGET) "Potability (2 groups)" else sprintf("%s split into %d quantile groups", group, nlevels(g))
  list(result = data.frame(Response = response, Grouping = method, H0 = "All group means are equal", H1 = "At least one group mean differs",
                           F = round(s[["F value"]][1], 3), df_between = s$Df[1], df_within = s$Df[2], p_value = signif(p, 4), Alpha = alpha,
                           Eta_squared = round(eta, 4), Conclusion = decide(p, alpha),
                           Interpretation = sprintf("%s; eta-squared = %.3f. %s Association only, not causation.",
                                                    if (p < alpha) "Group means differ significantly" else "No significant difference in group means", eta,
                                                    if (concerns) "Assumption concerns (see diagnostics): treat with caution and consider the Kruskal-Wallis result." else "No major assumption violations flagged.")),
       groups = data.frame(Group = levels(g), N = as.integer(table(g)), Mean = round(tapply(y, g, mean), 3), SD = round(tapply(y, g, sd), 3), row.names = NULL),
       diagnostics = data.frame(Check = c("Shapiro-Wilk on residuals (normality)", "Levene test (equal variances)", "Kruskal-Wallis (non-parametric check)"),
                                p_value = signif(c(sh, lv, kw), 4),
                                Note = c("p < 0.05 suggests non-normal residuals", "p < 0.05 suggests unequal variances", "Robust alternative; compare with ANOVA conclusion")),
       transformation = if (group == TARGET) "Grouping uses the Potability classes." else sprintf("The continuous variable '%s' was converted to %d quantile-based groups (Q1 = lowest).", group, nlevels(g)),
       resid = data.frame(Std = as.numeric(scale(res))))
}

# Chi-square test of independence: quantile-binned parameter vs Potability
run_chisq <- function(df, var, k = 4, alpha = ALPHA) {
  d <- df[c(var, TARGET)]; d <- d[complete.cases(d), ]
  tab <- table(bin_quantiles(d[[var]], k), group_label(d[[TARGET]]))
  if (nrow(tab) < 2 || ncol(tab) < 2) stop("Need at least a 2 x 2 table.")
  ct <- suppressWarnings(chisq.test(tab))
  v <- if (is.na(ct$statistic) || sum(tab) == 0) 0 else sqrt(max(0, unname(ct$statistic)) / (sum(tab) * max(1, min(dim(tab)) - 1)))
  low <- sum(ct$expected < 5)
  list(table = as.data.frame.matrix(tab),
       result = data.frame(Variable = sprintf("%s (%d quantile groups) vs Potability", var, nrow(tab)), H0 = "Variable group and Potability are independent",
                           H1 = "They are associated", Chi_sq = round(unname(ct$statistic), 3), df = unname(ct$parameter), p_value = signif(ct$p.value, 4), Alpha = alpha,
                           Cramers_V = round(v, 3), Conclusion = decide(ct$p.value, alpha),
                           Interpretation = sprintf("%s; Cramer's V = %.3f.%s Association only, not causation.", if (ct$p.value < alpha) "Significant association" else "No significant association", v,
                                                    if (low > 0) sprintf(" Warning: %d cell(s) have expected count < 5.", low) else "")))
}

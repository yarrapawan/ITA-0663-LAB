# Module 3 - Logistic regression: training, evaluation, robustness, prediction
auc_rank <- function(y, p) {
  r <- rank(p); n1 <- sum(y == 1); n0 <- sum(y == 0)
  (sum(r[y == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}
roc_df <- function(y, p) {
  th <- sort(unique(c(0, p, 1)), decreasing = TRUE)
  data.frame(FPR = vapply(th, function(t) mean(p[y == 0] >= t), numeric(1)),
             TPR = vapply(th, function(t) mean(p[y == 1] >= t), numeric(1)))
}
classification_metrics <- function(y, p, thr = 0.5) {
  pred <- as.integer(p >= thr)
  tp <- sum(pred == 1 & y == 1); tn <- sum(pred == 0 & y == 0); fp <- sum(pred == 1 & y == 0); fn <- sum(pred == 0 & y == 1)
  safe <- function(a, b) if (b == 0) NA_real_ else a / b
  prec <- safe(tp, tp + fp); rec <- safe(tp, tp + fn)
  f1 <- if (is.na(prec) || is.na(rec) || prec + rec == 0) NA_real_ else 2 * prec * rec / (prec + rec)
  list(counts = c(TP = tp, TN = tn, FP = fp, FN = fn),
       table = data.frame(Metric = c("Accuracy", "Precision", "Recall / Sensitivity", "Specificity", "F1-score"),
                          Value = round(c((tp + tn) / length(y), prec, rec, safe(tn, tn + fp), f1), 4)))
}
threshold_table <- function(y, p, ths = seq(0.1, 0.9, by = 0.1))
  do.call(rbind, lapply(ths, function(t) { m <- classification_metrics(y, p, t)$table$Value
    data.frame(Threshold = t, Accuracy = m[1], Precision = m[2], Sensitivity = m[3], Specificity = m[4], F1 = m[5]) }))
calibration_df <- function(y, p, bins = 10) {
  br <- unique(quantile(p, 0:bins / bins)); if (length(br) < 3) return(NULL)
  g <- cut(p, br, include.lowest = TRUE)
  data.frame(Bin = seq_len(nlevels(g)), N = as.vector(table(g)), Mean_predicted = round(as.vector(tapply(p, g, mean)), 4), Observed_rate = round(as.vector(tapply(y, g, mean)), 4))
}

train_logistic <- function(df, seed = 42, train_frac = 0.8, threshold = 0.5) {
  d <- df[!is.na(df[[TARGET]]), ]; d <- d[!duplicated(d), ]; d[[TARGET]] <- as.integer(d[[TARGET]])
  if (nrow(d) < 50) stop("At least 50 labelled observations are required.")
  if (length(unique(d[[TARGET]])) < 2) stop("Potability has only one class.")
  set.seed(seed)   # reproducible, stratified split
  idx <- unlist(lapply(split(seq_len(nrow(d)), d[[TARGET]]), function(i) i[sample.int(length(i), max(1, floor(train_frac * length(i))))]))
  train <- d[idx, ]; test <- d[-idx, ]
  if (length(unique(train[[TARGET]])) < 2 || length(unique(test[[TARGET]])) < 2) stop("Both classes must appear in the training and testing sets.")
  pp <- fit_preprocessor(train)                       # fitted on TRAINING data only
  tr <- cbind(apply_preprocessor(pp, train), Potability = train[[TARGET]])
  warns <- character()
  fit <- withCallingHandlers(glm(Potability ~ ., data = tr, family = binomial),
                             warning = function(w) { warns <<- c(warns, conditionMessage(w)); invokeRestart("muffleWarning") })
  if (!fit$converged) stop("Logistic regression did not converge.")
  s <- summary(fit)$coefficients; ci <- confint.default(fit)
  coefs <- data.frame(Term = rownames(s), Estimate = s[, 1], Std_Error = s[, 2], z = s[, 3], p_value = s[, 4],
                      CI_low = ci[, 1], CI_high = ci[, 2], Odds_Ratio = exp(s[, 1]), OR_low = exp(ci[, 1]), OR_high = exp(ci[, 2]),
                      Significant = s[, 4] < ALPHA, row.names = NULL)
  p_test <- as.numeric(predict(fit, apply_preprocessor(pp, test), type = "response")); y_test <- test[[TARGET]]
  cls <- function(y) data.frame(Class = c("0 (non-potable)", "1 (potable)"), Count = as.integer(table(factor(y, levels = 0:1))),
                                Percent = round(100 * as.numeric(table(factor(y, levels = 0:1))) / length(y), 2))
  prev <- mean(d[[TARGET]])
  list(fit = fit, pp = pp, coefs = coefs, seed = seed, threshold = threshold, train_frac = train_frac,
       n_total = nrow(d), n_train = nrow(train), n_test = nrow(test), formula = paste("Potability ~", paste(WQ_PARAMS, collapse = " + ")),
       y_test = y_test, p_test = p_test, auc = auc_rank(y_test, p_test), roc = roc_df(y_test, p_test),
       brier = mean((p_test - y_test)^2), brier_baseline = mean((mean(train[[TARGET]]) - y_test)^2),
       calibration = calibration_df(y_test, p_test), classes = cls(d[[TARGET]]), classes_train = cls(train[[TARGET]]), classes_test = cls(y_test),
       minority_share = min(prev, 1 - prev), vif = tryCatch(car::vif(fit), error = function(e) NULL), pseudo_r2 = 1 - fit$deviance / fit$null.deviance, aic = AIC(fit), warnings = unique(warns))
}

# Same fitted preprocessing is used for every new observation.
predict_dataset <- function(model, df) {
  p <- as.numeric(predict(model$fit, apply_preprocessor(model$pp, df), type = "response"))
  out <- data.frame(Row = seq_len(nrow(df)), Predicted_Probability = round(p, 4),
                    Model_Classification = ifelse(p >= model$threshold, "Potable", "Non-potable"))
  if (TARGET %in% names(df)) out$Actual_Label <- ifelse(is.na(df[[TARGET]]), NA, ifelse(df[[TARGET]] == 1, "Potable", "Non-potable"))
  out
}
predict_sample <- function(model, values) {
  df <- as.data.frame(as.list(values)); z <- apply_preprocessor(model$pp, df)
  b <- coef(model$fit); contrib <- b[colnames(z)] * unlist(z[1, ])
  p <- plogis(unname(b["(Intercept)"] + sum(contrib, na.rm = TRUE))); rng <- model$pp$ranges
  out_bounds <- vapply(WQ_PARAMS, function(p) {
    val <- values[p]
    !is.na(val) && (val < rng["min", p] || val > rng["max", p])
  }, logical(1))
  list(prob = p, class = if (p >= model$threshold) "Potable" else "Non-potable", z = z, contrib = contrib,
       outside = WQ_PARAMS[out_bounds])
}

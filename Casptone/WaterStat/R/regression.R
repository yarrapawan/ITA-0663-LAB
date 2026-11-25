# Module 3 - Multiple linear regression (complete cases for the chosen variables) + residual analysis
fit_mlr <- function(df, response, predictors = setdiff(WQ_PARAMS, response)) {
  predictors <- setdiff(predictors, response)
  if (!length(predictors)) stop("Select at least one predictor different from the response.")
  d <- df[c(response, predictors)]; d <- d[complete.cases(d), ]
  if (nrow(d) < length(predictors) + 10) stop("Too few complete observations for this regression.")
  fit <- lm(reformulate(predictors, response), data = d); s <- summary(fit); ci <- confint(fit); fs <- s$fstatistic
  list(fit = fit, n = nrow(d),
       coefs = data.frame(Term = rownames(s$coefficients), Estimate = s$coefficients[, 1], Std_Error = s$coefficients[, 2],
                          t = s$coefficients[, 3], p_value = s$coefficients[, 4], CI_low = ci[, 1], CI_high = ci[, 2], row.names = NULL),
       r2 = s$r.squared, adj_r2 = s$adj.r.squared, f_p = unname(pf(fs[1], fs[2], fs[3], lower.tail = FALSE)),
       vif = if (length(predictors) > 1) tryCatch(car::vif(fit), error = function(e) NULL) else NULL,
       resid = data.frame(Fitted = fitted(fit), Residual = resid(fit), Std = rstandard(fit), SqrtAbsStd = sqrt(abs(rstandard(fit)))))
}

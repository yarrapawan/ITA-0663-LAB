# Module 3 - PCA (exploratory; FactoMineR + factoextra). Uses complete observations.
run_pca <- function(df) {
  d <- df[complete.cases(df[WQ_PARAMS]), ]
  if (nrow(d) < 20) stop("Too few complete observations for PCA (need at least 20).")
  if (any(vapply(d[WQ_PARAMS], function(x) sd(x) == 0, logical(1)))) stop("A parameter has no variation in the selected data.")
  list(res = FactoMineR::PCA(d[WQ_PARAMS], scale.unit = TRUE, graph = FALSE), data = d)
}
pca_eig_table <- function(p) {
  e <- as.data.frame(p$res$eig); names(e) <- c("Eigenvalue", "Variance_pct", "Cumulative_pct")
  cbind(Component = paste0("PC", seq_len(nrow(e))), round(e, 3))
}
pca_loadings <- function(p) round(as.data.frame(p$res$var$coord), 3)
pca_contrib <- function(p) round(as.data.frame(p$res$var$contrib), 2)
pca_scores <- function(p) {
  s <- round(as.data.frame(p$res$ind$coord), 3); if (TARGET %in% names(p$data)) s$Potability <- p$data[[TARGET]]; s
}

# Module 1 - Data acquisition, validation & preprocessing
# Three separate preprocessing paths:
#   (1) EDA            : eda_data()            duplicates removed, invalid -> NA, NO imputation
#   (2) Statistical    : complete observations chosen per test inside each test function
#   (3) Machine learning: fit_preprocessor()/apply_preprocessor() fitted on TRAINING data only
WQ_PARAMS <- c("pH","Hardness","Solids","Chloramines","Sulfate","Conductivity",
               "Organic_carbon","Trihalomethanes","Turbidity")
TARGET <- "Potability"
LOG_VARS <- "Solids"
NO_DATA_MSG <- "No dataset loaded. Upload a CSV or Excel water-quality dataset to begin."

# ---- shiny helpers -------------------------------------------------------------------
need_valid <- function(state)
  shiny::validate(shiny::need(!is.null(state$raw), NO_DATA_MSG),
                  shiny::need(!is.null(state$data), "The uploaded dataset failed validation. See the Validation report in Dataset Assessment."))
need_target <- function(state) {
  need_valid(state)
  shiny::validate(shiny::need(isTRUE(state$validation$has_target), "This analysis needs a valid Potability column (0/1) containing both classes."))
}
# Run an analysis; any failure becomes a friendly message instead of crashing the app.
safe_run <- function(expr, what = "Analysis")
  tryCatch(expr, shiny.silent.error = function(e) stop(e),
           error = function(e) shiny::validate(shiny::need(FALSE, paste0(what, " could not be completed: ", conditionMessage(e)))))

write_sections <- function(file, sections) {   # several tables in one CSV, each under a "# title" line
  con <- file(file, "w"); on.exit(close(con))
  for (nm in names(sections)) {
    writeLines(paste0("# ", nm), con)
    utils::write.table(sections[[nm]], con, sep = ",", row.names = FALSE, qmethod = "double")
    writeLines("", con)
  }
}

# ---- reading & coercion --------------------------------------------------------------
canon_names <- function(x) {
  # Remove parenthetical / bracketed measurement units e.g. (mg/L), [ppm], (uS/cm), (0/1)
  s <- gsub("\\s*\\([^)]*\\)", "", x)
  s <- gsub("\\s*\\[[^]]*\\]", "", s)
  key <- tolower(gsub("[^A-Za-z0-9]", "", s))
  
  vapply(seq_along(x), function(i) {
    k <- key[i]
    if (k %in% c("ph", "phvalue", "phlevel")) return("pH")
    if (k %in% c("hardness", "waterhardness")) return("Hardness")
    if (k %in% c("solids", "solid", "tds", "totaldissolvedsolids", "dissolvedsolids")) return("Solids")
    if (k %in% c("chloramines", "chloramine")) return("Chloramines")
    if (k %in% c("sulfate", "sulphate", "sulfates", "sulphates", "so4")) return("Sulfate")
    if (k %in% c("conductivity", "conductance", "electricalconductivity", "ec")) return("Conductivity")
    if (k %in% c("organiccarbon", "organic_carbon", "toc", "totalorganiccarbon")) return("Organic_carbon")
    if (k %in% c("trihalomethanes", "trihalomethane", "thm", "thms", "totaltrihalomethanes")) return("Trihalomethanes")
    if (k %in% c("turbidity", "turbid")) return("Turbidity")
    if (k %in% c("potability", "potable", "ispotable", "target", "class", "label", "outcome", "waterpotability", "potabilityclass")) return("Potability")
    trimws(x[i])
  }, character(1))
}

coerce_numeric <- function(df) {
  nn <- integer(0)
  for (p in intersect(c(WQ_PARAMS, TARGET), names(df))) {
    x <- df[[p]]
    if (is.numeric(x) || is.integer(x)) {
      nn[p] <- 0L
    } else {
      xc <- suppressWarnings(as.numeric(as.character(x)))
      nn[p] <- sum(!is.na(x) & trimws(as.character(x)) != "" & is.na(xc))
      df[[p]] <- xc
    }
  }
  attr(df, "nonnumeric_cells") <- nn
  df
}

read_water_data <- function(path, name = path) {
  ext <- tolower(tools::file_ext(name))
  df <- if (ext %in% c("xlsx", "xls")) {
    readxl::read_excel(path)
  } else {
    first_line <- tryCatch(readLines(path, n = 1, warn = FALSE), error = function(e) "")
    commas <- lengths(regmatches(first_line, gregexpr(",", first_line)))
    semicolons <- lengths(regmatches(first_line, gregexpr(";", first_line)))
    tabs <- lengths(regmatches(first_line, gregexpr("\t", first_line)))
    delim <- if (semicolons > commas && semicolons > tabs) ";" else if (tabs > commas) "\t" else ","
    
    tryCatch(
      readr::read_delim(path, delim = delim, show_col_types = FALSE, progress = FALSE),
      error = function(e) {
        if (delim == ";") utils::read.csv2(path, stringsAsFactors = FALSE, check.names = FALSE)
        else if (delim == "\t") utils::read.delim(path, stringsAsFactors = FALSE, check.names = FALSE)
        else utils::read.csv(path, stringsAsFactors = FALSE, check.names = FALSE)
      }
    )
  }
  df <- as.data.frame(df)
  if (!nrow(df) || !ncol(df)) stop("The file is empty.")
  names(df) <- make.unique(canon_names(names(df)))
  
  # Auto-convert text labels in Potability (e.g. Potable / Non-potable, Yes / No) to 0/1 integers
  if (TARGET %in% names(df)) {
    t_raw <- trimws(as.character(df[[TARGET]]))
    t_lower <- tolower(t_raw)
    is_text <- any(t_lower %in% c("potable", "non-potable", "nonpotable", "yes", "no", "true", "false", "safe", "unsafe"))
    if (is_text) {
      df[[TARGET]] <- ifelse(t_lower %in% c("potable", "yes", "true", "1", "safe"), 1L,
                      ifelse(t_lower %in% c("non-potable", "nonpotable", "no", "false", "0", "unsafe"), 0L, NA_integer_))
    }
  }
  
  coerce_numeric(df)
}

# ---- validation ----------------------------------------------------------------------
validate_dataset <- function(df, nonnumeric = attr(df, "nonnumeric_cells")) {
  errors <- character(); warns <- character()
  if (is.null(nonnumeric)) nonnumeric <- integer(0)
  n <- nrow(df); present <- intersect(WQ_PARAMS, names(df)); miss <- setdiff(WQ_PARAMS, names(df))
  has_col <- TARGET %in% names(df)
  if (n == 0) errors <- c(errors, "The dataset has no rows.")
  else if (n < 10) errors <- c(errors, sprintf("Only %d rows; at least 10 are required.", n))
  if (length(miss)) errors <- c(errors, paste("Missing required column(s):", paste(miss, collapse = ", ")))
  for (p in present) {
    x <- df[[p]]
    if (!is.numeric(x) || all(is.na(x))) errors <- c(errors, sprintf("Column '%s' has no usable numeric values.", p))
  }
  inv <- data.frame(Column = c(present, if (has_col) TARGET), stringsAsFactors = FALSE)
  inv$Non_numeric_cells <- as.integer(ifelse(is.na(nonnumeric[inv$Column]), 0L, nonnumeric[inv$Column]))
  inv$Negative <- vapply(inv$Column, function(p) if (is.numeric(df[[p]])) sum(df[[p]] < 0, na.rm = TRUE) else 0L, numeric(1))
  inv$Out_of_range <- vapply(inv$Column, function(p) if (p == "pH" && is.numeric(df$pH)) sum(df$pH > 14, na.rm = TRUE) else 0L, numeric(1))
  inv$Negative[inv$Column == TARGET] <- 0
  if (any(inv$Non_numeric_cells > 0)) warns <- c(warns, "Non-numeric entries were found and converted to missing (see invalid-values table).")
  if (sum(inv$Negative) > 0) warns <- c(warns, "Negative values found; physically invalid, treated as missing in analysis.")
  if (sum(inv$Out_of_range) > 0) warns <- c(warns, "pH values above 14 found; treated as missing in analysis.")
  # target
  has_target <- FALSE; classes <- NULL; usable_target <- 0L
  if (has_col) {
    t <- df[[TARGET]]; vals <- unique(na.omit(t))
    if (!is.numeric(t) || !all(vals %in% c(0, 1))) errors <- c(errors, "Potability must contain only 0 (non-potable) and 1 (potable).")
    else {
      tb <- table(factor(t, levels = c(0, 1)))
      classes <- data.frame(Class = c("0 (non-potable)", "1 (potable)"), Count = as.integer(tb), Percent = round(100 * as.numeric(tb) / max(sum(tb), 1), 2))
      usable_target <- sum(tb); has_target <- all(tb >= 5)
      if (anyNA(t)) warns <- c(warns, sprintf("%d rows have a missing Potability label (ignored for group analysis and modeling).", sum(is.na(t))))
      if (!has_target) warns <- c(warns, "Potability needs at least 5 observations in each class for group analysis and modeling.")
    }
  } else warns <- c(warns, "No Potability column: group comparisons and modeling are disabled.")
  n_missing <- if (length(present)) sum(is.na(df[present])) else 0L
  n_dup <- if (n > 0) sum(duplicated(df)) else 0L
  if (n_missing > 0) warns <- c(warns, sprintf("%d missing predictor values.", n_missing))
  if (n_dup > 0) warns <- c(warns, sprintf("%d duplicate rows (removed for analysis).", n_dup))
  ok <- length(errors) == 0
  if (ok && has_target && usable_target - n_dup < 50) { warns <- c(warns, "Fewer than 50 labelled observations: modeling disabled."); has_target_model <- FALSE } else has_target_model <- TRUE
  types <- data.frame(Column = names(df), Type = vapply(df, function(x) class(x)[1], character(1)),
                      Required = names(df) %in% c(WQ_PARAMS, TARGET), row.names = NULL)
  list(ok = ok, has_target = ok && has_target, ok_model = ok && has_target && has_target_model,
       errors = errors, warnings = warns, rows = n, cols = ncol(df), missing = n_missing, duplicates = n_dup,
       numeric_cols = sum(vapply(df, is.numeric, logical(1))), nonnumeric_cols = sum(!vapply(df, is.numeric, logical(1))),
       missing_required = miss, invalid = inv, classes = classes, types = types,
       summary = data.frame(Item = c("Dataset status", "Rows", "Columns", "Missing values (predictors)", "Duplicate rows", "Target variable"),
                            Value = c(if (!ok) "Invalid" else if (!has_target) "Valid (no usable target: modeling disabled)" else "Valid",
                                      n, ncol(df), n_missing, n_dup, if (has_col) TARGET else "not found")))
}

# ---- (1) EDA preprocessing --------------------------------------------------------------
invalid_to_na <- function(d) {
  for (p in intersect(WQ_PARAMS, names(d))) {
    x <- d[[p]]; x[!is.na(x) & x < 0] <- NA
    if (p == "pH") x[!is.na(x) & x > 14] <- NA
    d[[p]] <- x
  }
  d
}
eda_data <- function(raw) { d <- raw[!duplicated(raw), , drop = FALSE]; d <- invalid_to_na(d); rownames(d) <- NULL; d }

missing_summary <- function(df) {
  cols <- intersect(c(WQ_PARAMS, TARGET), names(df))
  data.frame(Variable = cols, Missing = vapply(df[cols], function(x) sum(is.na(x)), numeric(1)),
             Percent = round(100 * vapply(df[cols], function(x) mean(is.na(x)), numeric(1)), 2), row.names = NULL)
}
outlier_summary <- function(df) {   # Tukey 1.5 x IQR rule; flagged, never removed
  do.call(rbind, lapply(WQ_PARAMS, function(p) {
    x <- df[[p]]; q <- quantile(x, c(.25, .75), na.rm = TRUE); i <- q[2] - q[1]
    lo <- q[1] - 1.5 * i; hi <- q[2] + 1.5 * i
    data.frame(Parameter = p, Lower_fence = round(unname(lo), 3), Upper_fence = round(unname(hi), 3),
               Outliers = sum(x < lo | x > hi, na.rm = TRUE))
  }))
}

# ---- (3) Machine-learning preprocessing (fit on TRAIN only, reuse everywhere) --------------
impute_with <- function(d, med) {
  for (p in WQ_PARAMS) { x <- d[[p]]; x[is.na(x)] <- med[[p]]; d[[p]] <- x }
  d
}
transform_params <- function(x, log_vars) { for (v in log_vars) x[[v]] <- log1p(x[[v]]); x }

fit_preprocessor <- function(df, log_vars = LOG_VARS) {
  x <- invalid_to_na(df[WQ_PARAMS])
  med <- vapply(x, median, numeric(1), na.rm = TRUE)
  xt <- transform_params(impute_with(x, med), log_vars)
  list(medians = med, log_vars = log_vars, means = colMeans(xt), sds = vapply(xt, sd, numeric(1)),
       ranges = rbind(min = vapply(x, min, numeric(1), na.rm = TRUE), max = vapply(x, max, numeric(1), na.rm = TRUE)))
}
apply_preprocessor <- function(pp, df) {
  x <- transform_params(impute_with(invalid_to_na(df[WQ_PARAMS]), pp$medians), pp$log_vars)
  as.data.frame(sweep(sweep(as.matrix(x), 2, pp$means[colnames(x)], "-"), 2, pp$sds[colnames(x)], "/"))
}

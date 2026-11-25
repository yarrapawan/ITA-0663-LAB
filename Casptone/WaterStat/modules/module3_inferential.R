# Module 3 — Inferential Statistical Analysis & Modeling
# Performs hypothesis testing (t-test, ANOVA, Chi-square), regression (MLR),
# PCA dimensionality reduction, and logistic regression model training & evaluation.

module3InferentialUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(class = "module-header mb-3 p-3 bg-white rounded shadow-sm border-start border-4 border-success",
      div(class = "d-flex justify-content-between align-items-center flex-wrap gap-2",
        div(
          h4(class = "mb-1 text-success fw-bold", icon("brain", class = "me-2"), "Module 3: Inferential Statistical Analysis & Modeling"),
          p(class = "text-muted mb-0 small",
            "Performs rigorous Welch t-tests, One-Way ANOVA with assumption tests (Levene, Shapiro-Wilk), Chi-square, MLR with VIF collinearity checks, PCA, and trains stratified Logistic Regression with standardized Odds Ratios.")
        ),
        span(class = "badge bg-success-subtle text-success fw-bold px-3 py-2 border", icon("microscope", class = "me-1"), "Hypothesis & Modeling Engine")
      )
    ),
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(width = 300,
        # Pre-training checklist
        div(class = "p-2 mb-2 rounded bg-light border",
          h6(class = "fw-bold text-dark mb-2", icon("list-check", class = "text-success me-1"), " Pre-Training Checklist"),
          uiOutput(ns("pretrain_checklist"))
        ),
        hr(class = "my-2"),
        h6(class = "fw-bold text-dark", icon("gears"), " Hyperparameter Configuration"),
        numericInput(ns("seed"), "Random Seed (Reproducibility):", value = 42, min = 1, step = 1),
        sliderInput(ns("frac"), "Training Set Proportion:", min = 0.50, max = 0.90, value = 0.80, step = 0.05),
        sliderInput(ns("thr"), "Classification Threshold:", min = 0.10, max = 0.90, value = 0.50, step = 0.05),
        uiOutput(ns("train_button_ui")),
        uiOutput(ns("model_badge")),
        hr(),
        h6(class = "fw-bold text-dark", icon("file-arrow-down"), " Export Modeling Outputs"),
        downloadButton(ns("dl_model_sum"),    "Download Model Summary",   class = "btn-outline-success btn-sm w-100 mb-2"),
        downloadButton(ns("dl_eval_metrics"), "Download Metrics & ROC",   class = "btn-outline-secondary btn-sm w-100")
      ),
      navset_card_tab(
        id = ns("tabs"),
        nav_panel(
          title = tagList(icon("vial-virus"), " Hypothesis Testing"),
          card(card_header(icon("code-compare"), " Welch Two-Sample t-tests: Potable vs Non-Potable (alpha = 0.05)"),
            p(class = "small text-muted", "Evaluates whether mean water parameter levels differ significantly between potable and non-potable samples. Includes Cohen's d effect sizes."),
            DTOutput(ns("table_ttests"))
          ),
          hr(),
          card(card_header(icon("chart-gantt"), " One-Way Analysis of Variance (ANOVA)"),
            layout_columns(
              col_widths = c(4, 4, 4),
              selectInput(ns("an_resp"), "Response Parameter:", WQ_PARAMS, selected = "pH"),
              uiOutput(ns("an_grp_ui")),
              selectInput(ns("an_k"), "Quantile Bins for Continuous:", c("3 Groups (Tertiles)" = 3, "4 Groups (Quartiles)" = 4, "5 Groups (Quintiles)" = 5), selected = 4)
            ),
            div(class = "alert alert-light py-1 small border", textOutput(ns("an_note"))),
            layout_columns(
              col_widths = c(7, 5),
              tableOutput(ns("table_anova_result")),
              tableOutput(ns("table_anova_groups"))
            ),
            h6(class = "fw-bold text-secondary mt-2", "ANOVA Assumption Diagnostics"),
            layout_columns(
              col_widths = c(6, 6),
              tableOutput(ns("table_anova_diag")),
              plotlyOutput(ns("plot_anova_qq"), height = "260px")
            )
          ),
          hr(),
          card(card_header(icon("cubes"), " Chi-Square Test of Independence"),
            selectInput(ns("chi_param"), "Select Parameter to Group into Quantiles vs Potability:", WQ_PARAMS, selected = "Sulfate"),
            layout_columns(
              col_widths = c(5, 7),
              tableOutput(ns("table_chi_contingency")),
              tableOutput(ns("table_chi_result"))
            )
          )
        ),
        nav_panel(
          title = tagList(icon("chart-line"), " Multiple Linear Regression"),
          p(class = "small text-muted", "Explores multivariate linear dependencies between water-quality parameters. Assesses model fit (R², F-test) and multicollinearity (VIF)."),
          layout_columns(
            col_widths = c(4, 8),
            selectInput(ns("mlr_resp"), "Response Parameter (Y):", WQ_PARAMS, selected = "Turbidity"),
            selectizeInput(ns("mlr_preds"), "Predictor Parameters (X):", WQ_PARAMS, selected = setdiff(WQ_PARAMS, "Turbidity"), multiple = TRUE)
          ),
          div(class = "alert alert-secondary py-2 small", uiOutput(ns("mlr_fit_summary"))),
          card(card_header("Regression Coefficients and Significance"), DTOutput(ns("table_mlr_coefs"))),
          h6(class = "fw-bold text-secondary mt-3", icon("microscope"), " Residual Diagnostic Plots"),
          layout_columns(
            col_widths = c(4, 4, 4),
            plotlyOutput(ns("plot_mlr_fitted"), height = "280px"),
            plotlyOutput(ns("plot_mlr_qq"), height = "280px"),
            plotlyOutput(ns("plot_mlr_scale_loc"), height = "280px")
          )
        ),
        nav_panel(
          title = tagList(icon("compass-drafting"), " Principal Component Analysis"),
          p(class = "small text-muted", "Unsupervised dimensionality reduction on standardized complete observations to detect multidimensional patterns and parameter loadings."),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header("Scree Plot: Explained Variance by PC"), plotOutput(ns("plot_pca_scree"), height = "360px")),
            card(card_header("PCA Biplot (Observations & Parameter Vectors)"), plotOutput(ns("plot_pca_biplot"), height = "360px"))
          ),
          card(card_header("Variable Contributions to Principal Component 1"), plotOutput(ns("plot_pca_contrib"), height = "260px")),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header("Eigenvalues & Cumulative Variance"), DTOutput(ns("table_pca_eig"))),
            card(card_header("Principal Component Loadings (Coordinates)"), tableOutput(ns("table_pca_loadings")))
          ),
          card(card_header("Individual Observation Scores (Sample Preview)"), DTOutput(ns("table_pca_scores")))
        ),
        nav_panel(
          title = tagList(icon("robot"), " Logistic Regression Model"),
          uiOutput(ns("model_pipeline_info")),
          card(card_header(icon("square-root-variable"), " Fitted Logistic Regression Formula"),
            verbatimTextOutput(ns("text_formula"))
          ),
          card(card_header(icon("ranking-star"), " Parameter Coefficients & Odds Ratios (per +1 SD)"),
            DTOutput(ns("table_logistic_coefs")),
            uiOutput(ns("odds_ratio_explanation"))
          ),
          card(card_header(icon("chart-simple"), " Odds Ratios Forest Plot (95% Wald CI)"),
            plotlyOutput(ns("plot_forest_odds"), height = "350px")
          ),
          card(card_header(icon("stethoscope"), " Model Goodness-of-Fit Diagnostics"),
            tableOutput(ns("table_model_diagnostics"))
          )
        ),
        nav_panel(
          title = tagList(icon("award"), " Evaluation & Metrics"),
          uiOutput(ns("threshold_alert")),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("table-cells-large"), " Visual Confusion Matrix Heatmap"), plotlyOutput(ns("plot_cm_heatmap"), height = "320px")),
            card(card_header(icon("calculator"), " Complete Classification Metrics"), tableOutput(ns("table_metrics_display")))
          ),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("chart-line"), " ROC Curve (Held-out Test Set)"), plotlyOutput(ns("plot_roc_curve"), height = "360px")),
            card(card_header(icon("bullseye"), " Probability Calibration Curve"), plotlyOutput(ns("plot_calibration_curve"), height = "360px"))
          ),
          card(card_header(icon("sliders"), " Performance Comparison Across Different Thresholds (0.1 to 0.9)"),
            tableOutput(ns("table_threshold_sweep"))
          )
        )
      )
    )
  )
}

module3InferentialServer <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    need_model <- function() {
      validate(need(!is.null(state$model), "A trained Logistic Regression model is required. Click 'Train Logistic Regression' in the sidebar."))
    }

    # Pre-training checklist (reactive)
    output$pretrain_checklist <- renderUI({
      has_data   <- !is.null(state$raw)
      has_target <- isTRUE(state$validation$ok_model)
      has_model  <- !is.null(state$model)
      n_rows     <- if (has_data) nrow(state$raw) else 0
      make_item <- function(ok, label) {
        col <- if (ok) "text-success" else "text-muted"
        ico <- if (ok) "circle-check" else "circle"
        div(class = paste("small d-flex align-items-center gap-2 mb-1", col),
          icon(ico, class = paste("fs-6", col)), span(label))
      }
      tagList(
        make_item(has_data,   sprintf("Dataset loaded (%s rows)", format(n_rows, big.mark = ","))),
        make_item(has_target, "Potability target column (0/1) present"),
        make_item(n_rows >= 100, "Sufficient sample size (>= 100 rows)"),
        make_item(has_model,  "Model previously trained")
      )
    })

    # Train button (re-label after first train)
    output$train_button_ui <- renderUI({
      if (is.null(state$model)) {
        actionButton(ns("train"), "Train Logistic Regression",
          class = "btn-success w-100 fw-bold mb-2", icon = icon("play"))
      } else {
        tagList(
          actionButton(ns("train"), "Re-Train Model (New Split)",
            class = "btn-outline-success w-100 fw-bold mb-1", icon = icon("rotate")),
          div(class = "small text-muted text-center mb-2", "Re-training resets all results with new split/seed.")
        )
      }
    })

    observeEvent(input$train, {
      if (is.null(state$raw)) {
        return(showNotification(NO_DATA_MSG, type = "error"))
      }
      if (!isTRUE(state$validation$ok_model)) {
        return(showNotification("Modeling disabled: Dataset needs valid Potability target column (0/1).", type = "error"))
      }
      t_start <- proc.time()["elapsed"]
      res <- tryCatch(
        withProgress(message = "Initializing ML Pipeline...", value = 0, {
          setProgress(0.10, message = "Step 1/6: Validating data schema & parameters...")
          Sys.sleep(0.3)
          setProgress(0.22, message = "Step 2/6: Stratified train/test split (seed-locked)...")
          Sys.sleep(0.3)
          setProgress(0.40, message = "Step 3/6: Fitting preprocessor on training fold (median imputation + Z-score)...")
          Sys.sleep(0.3)
          setProgress(0.58, message = "Step 4/6: Applying log1p transform (Solids) & Z-score standardization...")
          Sys.sleep(0.2)
          setProgress(0.72, message = "Step 5/6: Fitting Logistic Regression (GLM binomial, logit link)...")
          result <- train_logistic(state$raw, seed = input$seed, train_frac = input$frac, threshold = input$thr)
          setProgress(0.90, message = "Step 6/6: Evaluating on held-out test set (ROC, Calibration, Confusion Matrix)...")
          Sys.sleep(0.3)
          setProgress(1.00, message = "Complete!")
          result
        }),
        error = function(e) {
          showNotification(paste("Training failed:", conditionMessage(e)), type = "error", duration = 10)
          NULL
        }
      )
      if (!is.null(res)) {
        t_elapsed <- round(proc.time()["elapsed"] - t_start, 1)
        res$train_time <- t_elapsed
        state$model <- res
        showNotification(
          sprintf("Model trained in %.1fs | Test AUC: %.4f | Brier: %.4f | Pseudo-R\u00b2: %.4f",
                  t_elapsed, res$auc, res$brier, res$pseudo_r2),
          type = "message", duration = 8
        )
      }
    })

    observeEvent(input$thr, {
      m <- state$model
      if (!is.null(m)) {
        m$threshold <- input$thr
        state$model <- m
      }
    }, ignoreInit = TRUE)

    output$model_badge <- renderUI({
      if (is.null(state$model)) {
        div(class = "p-2 rounded border bg-warning-subtle text-center small",
          icon("circle-pause", class = "text-warning me-1"),
          span(class = "fw-bold", "No model trained yet"),
          div(class = "text-muted mt-1", "Configure parameters above and click Train.")
        )
      } else {
        m <- state$model
        elapsed_str <- if (!is.null(m$train_time)) sprintf("%.1fs", m$train_time) else "—"
        n_train  <- m$n_train; n_test <- m$n_test
        pct_min  <- round(100 * min(sum(m$classes_train==1), sum(m$classes_train==0)) / n_train, 1)
        bal_warn <- pct_min < 35

        div(class = "mt-1",
          div(class = "card border-success shadow-sm",
            div(class = "card-header bg-success text-white py-1 px-2 d-flex justify-content-between align-items-center",
              div(icon("circle-check"), span(class = "fw-bold ms-1 small", " Model Trained")),
              div(class = "small opacity-75", format(Sys.time(), "%H:%M:%S"))
            ),
            div(class = "card-body p-2",
              tags$table(class = "table table-sm table-borderless mb-0",
                tags$style(HTML(".table td { padding: 2px 4px; font-size: 0.78rem; }")),
                tags$tr(tags$td(class="text-muted","ROC-AUC"), tags$td(class="fw-bold text-success mono-num", sprintf("%.4f", m$auc))),
                tags$tr(tags$td(class="text-muted","Brier Score"), tags$td(class="mono-num", sprintf("%.4f", m$brier))),
                tags$tr(tags$td(class="text-muted","Pseudo R\u00b2"), tags$td(class="mono-num", sprintf("%.4f", m$pseudo_r2))),
                tags$tr(tags$td(class="text-muted","AIC"), tags$td(class="mono-num", sprintf("%.1f", m$aic))),
                tags$tr(tags$td(class="text-muted","Train N"), tags$td(class="mono-num", format(n_train, big.mark=","))),
                tags$tr(tags$td(class="text-muted","Test N"), tags$td(class="mono-num", format(n_test, big.mark=","))),
                tags$tr(tags$td(class="text-muted","Threshold"), tags$td(class="mono-num", sprintf("%.2f", m$threshold))),
                tags$tr(tags$td(class="text-muted","Train time"), tags$td(class="mono-num text-info", elapsed_str))
              ),
              if (bal_warn) {
                div(class = "alert alert-warning p-1 mt-1 mb-0 small",
                  icon("triangle-exclamation"), sprintf(" Minority class = %.1f%% — consider threshold tuning.", pct_min))
              }
            )
          )
        )
      }
    })

    # Hypothesis Testing
    output$table_ttests <- renderDT({
      need_target(state)
      datatable(safe_run(run_all_ttests(state$data), "Welch t-tests"), rownames = FALSE, options = list(pageLength = 9, scrollX = TRUE))
    })

    output$an_grp_ui <- renderUI({
      ch <- setdiff(c(TARGET, WQ_PARAMS), input$an_resp)
      selectInput(ns("an_grp"), "Grouping Variable:", ch, selected = if (TARGET %in% ch) TARGET else ch[1])
    })

    an_obj <- reactive({
      need_target(state)
      req(input$an_resp, input$an_grp, input$an_k)
      safe_run(run_anova(state$data, input$an_resp, input$an_grp, as.integer(input$an_k)), "ANOVA")
    })

    output$an_note <- renderText({ an_obj()$transformation })
    output$table_anova_result <- renderTable({ an_obj()$result })
    output$table_anova_groups <- renderTable({ an_obj()$groups })
    output$table_anova_diag <- renderTable({ an_obj()$diagnostics })
    output$plot_anova_qq <- renderPlotly({
      safe_run(ggplotly(plot_qq(an_obj()$resid, "Normal Q-Q (ANOVA Residuals)")), "ANOVA Q-Q Plot")
    })

    chi_obj <- reactive({
      need_target(state)
      req(input$chi_param)
      safe_run(run_chisq(state$data, input$chi_param, as.integer(input$an_k)), "Chi-Square Test")
    })

    output$table_chi_contingency <- renderTable({ chi_obj()$table }, rownames = TRUE)
    output$table_chi_result <- renderTable({ chi_obj()$result })

    # MLR
    mlr_obj <- reactive({
      need_valid(state)
      validate(need(length(input$mlr_preds) > 0, "Select at least one predictor."), need(input$mlr_resp != "", "Select response variable."))
      safe_run(fit_mlr(state$data, input$mlr_resp, input$mlr_preds), "Regression")
    })

    output$mlr_fit_summary <- renderUI({
      m <- mlr_obj()
      p(class = "mb-0",
        sprintf("Sample Size: n = %d complete observations. Multiple R² = %.4f, Adjusted R² = %.4f, Model F-statistic p-value = %.4g.",
          m$n, m$r2, m$adj_r2, m$f_p),
        if (!is.null(m$vif)) sprintf(" Multicollinearity Check: Max VIF = %.2f (values < 5 indicate absence of severe multicollinearity).", max(m$vif)) else ""
      )
    })

    output$table_mlr_coefs <- renderDT({
      datatable(mlr_obj()$coefs, rownames = FALSE, options = list(dom = "t")) |> formatSignif(2:7, 4)
    })

    output$plot_mlr_fitted <- renderPlotly({
      m <- mlr_obj()
      g <- ggplot(m$resid, aes(Fitted, Residual)) +
        geom_point(alpha = 0.5, colour = "#0284c7") +
        geom_hline(yintercept = 0, linetype = "dashed", colour = "#dc2626") +
        theme_ws() + labs(title = "Residuals vs Fitted Values")
      safe_run(ggplotly(g), "MLR Fitted Values Plot")
    })

    output$plot_mlr_qq <- renderPlotly({
      safe_run(ggplotly(plot_qq(mlr_obj()$resid, "Normal Q-Q of MLR Residuals")), "MLR Residuals Q-Q Plot")
    })

    output$plot_mlr_scale_loc <- renderPlotly({
      m <- mlr_obj()
      g <- ggplot(m$resid, aes(Fitted, SqrtAbsStd)) +
        geom_point(alpha = 0.5, colour = "#0d9488") +
        geom_smooth(se = FALSE, colour = "#0f172a", linewidth = 0.7, method = "loess", formula = y ~ x) +
        theme_ws() + labs(title = "Scale-Location (Homoscedasticity)", y = "sqrt(|Standardized Residuals|)")
      safe_run(ggplotly(g), "MLR Scale-Location Plot")
    })

    # PCA
    pca_obj <- reactive({
      need_valid(state)
      safe_run(run_pca(state$data), "PCA Analysis")
    })

    output$plot_pca_scree <- renderPlot({
      factoextra::fviz_eig(pca_obj()$res, addlabels = TRUE, barfill = "#0d9488", barcolor = "#0f766e") + theme_ws()
    })

    output$plot_pca_biplot <- renderPlot({
      p <- pca_obj()
      g <- droplevels(add_group(p$data)$Group)
      if (nlevels(g) > 1) {
        factoextra::fviz_pca_biplot(p$res, habillage = g, geom.ind = "point", label = "var", pointsize = 1.2, alpha.ind = 0.6, repel = TRUE, palette = unname(WS_COLORS[levels(g)])) + theme_ws()
      } else {
        factoextra::fviz_pca_biplot(p$res, geom.ind = "point", label = "var", repel = TRUE) + theme_ws()
      }
    })

    output$plot_pca_contrib <- renderPlot({
      factoextra::fviz_contrib(pca_obj()$res, choice = "var", axes = 1, fill = "#0284c7", color = "#0369a1") + theme_ws()
    })

    output$table_pca_eig <- renderDT({
      datatable(pca_eig_table(pca_obj()), rownames = FALSE, options = list(dom = "t"))
    })

    output$table_pca_loadings <- renderTable({ pca_loadings(pca_obj()) }, rownames = TRUE)
    output$table_pca_scores <- renderDT({
      datatable(pca_scores(pca_obj()), options = list(pageLength = 6, scrollX = TRUE))
    })

    # Logistic Regression
    output$model_pipeline_info <- renderUI({
      need_model()
      m <- state$model
      div(class = "p-3 mb-3 bg-light rounded border",
        h6(class = "fw-bold text-success", icon("check-double"), " Trained Model Specifications:"),
        tags$ul(class = "mb-0 small",
          tags$li(sprintf("Split: Seed %d | %d Training observations (%.0f%%) and %d Testing observations (held out).",
            m$seed, m$n_train, 100 * m$train_frac, m$n_test)),
          tags$li("Solids parameter log1p-transformed; all 9 parameters standardized (Z-Score)."),
          tags$li("Preprocessing strictly learned from the Training partition and applied consistently across Test and new sample assessments.")
        )
      )
    })

    output$text_formula <- renderText({
      need_model()
      state$model$formula
    })

    output$table_logistic_coefs <- renderDT({
      need_model()
      d <- state$model$coefs
      d$Effect_on_Odds <- ifelse(!d$Significant, "Not Significant (p >= 0.05)",
        ifelse(d$Odds_Ratio > 1, "Associated with Higher Potability Odds", "Associated with Lower Potability Odds"))
      d$Effect_on_Odds[d$Term == "(Intercept)"] <- "Baseline Constant"
      datatable(d, rownames = FALSE, options = list(dom = "t", scrollX = TRUE)) |>
        formatSignif(c("Estimate", "Std_Error", "z", "p_value", "CI_low", "CI_high", "Odds_Ratio", "OR_low", "OR_high"), 4)
    })

    output$odds_ratio_explanation <- renderUI({
      need_model()
      p(class = "small text-muted mt-2",
        "Interpretation: An Odds Ratio (OR) > 1 indicates increased probability of potability per +1 SD increase in the parameter, whereas OR < 1 indicates reduced odds. CIs are 95% Wald intervals.")
    })

    output$plot_forest_odds <- renderPlotly({
      need_model()
      safe_run(ggplotly(plot_odds_ratios(state$model$coefs)), "Odds Ratios Forest Plot")
    })

    output$table_model_diagnostics <- renderTable({
      need_model()
      m <- state$model
      vif_rows <- if (!is.null(m$vif) && length(m$vif) > 0) {
        data.frame(Metric = paste("VIF:", names(m$vif)), Value = as.character(round(unname(m$vif), 3)))
      } else {
        data.frame(Metric = "Multicollinearity (VIF)", Value = "Not applicable / No severe multicollinearity")
      }
      rbind(
        data.frame(Metric = "McFadden Pseudo R²", Value = as.character(round(m$pseudo_r2, 4))),
        data.frame(Metric = "Akaike Information Criterion (AIC)", Value = as.character(round(m$aic, 2))),
        vif_rows
      )
    })

    # Evaluation
    ev_obj <- reactive({
      need_model()
      m <- state$model
      classification_metrics(m$y_test, m$p_test, input$thr)
    })

    output$threshold_alert <- renderUI({
      need_model()
      div(class = "alert alert-secondary py-2 small d-flex align-items-center mb-3",
        icon("sliders", class = "fs-5 me-2 text-primary"),
        div(
          strong("Active Threshold: ", sprintf("%.2f. ", input$thr)),
          "Adjusting the threshold dynamically updates the Confusion Matrix and metrics below. A lower threshold prioritizes sensitivity (capturing more potable water), while a higher threshold prioritizes specificity (minimizing false potability classification)."
        )
      )
    })

    output$plot_cm_heatmap <- renderPlotly({
      need_model()
      safe_run(ggplotly(plot_confusion_matrix(ev_obj()$counts)), "Confusion Matrix Plot")
    })

    output$table_metrics_display <- renderTable({
      need_model()
      t <- ev_obj()$table
      m <- state$model
      data.frame(
        Metric = c(t$Metric, "ROC-AUC Score", "Brier Score (Mean Squared Error)"),
        Value = c(as.character(t$Value), as.character(round(m$auc, 4)), as.character(round(m$brier, 4)))
      )
    })

    output$plot_roc_curve <- renderPlotly({
      need_model()
      safe_run(ggplotly(plot_roc(state$model$roc, state$model$auc)), "ROC Curve")
    })

    output$plot_calibration_curve <- renderPlotly({
      need_model()
      m <- state$model
      validate(need(!is.null(m$calibration), "Calibration plot unavailable (predictions too clustered)."))
      safe_run(ggplotly(plot_calibration(m$calibration)), "Calibration Curve")
    })

    output$table_threshold_sweep <- renderTable({
      need_model()
      m <- state$model
      threshold_table(m$y_test, m$p_test)
    })

    # Downloads
    output$dl_model_sum <- downloadHandler(
      filename = function() paste0("waterstat_model_summary_", Sys.Date(), ".csv"),
      content = function(file) {
        m <- state$model
        if (is.null(m)) return(writeLines("No model trained yet.", file))
        sec <- list(
          Model_Metadata = data.frame(
            Item = c("Formula", "Seed", "Train_Fraction", "Train_N", "Test_N", "Test_AUC", "Brier_Score", "Threshold", "Pseudo_R2", "AIC"),
            Value = c(m$formula, m$seed, m$train_frac, m$n_train, m$n_test, round(m$auc, 4), round(m$brier, 4), m$threshold, round(m$pseudo_r2, 4), round(m$aic, 2))
          ),
          Coefficients = m$coefs,
          VIF = if (!is.null(m$vif) && length(m$vif) > 0) data.frame(Predictor = names(m$vif), VIF = round(unname(m$vif), 3)) else data.frame(Note = "VIF not applicable")
        )
        write_sections(file, sec)
      }
    )

    output$dl_eval_metrics <- downloadHandler(
      filename = function() paste0("waterstat_evaluation_metrics_", Sys.Date(), ".csv"),
      content = function(file) {
        m <- state$model
        if (is.null(m)) return(writeLines("No model trained yet.", file))
        e <- classification_metrics(m$y_test, m$p_test, m$threshold)
        sec <- list(
          Metrics = rbind(data.frame(Metric = "Threshold", Value = m$threshold), e$table, data.frame(Metric = c("AUC", "Brier"), Value = round(c(m$auc, m$brier), 4))),
          Confusion_Counts = data.frame(Type = names(e$counts), Count = as.integer(e$counts)),
          Threshold_Comparison = threshold_table(m$y_test, m$p_test)
        )
        write_sections(file, sec)
      }
    )
  })
}

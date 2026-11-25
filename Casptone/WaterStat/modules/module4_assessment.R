# Module 4 – Interactive R Shiny Application & Potability Assessment
# Serves as the interactive operational dashboard for batch dataset potability scoring,
# single-sample custom water laboratory assessment, analytics dashboard, and export.

module4AssessmentUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(class = "module-header mb-3 p-3 bg-white rounded shadow-sm border-start border-4 border-primary",
      div(class = "d-flex justify-content-between align-items-center flex-wrap gap-2",
        div(
          h4(class = "mb-1 fw-bold text-dark", icon("flask-vial", class = "text-primary me-2"), "Module 4: Laboratory Decision-Support & Potability Assessment"),
          p(class = "text-muted mb-0 small",
            "Real-time operational dashboard for custom single-sample laboratory water testing, batch dataset scoring, comprehensive analytics, and regulatory export.")
        ),
        span(class = "badge bg-primary-subtle text-primary fw-bold px-3 py-2 border", icon("shield-halved"), " Laboratory Grade")
      )
    ),
    navset_card_tab(
      id = ns("tabs"),

      # ── Tab 1: Custom Sample Assessment ─────────────────────────────────────
      nav_panel(
        title = tagList(icon("flask-vial"), " Custom Water Sample Assessment"),
        layout_sidebar(
          fillable = FALSE,
          sidebar = sidebar(width = 320,
            h6(class = "fw-bold text-dark", icon("vial"), " Enter Water Sample Parameters"),
            p(class = "small text-muted mb-2", "Input measured values for all 9 physicochemical parameters:"),
            div(class = "d-flex gap-1 mb-3",
              actionButton(ns("btn_preset_potable"),    "Preset Potable",     class = "btn-outline-success btn-sm"),
              actionButton(ns("btn_preset_nonpotable"), "Preset Non-Potable", class = "btn-outline-danger btn-sm"),
              actionButton(ns("btn_clear"),             "Reset",              class = "btn-outline-secondary btn-sm")
            ),
            numericInput(ns("pH"),              "pH (0.0 - 14.0):",          value = 7.08,  min = 0, max = 14, step = 0.1),
            numericInput(ns("Hardness"),        "Hardness (mg/L):",           value = 196.3, min = 0, step = 1),
            numericInput(ns("Solids"),          "Solids / TDS (ppm):",        value = 21481, min = 0, step = 100),
            numericInput(ns("Chloramines"),     "Chloramines (ppm):",         value = 7.12,  min = 0, step = 0.1),
            numericInput(ns("Sulfate"),         "Sulfate (mg/L):",            value = 333.7, min = 0, step = 5),
            numericInput(ns("Conductivity"),    "Conductivity (\u03bcS/cm):", value = 426.2, min = 0, step = 10),
            numericInput(ns("Organic_carbon"),  "Organic Carbon (ppm):",      value = 14.28, min = 0, step = 0.5),
            numericInput(ns("Trihalomethanes"), "Trihalomethanes (\u03bcg/L):",value = 66.39, min = 0, step = 1),
            numericInput(ns("Turbidity"),       "Turbidity (NTU):",           value = 3.96,  min = 0, step = 0.1),
            actionButton(ns("btn_assess"), "Assess Water Sample", class = "btn-primary w-100 fw-bold mt-2", icon = icon("magnifying-glass-chart"))
          ),
          uiOutput(ns("custom_sample_output"))
        )
      ),

      # ── Tab 2: Batch Dataset Assessment ─────────────────────────────────────
      nav_panel(
        title = tagList(icon("table-list"), " Batch Dataset Assessment"),
        uiOutput(ns("batch_assessment_ui"))
      ),

      # ── Tab 3: Analytics Dashboard ───────────────────────────────────────────
      nav_panel(
        title = tagList(icon("chart-line"), " Analytics Dashboard"),
        uiOutput(ns("dashboard_ui"))
      ),

      # ── Tab 4: Export & Report Center ───────────────────────────────────────
      nav_panel(
        title = tagList(icon("file-export"), " Export & Report Center"),
        div(class = "p-3",
          h5(class = "fw-bold text-dark mb-3", icon("download"), " Downloadable Analysis Artifacts"),
          p(class = "text-muted", "Export validated tables, model performance statistics, and predictions as multi-section CSV files for reporting and academic presentations:"),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("file-csv"), " Statistical Analysis Results"),
              p(class = "small text-muted", "Contains descriptive statistics, Pearson/Spearman correlation matrices, group statistics, and Welch t-test results."),
              downloadButton(ns("dl_all_stats"), "Download Statistical Analysis CSV", class = "btn-primary btn-sm")
            ),
            card(card_header(icon("file-waveform"), " Batch Assessment Predictions"),
              p(class = "small text-muted", "Contains validation summary, class distribution, invalid values audit, and model predictions for all dataset rows."),
              downloadButton(ns("dl_all_preds"), "Download Batch Assessment CSV", class = "btn-info btn-sm text-white")
            )
          ),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("brain"), " Model Specification & Coefficients"),
              p(class = "small text-muted", "Contains logistic regression formula, seed, training/testing observations, pseudo-R\u00b2, AIC, coefficients, and odds ratios."),
              downloadButton(ns("dl_all_model"), "Download Model Specifications CSV", class = "btn-success btn-sm")
            ),
            card(card_header(icon("award"), " Model Evaluation & Calibration"),
              p(class = "small text-muted", "Contains confusion matrix counts, accuracy, precision, recall, specificity, F1-score, AUC, Brier score, and threshold sweeps."),
              downloadButton(ns("dl_all_eval"), "Download Evaluation Metrics CSV", class = "btn-secondary btn-sm")
            )
          )
        )
      )
    )
  )
}

module4AssessmentServer <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # ── Presets ───────────────────────────────────────────────────────────────
    observeEvent(input$btn_preset_potable, {
      updateNumericInput(session, "pH",              value = 7.2)
      updateNumericInput(session, "Hardness",        value = 200)
      updateNumericInput(session, "Solids",          value = 18000)
      updateNumericInput(session, "Chloramines",     value = 7.0)
      updateNumericInput(session, "Sulfate",         value = 330)
      updateNumericInput(session, "Conductivity",    value = 400)
      updateNumericInput(session, "Organic_carbon",  value = 13.0)
      updateNumericInput(session, "Trihalomethanes", value = 60.0)
      updateNumericInput(session, "Turbidity",       value = 3.5)
    })

    observeEvent(input$btn_preset_nonpotable, {
      updateNumericInput(session, "pH",              value = 4.5)
      updateNumericInput(session, "Hardness",        value = 280)
      updateNumericInput(session, "Solids",          value = 38000)
      updateNumericInput(session, "Chloramines",     value = 11.5)
      updateNumericInput(session, "Sulfate",         value = 460)
      updateNumericInput(session, "Conductivity",    value = 620)
      updateNumericInput(session, "Organic_carbon",  value = 22.0)
      updateNumericInput(session, "Trihalomethanes", value = 98.0)
      updateNumericInput(session, "Turbidity",       value = 6.2)
    })

    observeEvent(input$btn_clear, {
      for (p in WQ_PARAMS) updateNumericInput(session, p, value = NA)
    })

    # ── Custom Sample Assessment ──────────────────────────────────────────────
    sample_result <- eventReactive(input$btn_assess, {
      if (is.null(state$model)) {
        return(list(error = "A trained Logistic Regression model is required before assessing custom water samples. Please train a model in Module 3 first."))
      }
      vals <- vapply(WQ_PARAMS, function(p) {
        v <- input[[p]]
        if (is.null(v) || length(v) == 0 || is.na(v)) NA_real_ else as.numeric(v)
      }, numeric(1))

      errs <- character()
      if (anyNA(vals)) {
        errs <- c(errs, paste("Missing values in parameter(s):", paste(WQ_PARAMS[is.na(vals)], collapse = ", ")))
      } else {
        if (any(vals < 0)) errs <- c(errs, paste("Negative values are physically impossible:", paste(WQ_PARAMS[vals < 0], collapse = ", ")))
        if (vals["pH"] > 14) errs <- c(errs, "pH value must be strictly between 0 and 14.")
      }
      if (length(errs)) return(list(error = errs))

      tryCatch(
        c(list(values = vals), predict_sample(state$model, vals)),
        error = function(e) list(error = paste("Prediction evaluation failed:", conditionMessage(e)))
      )
    })

    output$custom_sample_output <- renderUI({
      if (is.null(state$model)) {
        return(div(class = "alert alert-warning p-4 m-3 text-center",
          icon("triangle-exclamation", class = "fs-2 text-warning mb-2"),
          h5("Model Not Yet Trained"),
          p("To assess custom water samples, please navigate to Module 3 (Inferential Analysis & Modeling) and train the Logistic Regression model using an uploaded dataset.")
        ))
      }
      if (input$btn_assess == 0) {
        return(div(class = "p-4 text-center text-muted",
          icon("hand-pointer", class = "fs-3 text-secondary mb-2"),
          h6("Ready for Laboratory Sample Evaluation"),
          p("Input measured physicochemical values in the sidebar (or select a preset) and click 'Assess Water Sample'.")
        ))
      }
      res <- sample_result()
      if (!is.null(res$error)) {
        return(div(class = "alert alert-danger m-3",
          strong(icon("circle-xmark"), " Evaluation Error:"),
          lapply(res$error, p)
        ))
      }
      m          <- state$model
      prob_pct   <- round(100 * res$prob, 1)
      is_potable <- res$class == "Potable"
      badge_theme <- if (is_potable) "success" else "danger"
      badge_icon  <- if (is_potable) "circle-check" else "triangle-exclamation"
      fill_class  <- if (is_potable) "fill-potable" else "fill-nonpotable"
      status_badge <- if (is_potable) {
        span(class = "ws-badge-potable",  icon("circle-check"),          " CERTIFIED POTABLE (FIT FOR CONSUMPTION)")
      } else {
        span(class = "ws-badge-nonpotable", icon("triangle-exclamation"), " HAZARDOUS / NON-POTABLE (UNSAFE)")
      }

      tagList(
        div(class = "ws-lab-console",
          div(class = "ws-cert-header",
            div(
              div(class = "d-flex align-items-center gap-2",
                span(class = "badge bg-dark text-white px-2 py-1", icon("microscope"), " WaterStat Lab Console"),
                span(class = "ws-cert-id", paste0("SAMPLE-REF: #WS-", format(Sys.time(), "%y%m%d"), "-", round(runif(1, 1000, 9999))))
              ),
              h5(class = "fw-bold text-dark mt-2 mb-0", "Water Sample Laboratory Diagnostic Report")
            ),
            div(class = "text-end",
              status_badge,
              div(class = "small text-muted mt-1", paste("Evaluated at:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))
            )
          ),
          div(class = "ws-meter-wrapper",
            div(class = "ws-meter-label-row",
              span(class = "fw-bold text-dark", icon("gauge-high", class = "text-primary me-1"), " Model Predicted Potability Index:"),
              span(class = "mono-num fw-bold fs-5", sprintf("%.1f%%", prob_pct))
            ),
            div(class = "ws-meter-bar-track",
              div(class = paste("ws-meter-bar-fill", fill_class),
                  style = sprintf("width: %d%%;", max(5, min(100, round(prob_pct)))),
                  sprintf("%.1f%%", prob_pct))
            ),
            div(class = "ws-meter-ticks",
              span("0% (High Contamination Hazard)"),
              span("Threshold 50%"),
              span("100% (Certified Potable)")
            )
          ),
          if (length(res$outside)) {
            div(class = "alert alert-warning p-2 small mb-3 border-start border-4 border-warning",
              icon("triangle-exclamation", class = "me-2"),
              strong("Out-of-Range Parameter Warning: "),
              paste(res$outside, collapse = ", "),
              " exceed observed historical training data. Prediction in these zones constitutes statistical extrapolation."
            )
          },
          layout_columns(
            col_widths = c(4, 4, 4),
            value_box("Potability Probability", sprintf("%.1f%%", prob_pct),
              showcase = icon("percent"),  theme = if (prob_pct >= 50) "success" else "danger"),
            value_box(sprintf("Decision (Threshold %.2f)", m$threshold), res$class,
              showcase = icon(badge_icon), theme = badge_theme),
            value_box("Standardization Model",  sprintf("Logit (AUC %.3f)", m$auc),
              showcase = icon("brain"),    theme = "primary")
          )
        ),
        card(
          card_header(icon("certificate", class = "text-primary me-2"), " WHO Drinking Water Guidelines (2022) Permissible Compliance Audit"),
          p(class = "small text-muted px-3 pt-2 mb-1", "Compares entered physical and chemical levels against international World Health Organization safe drinking limits:"),
          div(class = "table-responsive p-2", tableOutput(session$ns("custom_who_tab")))
        ),
        layout_columns(
          col_widths = c(6, 6),
          card(
            card_header(icon("scale-balanced", class = "text-info me-2"), " Explainable AI: Chemical Contributions to Log-Odds"),
            p(class = "small text-muted px-3 pt-2 mb-1", "Mathematical decomposition (Beta * Z). Positive increases safety (+odds); Negative increases contamination risk (-odds)."),
            div(class = "table-responsive p-2", tableOutput(session$ns("custom_contrib_tab")))
          ),
          card(
            card_header(icon("list-check", class = "text-success me-2"), " Standardized Z-Scores & Empirical Training Bounds"),
            p(class = "small text-muted px-3 pt-2 mb-1", "Evaluates whether input parameters lie safely within empirical min-max training domain:"),
            div(class = "table-responsive p-2", tableOutput(session$ns("custom_input_tab")))
          )
        )
      )
    })

    output$custom_who_tab <- renderTable({
      r <- sample_result(); req(is.null(r$error)); v <- r$values
      data.frame(
        Parameter = c("pH","Hardness","Solids (TDS)","Chloramines","Sulfate","Conductivity","Organic Carbon","Trihalomethanes","Turbidity"),
        Sample_Value = c(
          sprintf("%.2f", v["pH"]), sprintf("%.1f mg/L", v["Hardness"]),
          sprintf("%.0f ppm", v["Solids"]), sprintf("%.2f ppm", v["Chloramines"]),
          sprintf("%.1f mg/L", v["Sulfate"]), sprintf("%.1f uS/cm", v["Conductivity"]),
          sprintf("%.2f ppm", v["Organic_carbon"]), sprintf("%.2f ug/L", v["Trihalomethanes"]),
          sprintf("%.2f NTU", v["Turbidity"])),
        WHO_Guideline_Threshold = c("6.5 - 8.5","<= 200 mg/L","<= 1,000 ppm","<= 4.0 ppm","<= 250 mg/L","<= 400 uS/cm","<= 10.0 ppm","<= 80 ug/L","<= 5.0 NTU"),
        WHO_Regulatory_Status = c(
          if (v["pH"] >= 6.5 && v["pH"] <= 8.5) "PASS (Safe Range)" else "FAIL (Acidic/Alkaline)",
          if (v["Hardness"] <= 200) "PASS (Acceptable)" else "CAUTION (High Hardness)",
          if (v["Solids"] <= 1000) "PASS (Desirable)" else if (v["Solids"] <= 2000) "CAUTION (Elevated TDS)" else "FAIL (Exceeds TDS Limit)",
          if (v["Chloramines"] <= 4.0) "PASS (Safe Disinfection)" else "FAIL (Exceeds 4 ppm Limit)",
          if (v["Sulfate"] <= 250) "PASS (Acceptable)" else "CAUTION (High Sulfate)",
          if (v["Conductivity"] <= 400) "PASS (Acceptable)" else "CAUTION (High Conductivity)",
          if (v["Organic_carbon"] <= 10.0) "PASS (Acceptable)" else "FAIL (Elevated TOC)",
          if (v["Trihalomethanes"] <= 80) "PASS (Safe DBPs)" else "FAIL (Exceeds 80 ug/L)",
          if (v["Turbidity"] <= 5.0) "PASS (Clear)" else "FAIL (Exceeds 5 NTU)")
      )
    })

    output$custom_input_tab <- renderTable({
      r <- sample_result(); req(is.null(r$error)); m <- state$model
      in_bounds <- vapply(WQ_PARAMS, function(p) {
        val <- r$values[p]
        mn <- m$pp$ranges["min", p]; mx <- m$pp$ranges["max", p]
        if (val >= mn && val <= mx) "Within Domain (OK)" else "Extrapolation (Warning)"
      }, character(1))
      data.frame(Parameter = WQ_PARAMS, Input_Value = round(r$values[WQ_PARAMS], 2),
        Standardized_Z = round(unlist(r$z[1, WQ_PARAMS]), 3),
        Training_Min = round(m$pp$ranges["min", WQ_PARAMS], 2),
        Training_Max = round(m$pp$ranges["max", WQ_PARAMS], 2),
        Domain_Status = in_bounds)
    })

    output$custom_contrib_tab <- renderTable({
      r <- sample_result(); req(is.null(r$error))
      c_vals <- unname(r$contrib)
      data.frame(Parameter = names(r$contrib), LogOdds_Weight = round(c_vals, 4),
        Impact_Direction = ifelse(c_vals >= 0, "+ Increases Safety (Potable)", "- Increases Hazard (Unsafe)"))
    })

    # ── Batch Assessment ──────────────────────────────────────────────────────
    batch_preds <- reactive({
      need_valid(state)
      validate(need(!is.null(state$model), "A trained Logistic Regression model is required. Please train one in Module 3 first."))
      safe_run(predict_dataset(state$model, state$raw), "Batch Assessment")
    })

    output$batch_assessment_ui <- renderUI({
      need_valid(state)
      validate(need(!is.null(state$model), "A trained Logistic Regression model is required. Train a model in Module 3 first."))
      p_df <- batch_preds(); m <- state$model
      tagList(
        div(class = "alert alert-secondary py-2 small mb-3",
          icon("info-circle"),
          sprintf(" Evaluated %d observations from dataset: %s using active model (Threshold = %.2f, Test AUC = %.3f).",
            nrow(p_df), state$source, m$threshold, m$auc)
        ),
        layout_columns(
          col_widths = c(4, 8),
          card(card_header(icon("chart-pie"), " Classification Breakdown"),
            tableOutput(ns("batch_counts")),
            p(class = "small text-muted mt-2", "Count of samples classified as Potable vs Non-potable at current decision threshold.")
          ),
          card(card_header(icon("chart-area"), " Distribution of Predicted Potability Probabilities"),
            plotlyOutput(ns("batch_prob_hist"), height = "260px")
          )
        ),
        card(card_header(icon("table"), " Batch Predictions Records"), DTOutput(ns("batch_table")))
      )
    })

    output$batch_counts <- renderTable({
      as.data.frame(table(Model_Classification = batch_preds()$Model_Classification))
    })

    output$batch_prob_hist <- renderPlotly({
      df <- batch_preds()
      g <- ggplot(df, aes(Predicted_Probability, fill = Model_Classification)) +
        geom_histogram(bins = 30, alpha = 0.75, colour = "white", linewidth = 0.3) +
        scale_fill_manual(values = c("Non-potable" = "#dc2626", "Potable" = "#0d9488")) +
        geom_vline(xintercept = state$model$threshold, linetype = "dashed", colour = "#0f172a", linewidth = 0.8) +
        labs(x = "Predicted Probability of Potability", y = "Sample Count", fill = "Classification") +
        theme_ws()
      safe_run(ggplotly(g), "Batch Probability Distribution Plot")
    })

    output$batch_table <- renderDT({
      datatable(batch_preds(), rownames = FALSE, filter = "top",
        options = list(pageLength = 10, scrollX = TRUE)) |> formatRound("Predicted_Probability", 4)
    })

    # ── Analytics Dashboard ───────────────────────────────────────────────────
    dash_data <- reactive({
      need_valid(state)
      validate(need(!is.null(state$model), "Train the Logistic Regression model in Module 3 to unlock the Analytics Dashboard."))
      preds <- safe_run(predict_dataset(state$model, state$raw), "Dashboard predictions")
      cbind(state$raw, preds)
    })

    output$dashboard_ui <- renderUI({
      need_valid(state)
      validate(need(!is.null(state$model), "Train the model in Module 3 first to view the Analytics Dashboard."))

      df <- dash_data()
      m  <- state$model
      n_total    <- nrow(df)
      n_potable  <- sum(df$Model_Classification == "Potable",     na.rm = TRUE)
      n_nonpot   <- sum(df$Model_Classification == "Non-potable", na.rm = TRUE)

      tagList(
        # ── KPI Row ──────────────────────────────────────────────────────────
        div(class = "p-3 pb-0",
          h5(class = "fw-bold text-dark mb-3", icon("gauge-high", class = "text-primary me-2"), " Analytics Dashboard — Model & Data Intelligence"),
          layout_columns(
            col_widths = c(3, 3, 3, 3),
            value_box("Total Records Scored",   format(n_total,   big.mark = ","),
              showcase = icon("database"),    theme = "primary"),
            value_box("Classified Potable",     format(n_potable, big.mark = ","),
              showcase = icon("circle-check"), theme = "success"),
            value_box("Classified Non-Potable", format(n_nonpot,  big.mark = ","),
              showcase = icon("triangle-exclamation"), theme = "danger"),
            value_box("Model ROC-AUC",          sprintf("%.4f", m$auc),
              showcase = icon("chart-line"), theme = "info")
          )
        ),

        # ── Row 1: Pie + Prob Histogram ───────────────────────────────────────
        div(class = "p-3 pt-2",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("chart-pie"), " CLASSIFICATION OVERVIEW"),
          layout_columns(
            col_widths = c(4, 8),
            card(card_header(icon("circle-half-stroke"), " Potability Split (Predicted)"),
              plotlyOutput(ns("dash_pie"), height = "280px")),
            card(card_header(icon("chart-area"), " Predicted Probability Distribution by Class"),
              plotlyOutput(ns("dash_prob_hist"), height = "280px"))
          )
        ),

        # ── Row 2: pH, Hardness, Solids ───────────────────────────────────────
        div(class = "p-3 pt-0",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("vial"), " PARAMETER DISTRIBUTIONS BY PREDICTED CLASS (Group 1: Physical Parameters)"),
          layout_columns(
            col_widths = c(4, 4, 4),
            card(card_header("pH Distribution"),           plotlyOutput(ns("dash_hist_ph"),       height = "240px")),
            card(card_header("Hardness Distribution"),     plotlyOutput(ns("dash_hist_hard"),     height = "240px")),
            card(card_header("Solids (TDS) Distribution"), plotlyOutput(ns("dash_hist_solids"),   height = "240px"))
          )
        ),

        # ── Row 3: Chloramines, Sulfate, Conductivity ─────────────────────────
        div(class = "p-3 pt-0",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("flask"), " PARAMETER DISTRIBUTIONS BY PREDICTED CLASS (Group 2: Chemical Disinfection)"),
          layout_columns(
            col_widths = c(4, 4, 4),
            card(card_header("Chloramines Distribution"),  plotlyOutput(ns("dash_hist_chlor"),    height = "240px")),
            card(card_header("Sulfate Distribution"),      plotlyOutput(ns("dash_hist_sulf"),     height = "240px")),
            card(card_header("Conductivity Distribution"), plotlyOutput(ns("dash_hist_cond"),     height = "240px"))
          )
        ),

        # ── Row 4: OC, THMs, Turbidity ────────────────────────────────────────
        div(class = "p-3 pt-0",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("droplet"), " PARAMETER DISTRIBUTIONS BY PREDICTED CLASS (Group 3: Organic & Turbidity)"),
          layout_columns(
            col_widths = c(4, 4, 4),
            card(card_header("Organic Carbon Distribution"),     plotlyOutput(ns("dash_hist_oc"),   height = "240px")),
            card(card_header("Trihalomethanes Distribution"),    plotlyOutput(ns("dash_hist_thm"),  height = "240px")),
            card(card_header("Turbidity Distribution"),          plotlyOutput(ns("dash_hist_turb"), height = "240px"))
          )
        ),

        # ── Row 5: Boxplots by class ──────────────────────────────────────────
        div(class = "p-3 pt-0",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("box-open"), " PARAMETER BOXPLOTS BY PREDICTED CLASS"),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("chart-simple"), " pH & Hardness — Boxplots by Classification"),
              plotlyOutput(ns("dash_box_ph_hard"), height = "280px")),
            card(card_header(icon("chart-simple"), " Chloramines & Turbidity — Boxplots by Classification"),
              plotlyOutput(ns("dash_box_chlor_turb"), height = "280px"))
          )
        ),

        # ── Row 6: Scatter plots ──────────────────────────────────────────────
        div(class = "p-3 pt-0",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("chart-line"), " PARAMETER SCATTER PLOTS (Coloured by Predicted Class)"),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("expand"), " pH vs Turbidity"),
              plotlyOutput(ns("dash_scatter_ph_turb"),  height = "280px")),
            card(card_header(icon("expand"), " Chloramines vs Sulfate"),
              plotlyOutput(ns("dash_scatter_chl_sulf"), height = "280px"))
          )
        ),

        # ── Row 7: Prob by actual Potability + Threshold performance ──────────
        div(class = "p-3 pt-0",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("bullseye"), " MODEL DISCRIMINATION & THRESHOLD PERFORMANCE"),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("chart-area"), " Predicted Probability by Actual Potability (Violin)"),
              plotlyOutput(ns("dash_violin_prob"),  height = "300px")),
            card(card_header(icon("sliders"), " Accuracy / Sensitivity / Specificity vs Threshold"),
              plotlyOutput(ns("dash_threshold"),    height = "300px"))
          )
        ),

        # ── Row 8: ROC + Calibration ──────────────────────────────────────────
        div(class = "p-3 pt-0",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("stethoscope"), " ROC CURVE & CALIBRATION"),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("chart-area"), " ROC Curve (Test Set)"),
              plotlyOutput(ns("dash_roc"),         height = "300px")),
            card(card_header(icon("chart-line"), " Calibration Curve (Reliability Diagram)"),
              plotlyOutput(ns("dash_calibration"), height = "300px"))
          )
        ),

        # ── Row 9: Odds Ratio Forest Plot ─────────────────────────────────────
        div(class = "p-3 pt-0",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("ranking-star"), " ODDS RATIO FOREST PLOT"),
          card(card_header(icon("chart-simple"), " Parameter Odds Ratios with 95% Wald Confidence Intervals"),
            plotlyOutput(ns("dash_forest"), height = "360px"))
        ),

        # ── Row 10: Confusion Matrix + Class Balance ───────────────────────────
        div(class = "p-3 pt-0",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("table"), " CONFUSION MATRIX & CLASS BALANCE"),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("table-cells"), " Confusion Matrix Heatmap (Test Set)"),
              plotlyOutput(ns("dash_cm"),           height = "300px")),
            card(card_header(icon("scale-balanced"), " Train vs Test Class Balance Comparison"),
              plotlyOutput(ns("dash_class_balance"), height = "300px"))
          )
        ),

        # ── Row 11: Correlation Heatmap ───────────────────────────────────────
        div(class = "p-3 pt-0",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("network-wired"), " CORRELATION HEATMAP (PEARSON, ALL 9 PARAMETERS)"),
          card(card_header(icon("table-cells"), " Parameter Correlation Matrix"),
            plotlyOutput(ns("dash_heatmap"), height = "400px"))
        ),

        # ── Row 12: Mean comparison by actual potability ───────────────────────
        div(class = "p-3 pt-0",
          h6(class = "text-muted fw-bold mb-2 border-bottom pb-1", icon("chart-bar"), " PARAMETER MEANS BY ACTUAL POTABILITY (BAR CHART)"),
          card(card_header(icon("chart-column"), " Mean Water Quality Parameters: Potable vs Non-Potable"),
            plotlyOutput(ns("dash_means_bar"), height = "360px"))
        )
      )
    })

    # Helper to build per-parameter histogram
    make_param_hist <- function(df, param, label) {
      g <- ggplot(df, aes(x = .data[[param]], fill = Model_Classification)) +
        geom_histogram(bins = 25, alpha = 0.72, colour = "white", linewidth = 0.2, position = "identity") +
        scale_fill_manual(values = c("Non-potable" = "#dc2626", "Potable" = "#0d9488")) +
        labs(x = label, y = "Count", fill = NULL) +
        theme_ws() + theme(legend.position = "bottom")
      ggplotly(g) |> layout(legend = list(orientation = "h", y = -0.25))
    }

    output$dash_pie <- renderPlotly({
      df <- dash_data()
      cnts <- table(df$Model_Classification)
      df_pie <- data.frame(Classification = names(cnts), Count = as.integer(cnts))
      plot_ly(data = df_pie, labels = ~Classification, values = ~Count, type = "pie",
        marker = list(colors = c("#dc2626", "#0d9488"),
                      line   = list(color = "#ffffff", width = 2)),
        textinfo = "label+percent", hole = 0.42) |>
        layout(showlegend = TRUE,
               margin = list(t = 10, b = 10, l = 10, r = 10))
    })

    output$dash_prob_hist <- renderPlotly({
      safe_run(ggplotly(
        ggplot(dash_data(), aes(Predicted_Probability, fill = Model_Classification)) +
          geom_histogram(bins = 40, alpha = 0.75, colour = "white", linewidth = 0.2) +
          scale_fill_manual(values = c("Non-potable" = "#dc2626", "Potable" = "#0d9488")) +
          geom_vline(xintercept = state$model$threshold, linetype = "dashed", colour = "#0f172a", linewidth = 0.9) +
          labs(x = "Predicted Probability", y = "Count", fill = NULL) + theme_ws()
      ), "Dashboard Probability Histogram")
    })

    output$dash_hist_ph      <- renderPlotly({ safe_run(make_param_hist(dash_data(), "pH",              "pH"),                       "pH Histogram") })
    output$dash_hist_hard    <- renderPlotly({ safe_run(make_param_hist(dash_data(), "Hardness",        "Hardness (mg/L)"),           "Hardness Histogram") })
    output$dash_hist_solids  <- renderPlotly({ safe_run(make_param_hist(dash_data(), "Solids",          "Solids TDS (ppm)"),          "Solids Histogram") })
    output$dash_hist_chlor   <- renderPlotly({ safe_run(make_param_hist(dash_data(), "Chloramines",     "Chloramines (ppm)"),         "Chloramines Histogram") })
    output$dash_hist_sulf    <- renderPlotly({ safe_run(make_param_hist(dash_data(), "Sulfate",         "Sulfate (mg/L)"),            "Sulfate Histogram") })
    output$dash_hist_cond    <- renderPlotly({ safe_run(make_param_hist(dash_data(), "Conductivity",    "Conductivity (\u03bcS/cm)"), "Conductivity Histogram") })
    output$dash_hist_oc      <- renderPlotly({ safe_run(make_param_hist(dash_data(), "Organic_carbon",  "Organic Carbon (ppm)"),      "OC Histogram") })
    output$dash_hist_thm     <- renderPlotly({ safe_run(make_param_hist(dash_data(), "Trihalomethanes", "Trihalomethanes (\u03bcg/L)"),"THM Histogram") })
    output$dash_hist_turb    <- renderPlotly({ safe_run(make_param_hist(dash_data(), "Turbidity",       "Turbidity (NTU)"),           "Turbidity Histogram") })

    output$dash_box_ph_hard <- renderPlotly({
      df <- dash_data()
      df_long <- tidyr::pivot_longer(df, cols = c("pH", "Hardness"), names_to = "Parameter", values_to = "Value")
      g <- ggplot(df_long, aes(x = Model_Classification, y = Value, fill = Model_Classification)) +
        geom_boxplot(alpha = 0.75, outlier.alpha = 0.4, outlier.size = 1) +
        scale_fill_manual(values = c("Non-potable" = "#dc2626", "Potable" = "#0d9488")) +
        facet_wrap(~Parameter, scales = "free_y") +
        labs(x = NULL, y = "Value", fill = NULL) + theme_ws()
      safe_run(ggplotly(g), "pH/Hardness Boxplot")
    })

    output$dash_box_chlor_turb <- renderPlotly({
      df <- dash_data()
      df_long <- tidyr::pivot_longer(df, cols = c("Chloramines", "Turbidity"), names_to = "Parameter", values_to = "Value")
      g <- ggplot(df_long, aes(x = Model_Classification, y = Value, fill = Model_Classification)) +
        geom_boxplot(alpha = 0.75, outlier.alpha = 0.4, outlier.size = 1) +
        scale_fill_manual(values = c("Non-potable" = "#dc2626", "Potable" = "#0d9488")) +
        facet_wrap(~Parameter, scales = "free_y") +
        labs(x = NULL, y = "Value", fill = NULL) + theme_ws()
      safe_run(ggplotly(g), "Chloramines/Turbidity Boxplot")
    })

    output$dash_scatter_ph_turb <- renderPlotly({
      df <- dash_data()
      g <- ggplot(df, aes(x = pH, y = Turbidity, colour = Model_Classification,
                          text = paste0("pH: ", round(pH,2), "<br>Turbidity: ", round(Turbidity,2),
                                        "<br>Prob: ", round(Predicted_Probability,3)))) +
        geom_point(alpha = 0.5, size = 1.2) +
        scale_colour_manual(values = c("Non-potable" = "#dc2626", "Potable" = "#0d9488")) +
        labs(x = "pH", y = "Turbidity (NTU)", colour = NULL) + theme_ws()
      safe_run(ggplotly(g, tooltip = "text"), "pH vs Turbidity Scatter")
    })

    output$dash_scatter_chl_sulf <- renderPlotly({
      df <- dash_data()
      g <- ggplot(df, aes(x = Chloramines, y = Sulfate, colour = Model_Classification,
                          text = paste0("Chloramines: ", round(Chloramines,2),
                                        "<br>Sulfate: ", round(Sulfate,1),
                                        "<br>Prob: ", round(Predicted_Probability,3)))) +
        geom_point(alpha = 0.5, size = 1.2) +
        scale_colour_manual(values = c("Non-potable" = "#dc2626", "Potable" = "#0d9488")) +
        labs(x = "Chloramines (ppm)", y = "Sulfate (mg/L)", colour = NULL) + theme_ws()
      safe_run(ggplotly(g, tooltip = "text"), "Chloramines vs Sulfate Scatter")
    })

    output$dash_violin_prob <- renderPlotly({
      df <- dash_data()
      req("Potability" %in% names(df))
      df$Actual <- factor(ifelse(df$Potability == 1, "Potable (Actual)", "Non-Potable (Actual)"))
      g <- ggplot(df, aes(x = Actual, y = Predicted_Probability, fill = Actual)) +
        geom_violin(alpha = 0.6, trim = FALSE) +
        geom_boxplot(width = 0.12, fill = "white", outlier.alpha = 0.3) +
        scale_fill_manual(values = c("Non-Potable (Actual)" = "#fca5a5", "Potable (Actual)" = "#6ee7b7")) +
        geom_hline(yintercept = state$model$threshold, linetype = "dashed", colour = "#0f172a") +
        labs(x = NULL, y = "Predicted Probability", fill = NULL) + theme_ws()
      safe_run(ggplotly(g), "Violin: Prob by Actual Potability")
    })

    output$dash_threshold <- renderPlotly({
      m  <- state$model
      tbl <- threshold_table(m$y_test, m$p_test)
      tbl_long <- tidyr::pivot_longer(tbl, cols = -Threshold, names_to = "Metric", values_to = "Value")
      g <- ggplot(tbl_long, aes(x = Threshold, y = Value, colour = Metric)) +
        geom_line(linewidth = 1.1) +
        geom_vline(xintercept = m$threshold, linetype = "dashed", colour = "#0f172a", linewidth = 0.8) +
        scale_colour_manual(values = c(
          "Accuracy"    = "#0284c7", "Sensitivity" = "#0d9488",
          "Specificity" = "#7c3aed", "F1_Score"    = "#f59e0b")) +
        labs(x = "Decision Threshold", y = "Score", colour = "Metric") +
        scale_y_continuous(limits = c(0, 1)) + theme_ws()
      safe_run(ggplotly(g), "Threshold Performance Chart")
    })

    output$dash_roc <- renderPlotly({
      safe_run(ggplotly(plot_roc(state$model$roc, state$model$auc)), "ROC Curve")
    })

    output$dash_calibration <- renderPlotly({
      m <- state$model
      validate(need(!is.null(m$calibration), "Calibration data unavailable."))
      safe_run(ggplotly(plot_calibration(m$calibration)), "Calibration Curve")
    })

    output$dash_forest <- renderPlotly({
      safe_run(ggplotly(plot_odds_ratios(state$model$coefs)), "Odds Ratios Forest Plot")
    })

    output$dash_cm <- renderPlotly({
      m  <- state$model
      ev <- classification_metrics(m$y_test, m$p_test, m$threshold)
      safe_run(ggplotly(plot_confusion_matrix(ev$counts)), "Confusion Matrix")
    })

    output$dash_class_balance <- renderPlotly({
      m <- state$model
      df_bal <- data.frame(
        Split = factor(c("Training", "Training", "Testing", "Testing"), levels = c("Training", "Testing")),
        Class = c("Non-Potable", "Potable", "Non-Potable", "Potable"),
        Count = c(
          m$classes_train$Count[1],
          m$classes_train$Count[2],
          m$classes_test$Count[1],
          m$classes_test$Count[2]
        )
      )
      g <- ggplot(df_bal, aes(x = Split, y = Count, fill = Class)) +
        geom_col(position = "dodge", alpha = 0.85) +
        scale_fill_manual(values = c("Non-Potable" = "#dc2626", "Potable" = "#0d9488")) +
        labs(x = NULL, y = "Sample Count", fill = "Class") + theme_ws()
      safe_run(ggplotly(g), "Class Balance Chart")
    })

    output$dash_heatmap <- renderPlotly({
      req(state$data)
      cm <- cor_matrix(state$data, "pearson")
      safe_run(ggplotly(plot_heatmap(cm)), "Correlation Heatmap")
    })

    output$dash_means_bar <- renderPlotly({
      req(isTRUE(state$validation$has_target), state$data)
      g <- plot_means_barchart(add_group(state$data))
      safe_run(ggplotly(g), "Parameter Means Bar Chart")
    })

    # ── Downloads ──────────────────────────────────────────────────────────────
    output$dl_all_stats <- downloadHandler(
      filename = function() paste0("waterstat_statistical_analysis_", Sys.Date(), ".csv"),
      content = function(file) {
        if (is.null(state$data)) return(writeLines(NO_DATA_MSG, file))
        sec <- list(
          Descriptive_Statistics = describe_stats(state$data, WQ_PARAMS),
          Pearson_Correlations   = cor_table(state$data, "pearson"),
          Spearman_Correlations  = cor_table(state$data, "spearman")
        )
        if (isTRUE(state$validation$has_target)) {
          sec$Group_Statistics <- group_stats(state$data)
          sec$Welch_t_tests    <- run_all_ttests(state$data)
        }
        write_sections(file, sec)
      }
    )

    output$dl_all_preds <- downloadHandler(
      filename = function() paste0("waterstat_batch_predictions_", Sys.Date(), ".csv"),
      content = function(file) {
        v <- state$validation
        if (is.null(v)) return(writeLines(NO_DATA_MSG, file))
        sec <- list(
          Validation_Summary = v$summary,
          Class_Distribution = v$classes,
          Predictions        = if (!is.null(state$model) && !is.null(state$raw) && isTRUE(v$ok))
            predict_dataset(state$model, state$raw) else data.frame(Notice = "No model predictions")
        )
        write_sections(file, sec)
      }
    )

    output$dl_all_model <- downloadHandler(
      filename = function() paste0("waterstat_model_specifications_", Sys.Date(), ".csv"),
      content = function(file) {
        m <- state$model
        if (is.null(m)) return(writeLines("No trained model.", file))
        sec <- list(
          Model_Metadata = data.frame(
            Item  = c("Formula","Seed","Train_Fraction","Train_N","Test_N","Test_AUC","Brier_Score","Threshold","Pseudo_R2","AIC"),
            Value = c(m$formula, m$seed, m$train_frac, m$n_train, m$n_test,
                      round(m$auc,4), round(m$brier,4), m$threshold, round(m$pseudo_r2,4), round(m$aic,2))
          ),
          Coefficients = m$coefs,
          VIF = if (!is.null(m$vif) && length(m$vif) > 0)
            data.frame(Predictor = names(m$vif), VIF = round(unname(m$vif), 3))
          else
            data.frame(Note = "VIF not applicable")
        )
        write_sections(file, sec)
      }
    )

    output$dl_all_eval <- downloadHandler(
      filename = function() paste0("waterstat_model_evaluation_", Sys.Date(), ".csv"),
      content = function(file) {
        m <- state$model
        if (is.null(m)) return(writeLines("No trained model.", file))
        e <- classification_metrics(m$y_test, m$p_test, m$threshold)
        sec <- list(
          Metrics           = rbind(data.frame(Metric = "Threshold", Value = m$threshold),
                                    e$table,
                                    data.frame(Metric = c("AUC","Brier"), Value = round(c(m$auc, m$brier), 4))),
          Confusion_Counts  = data.frame(Type = names(e$counts), Count = as.integer(e$counts)),
          Threshold_Comparison = threshold_table(m$y_test, m$p_test)
        )
        write_sections(file, sec)
      }
    )
  })
}

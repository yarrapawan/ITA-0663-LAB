# Module 1 – Water Quality Data Acquisition & Preprocessing
# Handles CSV/Excel upload, validation, duplicate removal, invalid-value auditing,
# Tukey 1.5x IQR outlier detection, missing-value profiling, and interactive data exploration.

module1PreprocessingUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(class = "module-header mb-3 p-3 bg-white rounded shadow-sm border-start border-4 border-primary",
      div(class = "d-flex justify-content-between align-items-center flex-wrap gap-2",
        div(
          h4(class = "mb-1 text-primary fw-bold", icon("database", class = "me-2"), "Module 1: Water Quality Data Acquisition & Preprocessing"),
          p(class = "text-muted mb-0 small",
            "Collects and validates CSV/Excel water laboratory data against physical boundaries (pH 0-14, positive concentrations), profiles missing cells, detects Tukey IQR outliers without data leakage, and provides interactive exploration.")
        ),
        span(class = "badge bg-primary-subtle text-primary fw-bold px-3 py-2 border", icon("shield", class = "me-1"), "Schema & Quality Control")
      )
    ),
    layout_sidebar(
      fillable = FALSE,
      sidebar = sidebar(width = 300,
        h6(class = "fw-bold text-dark", icon("file-arrow-up"), " Data Acquisition"),
        fileInput(ns("file"), "Upload CSV / Excel Dataset", accept = c(".csv", ".xlsx", ".xls")),
        div(class = "small text-muted p-2 rounded bg-light border mb-3",
          tags$strong("Required 9 Parameters:"), br(),
          tags$span(class = "badge bg-secondary m-1", "pH"),
          tags$span(class = "badge bg-secondary m-1", "Hardness"),
          tags$span(class = "badge bg-secondary m-1", "Solids"),
          tags$span(class = "badge bg-secondary m-1", "Chloramines"),
          tags$span(class = "badge bg-secondary m-1", "Sulfate"),
          tags$span(class = "badge bg-secondary m-1", "Conductivity"),
          tags$span(class = "badge bg-secondary m-1", "Organic_carbon"),
          tags$span(class = "badge bg-secondary m-1", "Trihalomethanes"),
          tags$span(class = "badge bg-secondary m-1", "Turbidity"),
          br(),
          tags$strong("Target Label:"), tags$span(class = "badge bg-primary m-1", "Potability (0/1)"),
          br(),
          tags$em("Names are normalized automatically (e.g., ph -> pH).")
        ),
        hr(),
        h6(class = "fw-bold text-dark", icon("download"), " Export Preprocessed Data"),
        downloadButton(ns("dl_clean"),   "Download Cleaned CSV",    class = "btn-outline-primary btn-sm w-100 mb-2"),
        downloadButton(ns("dl_quality"), "Download Quality Report", class = "btn-outline-secondary btn-sm w-100")
      ),
      navset_card_tab(
        id = ns("tabs"),

        # ── Tab 1: Validation Report ──────────────────────────────────────────
        nav_panel(
          title = tagList(icon("clipboard-check"), " Validation Report"),
          uiOutput(ns("v_status")),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("list-check"),        " Dataset Validation Summary"),        tableOutput(ns("v_summary"))),
            card(card_header(icon("scale-balanced"),    " Potability Class Distribution"),     tableOutput(ns("v_classes")))
          ),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("triangle-exclamation"), " Invalid / Physically Impossible Values"), tableOutput(ns("v_invalid"))),
            card(card_header(icon("table-columns"),        " Detected Columns & Types"),              tableOutput(ns("v_types")))
          )
        ),

        # ── Tab 2: Data Quality & Preprocessing ───────────────────────────────
        nav_panel(
          title = tagList(icon("filter"), " Data Quality & Preprocessing"),
          uiOutput(ns("prep_pipeline_info")),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("chart-bar"),    " Missing Values Visualization"),              plotlyOutput(ns("plot_missing"),  height = "320px")),
            card(card_header(icon("chart-column"), " Outlier Count (Tukey 1.5 x IQR)"),          plotlyOutput(ns("plot_outliers"), height = "320px"))
          ),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("file-circle-question"), " Missing Values Table"),                       tableOutput(ns("tab_missing"))),
            card(card_header(icon("shield-halved"),        " Outlier Thresholds (Flagged, Not Removed)"), tableOutput(ns("tab_outliers")))
          )
        ),

        # ── Tab 3: Interactive Data Explorer ──────────────────────────────────
        nav_panel(
          title = tagList(icon("magnifying-glass"), " Interactive Data Explorer"),
          div(class = "d-flex justify-content-between align-items-center mb-2 p-2 bg-light rounded",
            radioButtons(ns("version"), "Select Dataset View:",
              c("Raw Uploaded Data" = "raw", "EDA-Cleaned (Duplicates removed, invalid -> NA)" = "eda"),
              inline = TRUE),
            textOutput(ns("view_dim"))
          ),
          uiOutput(ns("col_select_ui")),
          card(card_header(icon("table"), " Full Dataset Table (Filterable)"),
            DTOutput(ns("data_table"))
          ),
          layout_columns(
            col_widths = c(6, 6),
            card(card_header(icon("arrow-up"),   " First 5 Rows"), tableOutput(ns("table_head"))),
            card(card_header(icon("arrow-down"), " Last 5 Rows"),  tableOutput(ns("table_tail")))
          )
        ),

        # ── Tab 4: Cleaned & Imputed Data (ML-Ready) ──────────────────────────
        nav_panel(
          title = tagList(icon("broom"), " Cleaned & Imputed Data (ML-Ready)"),
          uiOutput(ns("clean_data_ui"))
        )
      )
    )
  )
}

module1PreprocessingServer <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    vr <- reactive({
      validate(need(!is.null(state$validation), NO_DATA_MSG))
      state$validation
    })

    output$v_status <- renderUI({
      v <- vr()
      tagList(
        if (isTRUE(v$ok)) {
          div(class = "alert alert-success d-flex align-items-center mb-3",
            icon("circle-check", class = "fs-4 me-2"),
            div(strong("Dataset Validation Passed! "), "File: ", em(state$source), " is verified and ready for statistical exploration.")
          )
        } else {
          div(class = "alert alert-danger mb-3",
            strong(icon("circle-xmark"), " Validation Failed:"),
            lapply(v$errors, p),
            if (length(v$missing_required)) p("Missing mandatory parameters: ", paste(v$missing_required, collapse = ", "))
          )
        },
        lapply(v$warnings, function(w) {
          div(class = "alert alert-warning py-2 mb-2 small d-flex align-items-center",
            icon("triangle-exclamation", class = "me-2"), w)
        })
      )
    })

    output$v_summary <- renderTable({ vr()$summary })
    output$v_classes <- renderTable({
      v <- vr()
      validate(need(!is.null(v$classes), "Potability target column missing or invalid."))
      v$classes
    })
    output$v_invalid <- renderTable({ vr()$invalid })
    output$v_types   <- renderTable({ vr()$types })

    output$prep_pipeline_info <- renderUI({
      need_valid(state)
      v <- state$validation
      div(class = "p-3 mb-3 bg-light rounded border",
        h6(class = "fw-bold text-primary", icon("gears"), " Preprocessing Methodology Implemented:"),
        tags$ul(class = "mb-0",
          tags$li(strong("Path 1 (EDA & Descriptive Analysis): "),
            sprintf("%d duplicate row(s) removed; negative numbers and pH values > 14 replaced with NA; no global imputation to prevent artificial distribution bias.", v$duplicates)),
          tags$li(strong("Path 2 (Hypothesis Testing & Regression): "),
            "Complete pairwise or group-wise observations are filtered on demand per test, preserving authentic sample variances."),
          tags$li(strong("Path 3 (Machine Learning Pipeline): "),
            "Stratified train/test split (seed-controlled), followed by median imputation, log1p transformation for Solids, and Z-score standardization fitted strictly on training data only to avoid data leakage.")
        )
      )
    })

    miss_data <- reactive({
      need_valid(state)
      missing_summary(state$raw)
    })

    out_data <- reactive({
      need_valid(state)
      outlier_summary(state$data)
    })

    output$plot_missing  <- renderPlotly({ safe_run(ggplotly(plot_missing_bars(miss_data())), "Missing Values Plot") })
    output$plot_outliers <- renderPlotly({ safe_run(ggplotly(plot_outlier_bars(out_data())),  "Outliers Plot") })
    output$tab_missing   <- renderTable({ miss_data() })
    output$tab_outliers  <- renderTable({ out_data() })

    # Explorer
    current_df <- reactive({
      validate(need(!is.null(state$raw), NO_DATA_MSG))
      if (identical(input$version, "eda") && !is.null(state$data)) state$data else state$raw
    })

    output$view_dim <- renderText({
      d <- current_df()
      sprintf("Dimensions: %d rows x %d columns", nrow(d), ncol(d))
    })

    output$col_select_ui <- renderUI({
      cols <- names(current_df())
      checkboxGroupInput(ns("cols"), "Visible Columns:", cols, selected = cols, inline = TRUE)
    })

    output$data_table <- renderDT({
      d    <- current_df()
      cols <- if (length(input$cols)) intersect(input$cols, names(d)) else names(d)
      d_sub <- d[, cols, drop = FALSE]
      num_cols <- which(vapply(d_sub, is.numeric, logical(1)))
      dt <- datatable(d_sub, filter = "top", options = list(pageLength = 10, scrollX = TRUE))
      if (length(num_cols) > 0) formatRound(dt, num_cols, 3) else dt
    })

    output$table_head <- renderTable({ head(current_df(), 5) })
    output$table_tail <- renderTable({ tail(current_df(), 5) })

    # ── Cleaned & Imputed Data Tab ────────────────────────────────────────────
    output$clean_data_ui <- renderUI({
      need_valid(state)

      if (is.null(state$model)) {
        return(
          div(class = "p-4",
            div(class = "alert alert-info d-flex align-items-start gap-3 mb-4",
              icon("circle-info", class = "fs-3 mt-1 text-info"),
              div(
                h5(class = "mb-1", "Model Required for Full Imputation View"),
                p(class = "mb-0",
                  "The ML-Ready cleaned data view requires a trained Logistic Regression model from ",
                  strong("Module 3"), ". The model's fitted preprocessor (median imputers + scaler) ",
                  "is used to show the fully imputed & standardized dataset. ",
                  "Until then, the EDA-cleaned view (duplicates removed, invalids → NA) is shown below.")
              )
            ),
            div(class = "p-2 mb-3 rounded bg-light border",
              h6(class = "fw-bold text-secondary", icon("gears"), " Pipeline Applied So Far (EDA Path):"),
              tags$ol(class = "mb-0 small",
                tags$li(strong("Duplicate Removal:"), " Exact row duplicates removed."),
                tags$li(strong("Invalid → NA:"), " Negative values and pH > 14 set to NA."),
                tags$li(strong("Imputation:"), tags$em(" Pending — Train model in Module 3 to unlock median imputation."))
              )
            ),
            card(
              card_header(icon("table"), " EDA-Cleaned Data (Duplicates removed, invalids → NA)"),
              p(class = "small text-muted px-3 pt-2",
                sprintf("Showing %d rows × %d columns. NA cells indicate missing or invalid values awaiting imputation.",
                        nrow(state$data), ncol(state$data))),
              DTOutput(ns("clean_eda_table"))
            )
          )
        )
      }

      # Model exists: apply_preprocessor to get ML-ready data
      tryCatch({
        ml_df <- apply_preprocessor(state$model$pp, state$raw)

        # Before/after NA counts per column
        raw_na  <- colSums(is.na(state$raw[, WQ_PARAMS, drop = FALSE]))
        ml_na   <- colSums(is.na(ml_df[,  WQ_PARAMS, drop = FALSE]))
        impute_summary <- data.frame(
          Parameter      = WQ_PARAMS,
          NA_Before      = as.integer(raw_na),
          NA_After_ML    = as.integer(ml_na),
          Imputed        = as.integer(raw_na - ml_na),
          stringsAsFactors = FALSE
        )

        tagList(
          div(class = "p-3 pb-0",
            div(class = "alert alert-success d-flex align-items-start gap-3 mb-3",
              icon("circle-check", class = "fs-3 mt-1 text-success"),
              div(
                h5(class = "mb-1", "ML-Ready Cleaned & Imputed Dataset"),
                p(class = "mb-0",
                  "Data has passed through the full ML preprocessing pipeline: ",
                  tags$ol(class = "mb-0 mt-1",
                    tags$li(strong("Duplicate removal")),
                    tags$li(strong("Invalid → NA"), " (negative values, pH > 14)"),
                    tags$li(strong("Median Imputation"), " — missing values filled with training-set medians"),
                    tags$li(strong("log1p Transformation"), " — applied to Solids (TDS) to reduce skew"),
                    tags$li(strong("Z-Score Standardization"), " — all 9 parameters scaled to mean=0, sd=1")
                  )
                )
              )
            ),
            layout_columns(
              col_widths = c(4, 4, 4),
              value_box("Total Records",   format(nrow(ml_df), big.mark = ","),
                showcase = icon("table"),          theme = "primary"),
              value_box("NAs Imputed",     as.character(sum(impute_summary$Imputed)),
                showcase = icon("fill-drip"),      theme = "success"),
              value_box("Parameters Standardized", "9 (Z-Score)",
                showcase = icon("ruler-combined"), theme = "info")
            )
          ),
          div(class = "p-3 pt-2",
            h6(class = "text-muted fw-bold mb-2 border-bottom pb-1",
               icon("chart-bar"), " IMPUTATION SUMMARY — Before vs After"),
            card(
              card_header(icon("table"), " Per-Parameter NA Count: Before & After ML Preprocessing"),
              div(class = "table-responsive p-2", tableOutput(ns("clean_impute_summary")))
            )
          ),
          div(class = "p-3 pt-0",
            h6(class = "text-muted fw-bold mb-2 border-bottom pb-1",
               icon("microscope"), " ML-PREPROCESSED DATA TABLE (Standardized Z-Scores)"),
            card(
              card_header(icon("table"), " Fully Imputed & Standardized Data — All 9 Parameters (mean=0, sd=1)"),
              p(class = "small text-muted px-3 pt-2",
                "Values are Z-scored; Solids column is first log1p-transformed then standardized. ",
                "This is the exact feature matrix fed into the Logistic Regression model."),
              DTOutput(ns("clean_ml_table"))
            )
          )
        )
      }, error = function(e) {
        div(class = "alert alert-warning m-3",
          icon("triangle-exclamation"), " Could not apply ML preprocessor: ", conditionMessage(e))
      })
    })

    output$clean_eda_table <- renderDT({
      validate(need(!is.null(state$data), NO_DATA_MSG))
      d <- state$data
      num_cols <- which(vapply(d, is.numeric, logical(1)))
      dt <- datatable(d, rownames = FALSE, filter = "top",
        options = list(pageLength = 10, scrollX = TRUE))
      if (length(num_cols) > 0) formatRound(dt, num_cols, 3) else dt
    })

    output$clean_impute_summary <- renderTable({
      req(!is.null(state$model), !is.null(state$raw))
      raw_na <- colSums(is.na(state$raw[, WQ_PARAMS, drop = FALSE]))
      tryCatch({
        ml_df  <- apply_preprocessor(state$model$pp, state$raw)
        ml_na  <- colSums(is.na(ml_df[, WQ_PARAMS, drop = FALSE]))
        data.frame(
          Parameter   = WQ_PARAMS,
          NA_Before   = as.integer(raw_na),
          NA_After_ML = as.integer(ml_na),
          Imputed     = as.integer(raw_na - ml_na),
          stringsAsFactors = FALSE
        )
      }, error = function(e) data.frame(Error = conditionMessage(e)))
    })

    output$clean_ml_table <- renderDT({
      req(!is.null(state$model), !is.null(state$raw))
      tryCatch({
        ml_df <- apply_preprocessor(state$model$pp, state$raw)
        num_cols <- which(vapply(ml_df, is.numeric, logical(1)))
        dt <- datatable(ml_df, rownames = FALSE, filter = "top",
          options = list(pageLength = 10, scrollX = TRUE))
        if (length(num_cols) > 0) formatRound(dt, num_cols, 4) else dt
      }, error = function(e) {
        datatable(data.frame(Error = conditionMessage(e)))
      })
    })

    # Downloads
    output$dl_clean <- downloadHandler(
      filename = function() paste0("waterstat_cleaned_data_", Sys.Date(), ".csv"),
      content  = function(file) {
        if (is.null(state$data)) return(writeLines(NO_DATA_MSG, file))
        utils::write.csv(state$data, file, row.names = FALSE)
      }
    )

    output$dl_quality <- downloadHandler(
      filename = function() paste0("waterstat_quality_report_", Sys.Date(), ".csv"),
      content  = function(file) {
        v <- state$validation
        if (is.null(v)) return(writeLines(NO_DATA_MSG, file))
        sec <- list(
          Validation_Summary = v$summary,
          Missing_Values     = missing_summary(state$raw),
          Outliers_Tukey     = if (!is.null(state$data)) outlier_summary(state$data) else data.frame(Notice = "No data"),
          Invalid_Values     = v$invalid
        )
        write_sections(file, sec)
      }
    )
  })
}

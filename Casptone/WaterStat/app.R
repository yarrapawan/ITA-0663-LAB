# WaterStat - Interactive Statistical Framework for Water Quality Assessment and Potability Analysis Using R and Shiny
# B.Tech CSE Project Platform | Pure Software Implementation (No Hardware / IoT Required)

library(shiny)
library(bslib)
library(plotly)
library(DT)
library(ggplot2)
library(dplyr)

# Support up to 50 MB dataset uploads
options(shiny.maxRequestSize = 50 * 1024^2)

# Source all core statistical & helper logic from R/
for (f in c("preprocessing", "descriptive_analysis", "hypothesis_testing", "regression", "pca_analysis", "model_training", "visualization")) {
  source(file.path("R", paste0(f, ".R")), local = FALSE)
}

# Source all modules
for (f in list.files("modules", full.names = TRUE, pattern = "\\.R$")) {
  source(f, local = FALSE)
}

OPTIONAL_DATA <- "data/water_quality.csv"

set_current_dataset <- function(state, raw, name) {
  v <- validate_dataset(raw)
  state$raw <- raw
  state$source <- name
  state$validation <- v
  state$data <- if (isTRUE(v$ok)) eda_data(raw) else NULL
  
  # Auto-train baseline model if dataset has usable potability target
  if (isTRUE(v$ok_model)) {
    state$model <- tryCatch(
      train_logistic(raw, seed = 42, train_frac = 0.80, threshold = 0.50),
      error = function(e) NULL
    )
  } else {
    state$model <- NULL
  }
}

clear_dataset <- function(state, name, msg) {
  state$model <- NULL
  state$raw <- NULL
  state$data <- NULL
  state$source <- name
  state$validation <- list(
    ok = FALSE, has_target = FALSE, ok_model = FALSE, errors = msg,
    warnings = character(), missing_required = character(),
    summary = data.frame(Item = "Dataset status", Value = "Invalid")
  )
}

pipeline_steps <- c(
  "Upload Dataset", "Validate", "Preprocess", "Analyze", "Visualize",
  "Statistical Tests", "Train Model", "Evaluate", "Assess Potability"
)

# Main UI layout
ui <- page_navbar(
  id = "nav",
  title = tagList(
    span(class = "ws-brand-icon", icon("droplet")),
    span(class = "ws-brand-title", "WaterStat"),
    span(class = "ws-brand-pill", "Enterprise v2.4")
  ),
  fillable = FALSE,
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#0f766e",
    secondary = "#0284c7"
  ),
  header = tags$head(
    tags$link(rel = "stylesheet", href = "styles.css"),
    tags$meta(name = "description", content = "WaterStat: An Interactive Statistical Framework for Water Quality Assessment and Potability Analysis Using R and Shiny"),
    tags$script(HTML("
      $(document).on('shown.bs.tab', function() {
        window.dispatchEvent(new Event('resize'));
        setTimeout(function() {
          window.dispatchEvent(new Event('resize'));
        }, 120);
      });
    "))
  ),
  
  # Home / Project Overview Tab
  nav_panel(
    title = tagList(icon("house"), " Home"),
    value = "home",
    div(class = "container-fluid py-2",
      # High-Impact Enterprise Hero Banner
      div(class = "ws-hero",
        div(class = "d-flex justify-content-between align-items-start flex-wrap gap-3",
          div(style = "max-width: 860px;",
            div(class = "ws-hero-badge", icon("microscope"), " Applied Environmental Informatics & Statistical Machine Learning"),
            h2("WaterStat Environmental Intelligence Platform"),
            h5(class = "ws-hero-subtitle", "Interactive Statistical Framework for Multi-Parameter Water Quality Assessment and Potability Analysis"),
            p(class = "ws-hero-p", "A software-only computational platform unifying physical boundary validation, exploratory visual analytics, inferential hypothesis testing (Welch t-tests, ANOVA), unsupervised PCA, and stratified logistic potability modeling with explainable log-odds contributions."),
            div(class = "ws-hero-stats",
              div(class = "ws-hero-chip",
                div(class = "ws-hero-chip-icon", icon("database")),
                div(
                  div(class = "ws-hero-chip-val", "3,276"),
                  div(class = "ws-hero-chip-lbl", "Water Samples")
                )
              ),
              div(class = "ws-hero-chip",
                div(class = "ws-hero-chip-icon", icon("vials")),
                div(
                  div(class = "ws-hero-chip-val", "9 Params"),
                  div(class = "ws-hero-chip-lbl", "Physicochemical")
                )
              ),
              div(class = "ws-hero-chip",
                div(class = "ws-hero-chip-icon", icon("shield")),
                div(
                  div(class = "ws-hero-chip-val", "Zero Leakage"),
                  div(class = "ws-hero-chip-lbl", "Split-First ML")
                )
              ),
              div(class = "ws-hero-chip",
                div(class = "ws-hero-chip-icon", icon("square-root-variable")),
                div(
                  div(class = "ws-hero-chip-val", "Explainable AI"),
                  div(class = "ws-hero-chip-lbl", "Log-Odds / ORs")
                )
              )
            )
          ),
          div(class = "d-flex flex-column gap-2 mt-2",
            uiOutput("hero_action_btn"),
            actionButton("go_mod1_hero", "Explore Preprocessing", class = "btn btn-outline-light btn-sm shadow-sm", icon = icon("filter")),
            actionButton("go_mod3_hero", "View Hypothesis Tests", class = "btn btn-outline-light btn-sm shadow-sm", icon = icon("chart-line"))
          )
        )
      ),

      # System Architecture & Flow
      div(class = "ws-pipeline-card",
        div(class = "d-flex justify-content-between align-items-center mb-2",
          h6(class = "fw-bold text-dark mb-0", icon("diagram-project", class = "text-primary me-2"), " End-to-End Closed-Loop Pipeline Architecture"),
          span(class = "badge bg-light text-secondary border", "Automated Execution")
        ),
        div(class = "ws-pipeline-track",
          lapply(seq_along(pipeline_steps), function(i) {
            tagList(
              div(class = "ws-pipeline-node",
                span(class = "ws-pipeline-num", sprintf("%02d", i)),
                span(pipeline_steps[i])
              ),
              if (i < length(pipeline_steps)) span(class = "ws-pipeline-arrow", icon("chevron-right"))
            )
          })
        )
      ),

      # Live Dataset Status & Metrics
      h5(class = "fw-bold text-dark mb-3", icon("database", class = "text-primary me-2"), " Active Dataset Overview & Health"),
      uiOutput("dataset_banner"),
      uiOutput("dataset_value_boxes"),

      # 4 Modules Navigation Cards
      h5(class = "fw-bold text-dark mt-4 mb-3", icon("cubes", class = "text-primary me-2"), " Project Modules"),
      div(class = "row g-3 mb-4",
        div(class = "col-md-3",
          div(class = "feature-module-card border-top border-4 border-primary",
            div(
              div(class = "d-flex justify-content-between align-items-start mb-2",
                div(class = "module-icon-wrap mod1-icon", icon("database")),
                span(class = "badge bg-primary-subtle text-primary fw-bold", "Module 1")
              ),
              h6(class = "fw-bold text-dark mb-1", "Data Acquisition & Preprocessing"),
              p(class = "small text-muted mb-2", "Accepts CSV/Excel data, validates physical parameters, identifies missing cells and outliers (Tukey rule), and provides data explorer."),
              div(class = "badge-group",
                span(class = "tag-pill", "Physical Bounds"),
                span(class = "tag-pill", "Tukey 1.5x IQR"),
                span(class = "tag-pill", "Zero Leakage")
              )
            ),
            actionButton("go_mod1", "Open Module 1", class = "btn btn-outline-primary btn-sm w-100 mt-2")
          )
        ),
        div(class = "col-md-3",
          div(class = "feature-module-card border-top border-4 border-info",
            div(
              div(class = "d-flex justify-content-between align-items-start mb-2",
                div(class = "module-icon-wrap mod2-icon", icon("chart-pie")),
                span(class = "badge bg-info-subtle text-info fw-bold", "Module 2")
              ),
              h6(class = "fw-bold text-dark mb-1", "Descriptive & Exploratory Analysis"),
              p(class = "small text-muted mb-2", "Univariate histograms, KDE density, boxplots, violin plots, bivariate scatter plots, correlation heatmaps, and summary tables."),
              div(class = "badge-group",
                span(class = "tag-pill", "KDE & Violin"),
                span(class = "tag-pill", "Z-Scores"),
                span(class = "tag-pill", "Pearson/Spearman")
              )
            ),
            actionButton("go_mod2", "Open Module 2", class = "btn btn-outline-info btn-sm w-100 mt-2")
          )
        ),
        div(class = "col-md-3",
          div(class = "feature-module-card border-top border-4 border-success",
            div(
              div(class = "d-flex justify-content-between align-items-start mb-2",
                div(class = "module-icon-wrap mod3-icon", icon("brain")),
                span(class = "badge bg-success-subtle text-success fw-bold", "Module 3")
              ),
              h6(class = "fw-bold text-dark mb-1", "Inferential Statistics & Modeling"),
              p(class = "small text-muted mb-2", "Welch t-tests, ANOVA with diagnostics, Chi-square test, MLR with residual plots, PCA reduction, and Logistic Regression training."),
              div(class = "badge-group",
                span(class = "tag-pill", "Welch t-test"),
                span(class = "tag-pill", "PCA Biplot"),
                span(class = "tag-pill", "Odds Ratios")
              )
            ),
            actionButton("go_mod3", "Open Module 3", class = "btn btn-outline-success btn-sm w-100 mt-2")
          )
        ),
        div(class = "col-md-3",
          div(class = "feature-module-card border-top border-4 border-warning",
            div(
              div(class = "d-flex justify-content-between align-items-start mb-2",
                div(class = "module-icon-wrap mod4-icon", icon("flask-vial")),
                span(class = "badge bg-warning-subtle text-warning-emphasis fw-bold", "Module 4")
              ),
              h6(class = "fw-bold text-dark mb-1", "Laboratory Console & Assessment"),
              p(class = "small text-muted mb-2", "Batch dataset potability evaluation, custom single-sample laboratory assessment calculator, WHO audit, and consolidated report export."),
              div(class = "badge-group",
                span(class = "tag-pill", "Lab Console"),
                span(class = "tag-pill", "WHO Audit"),
                span(class = "tag-pill", "Export CSV")
              )
            ),
            actionButton("go_mod4", "Open Module 4", class = "btn btn-outline-warning btn-sm w-100 mt-2")
          )
        )
      ),

      # Viva & Project Defense Guide Accordion
      div(class = "card p-3 shadow-sm",
        h6(class = "fw-bold text-dark mb-2", icon("chalkboard-user", class = "text-primary me-2"), " Project Viva & Presentation Reference Points"),
        tags$ul(class = "small text-muted mb-0",
          tags$li(strong("Architecture Type: "), "Pure software application using R (computational engine) and R Shiny (reactive UI). No physical sensors or microcontroller hardware used."),
          tags$li(strong("9 Physicochemical Parameters: "), "pH, Hardness, Solids (TDS), Chloramines, Sulfate, Conductivity, Organic Carbon, Trihalomethanes, and Turbidity."),
          tags$li(strong("Statistical Rigor: "), "Three separate preprocessing paths: EDA path (unimputed), Hypothesis testing path (pairwise complete cases), Machine learning path (stratified training split, training-only median imputation, log1p transformation, and Z-score standardization)."),
          tags$li(strong("Model Diagnostics: "), "Odds ratios with 95% Wald confidence intervals, VIF multicollinearity checking, McFadden pseudo-R², AIC, interactive ROC/AUC, and probability calibration.")
        )
      )
    )
  ),

  # Module 1 Tab
  nav_panel(
    title = tagList(icon("database"), " Module 1: Preprocessing"),
    value = "mod1",
    module1PreprocessingUI("mod1")
  ),

  # Module 2 Tab
  nav_panel(
    title = tagList(icon("chart-pie"), " Module 2: Descriptive Statistics"),
    value = "mod2",
    module2DescriptiveUI("mod2")
  ),

  # Module 3 Tab
  nav_panel(
    title = tagList(icon("brain"), " Module 3: Inferential & Modeling"),
    value = "mod3",
    module3InferentialUI("mod3")
  ),

  # Module 4 Tab
  nav_panel(
    title = tagList(icon("droplet"), " Module 4: Dashboard & Assessment"),
    value = "mod4",
    module4AssessmentUI("mod4")
  ),

  nav_spacer(),
  nav_item(
    div(class = "d-flex align-items-center gap-2",
      span(class = "badge bg-white text-dark border px-2 py-1 shadow-sm", icon("shield-halved", class = "text-primary me-1"), " WHO 2022 Compliant"),
      span(class = "ws-engine-status",
        span(class = "ws-pulse-dot"), " Engine: R-4.6.1 Live"
      )
    )
  )
)

# Server Logic
server <- function(input, output, session) {
  state <- reactiveValues(
    raw = NULL,
    data = NULL,
    validation = NULL,
    source = "none",
    model = NULL
  )

  # Check for optional auto-load dataset
  if (file.exists(OPTIONAL_DATA)) {
    r <- tryCatch(read_water_data(OPTIONAL_DATA), error = function(e) NULL)
    if (!is.null(r)) {
      set_current_dataset(state, r, paste0(OPTIONAL_DATA, " (auto-loaded)"))
    }
  }

  # Initialize all 4 modules
  module1PreprocessingServer("mod1", state)
  module2DescriptiveServer("mod2", state)
  module3InferentialServer("mod3", state)
  module4AssessmentServer("mod4", state)

  # Navigation event observers
  observeEvent(input$go_mod1, nav_select("nav", "mod1"))
  observeEvent(input$go_mod1_hero, nav_select("nav", "mod1"))
  observeEvent(input$go_mod2, nav_select("nav", "mod2"))
  observeEvent(input$go_mod3, nav_select("nav", "mod3"))
  observeEvent(input$go_mod3_hero, nav_select("nav", "mod3"))
  observeEvent(input$go_mod4, nav_select("nav", "mod4"))
  observeEvent(input$go_upload, nav_select("nav", "mod1"))

  # Home Tab Reactive Outputs
  output$hero_action_btn <- renderUI({
    if (is.null(state$raw)) {
      actionButton("go_upload", "Upload Dataset Now", class = "btn-primary btn-md shadow", icon = icon("upload"))
    } else {
      actionButton("go_mod4", "Go to Potability Assessment", class = "btn-secondary btn-md shadow text-white", icon = icon("magnifying-glass-chart"))
    }
  })

  output$dataset_banner <- renderUI({
    v <- state$validation
    if (is.null(v)) {
      div(class = "alert alert-secondary d-flex align-items-center justify-content-between p-3",
        div(
          strong(icon("folder-open"), " No Dataset Loaded Currently: "),
          "Please upload a CSV or Excel water-quality dataset in Module 1 to activate statistical testing and modeling."
        ),
        actionButton("go_upload", "Upload File in Module 1", class = "btn-primary btn-sm")
      )
    } else if (!isTRUE(v$ok)) {
      div(class = "alert alert-danger p-3",
        strong(icon("circle-xmark"), " Dataset Validation Failed: ", state$source),
        lapply(v$errors, p),
        p("Review the full validation audit report in Module 1.")
      )
    } else {
      div(class = "alert alert-success d-flex align-items-center p-3",
        icon("circle-check", class = "fs-4 me-3"),
        div(
          strong("Active Verified Dataset: "), state$source,
          span(class = "ms-2 badge bg-success", "Validation Passed")
        )
      )
    }
  })

  output$dataset_value_boxes <- renderUI({
    v <- state$validation
    req(v, state$raw, isTRUE(v$ok))
    cl <- v$classes
    potable_count <- if (!is.null(cl) && nrow(cl) >= 2) cl$Count[2] else if (!is.null(cl) && nrow(cl) == 1 && grepl("1", cl$Class[1])) cl$Count[1] else "N/A"
    nonpotable_count <- if (!is.null(cl) && nrow(cl) >= 1 && grepl("0", cl$Class[1])) cl$Count[1] else "N/A"
    model_trained <- !is.null(state$model)

    layout_columns(
      col_widths = c(4, 4, 4, 4, 4, 4),
      value_box("Total Observations", v$rows, showcase = icon("table-cells"), theme = "primary"),
      value_box("Water Parameters", v$cols, showcase = icon("list"), theme = "info"),
      value_box("Potable Samples", potable_count, showcase = icon("shield-heart"), theme = "success"),
      value_box("Non-Potable Samples", nonpotable_count, showcase = icon("triangle-exclamation"), theme = "danger"),
      value_box("Missing Values", v$missing, showcase = icon("filter"), theme = "light", p(sprintf("%d duplicate rows", v$duplicates))),
      value_box(
        "Modeling Status",
        if (model_trained) sprintf("Trained (AUC %.3f)", state$model$auc) else "Not Trained",
        showcase = icon("brain"),
        theme = if (model_trained) "success" else "warning"
      )
    )
  })
}

shinyApp(ui, server)
